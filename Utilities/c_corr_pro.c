/*
 c_xy = c_corr(sp_x, bin_s, win_s,Non);

 MEX file to compute the basis for cross-correlation. The function counts
 the spikes in train sp_y surrounding all spikes in sp_x. sp_x and sp_y
 should be column vectors. bin_s must be odd, so that the spike in sp_x
 can actually serve as the center around which to compute the cross-
 correlation.
 win_s should be a solution to win_s = n_bin * bin_s + (bin_s - 1)/2, with
 n_bin a natural number (it is computed internally). There are checks on
 this in the method, throwing a MatLab warning, and resetting the value to
 a close-by value.
 
 PL Baljon, NBT, DIBE, University of Genova
 v1.0, 07/01/08
 
 */
#include "mex.h"
#include "math.h"
void mexFunction(int nhls, mxArray *plhs[], int nrhs, const mxArray *prhs[]){
    bool debug = false;
    double *bin_s_d, *win_s_d, *n_bin_d, *sp_x, *c_xy,*Non,*r,*x_train,*y_train;
    int  n_x, win_s, bin_s, n_bin,non,ind_x,ind_y,*x_time,*y_time;
   
    sp_x  = mxGetPr(prhs[0]);
    n_x   = mxGetM(prhs[0]);
    bin_s_d = mxGetPr(prhs[1]);
    win_s_d = mxGetPr(prhs[2]);
    Non = mxGetPr(prhs[3]);
    r = mxGetPr(prhs[4]);
    // n_bin_d = mxGetPr(prhs[4]);//(int)(win_s - (&bin_s-1)/2) / &bin_s); // 40

    win_s = (int)(*win_s_d);
    bin_s = (int)(*bin_s_d);
    non = (int)(*Non);                                           // Number Of Neuron
    n_bin = (int)((win_s - (bin_s-1)/2.0) / bin_s);
    
    //plhs[0] = mxCreateDoubleMatrix(n_bin * 2 + 1,1,mxREAL);
    printf("INSIDE");
   
    double *matrix_corr;
    plhs[0] = mxCreateDoubleMatrix((n_bin * 2 + 1)*non*non,1,mxREAL);
    matrix_corr = mxGetPr(plhs[0]);
    //printf("n_x: %d, n_y: %d, bin_s: %d, win_s: %d, n_bin: %d\n",n_x,n_y,bin_s,win_s,n_bin);
    
    if(mxGetN(prhs[0]) > 1)
        mexWarnMsgIdAndTxt("c_corri:InputSizeWarning", "input spike train x should be n_spikes x 1 matrices. dim 2 = %d > 1.",mxGetN(prhs[0]));
    if(mxGetN(prhs[1]) > 1)
        mexWarnMsgIdAndTxt("c_corri:InputSizeWarning", "input spike train y should be n_spikes x 1 matrices. dim 2 = %d > 1.",mxGetN(prhs[1]));
    
    if(bin_s%2 == 0){
        bin_s++;
        mexWarnMsgIdAndTxt("c_corri:EvenBinSize", "bin_s must be odd. reset bin_s: %d -> %d.",bin_s-1,bin_s);
    }
    if((win_s - (int)((double)(bin_s-1)/2.0))%bin_s != 0){
        win_s = (int)((bin_s - 1.0)/2.0) + n_bin * bin_s;
        mexWarnMsgIdAndTxt("c_corri:ParamsDontCorrespond", "bins must fit the window. reset win_s:%d, bin_s:%d, n_bin:%d.",win_s,bin_s,n_bin);
    }
    
   int length_spike_train=n_x/non;
   //printf("length spike train: %d\n n_x:%d \n",length_spike_train,n_x);
   for (int i=0;i<non;i++){                                                // cicli su neurone i
      // printf("Neuron: %d of %d\n",i,non);
       for (int j=0;j<non;j++){                                            // cicli su neurone j
             x_train = (double *) malloc(sizeof(double) * length_spike_train);   // alloca memoria per treno x
             y_train = (double *) malloc(sizeof(double) * length_spike_train);   // alloca memoria per treno y
             x_time = (int *) malloc(sizeof(int) * length_spike_train);   // alloca memoria per treno x
             y_time = (int *) malloc(sizeof(int) * length_spike_train);
              ind_x=0;                                                     // inizializzo indice per treno x e y
              ind_y=0;
             for (int k=0;k < length_spike_train;k++)                      // ciclo sulla lunghezza degli spike train
             {                                                             // cerco gli istanti di tempo dove c'è lo spike
                 if (sp_x[length_spike_train*i+k]!=0)
                    {    //if (debug) printf("\nind_x:%d x_train[%d]:%f \n",ind_x,ind_x,sp_x[length_spike_train*i+k]);
                         x_time[ind_x]=k;
                         x_train[ind_x]=sp_x[length_spike_train*i+k];
                         ind_x=ind_x+1;
                        
                    }
                 if (sp_x[length_spike_train*j+k]!=0)
                    {  
                         y_time[ind_y]=k;
                         y_train[ind_y]=sp_x[length_spike_train*j+k];
                         ind_y=ind_y+1;
                    }
             }
//               if (debug){
//                   printf("x array:");
//                   print_array(x_train,ind_x);
//                   printf("\n");
//                   printf("y array:");
//                   print_array(y_train,ind_y);
//                   printf("\n");
//               }
                 
              double c_xy[2 * n_bin +1];
              c_corr(ind_x, x_train,x_time ,ind_y, y_train,y_time, bin_s, win_s, n_bin, c_xy);
         
              for(int ib = 0; ib < 2 * n_bin + 1; ib++){
                  matrix_corr[i*(2*n_bin+1)*non+j*(2*n_bin+1)+ib]=c_xy[ib]/(r[i]*r[j]);          
                 
                   //if (debug)printf("%f\t", matrix_corr[i*(2*n_bin+1)*non+j*(2*n_bin+1)+ib]);
              
              }
              free(x_train);                                               
              free(y_train);
              free(x_time);                                               
              free(y_time);
              //printf("\n");
   }
}
}

void c_corr(int n_x, double sp_x[],int st_x[], int n_y, double sp_y[], int st_y[],int bin_s, int win_s, int n_bin, double c_xy[]){
    bool debug = false;
    int ix, iy, ib, l_bnd, u_bnd;
    /* Initialize the cross-correlation. */
    for(ib = 0; ib < 2 * n_bin + 1; ib++){
        //printf("Inside C_CORR c_xy[%d]:%f\n",ib,c_xy[ib]);
        c_xy[ib] = 0;
    }
    for(ix = 0, iy = 0; ix < n_x; ix++){
       
        //if(debug) printf("spike %d (%2.1f).\n",ix, sp_x[ix]);
                
        /* Go back to the last spike before the first bin */
            while(iy > 0 && st_y[iy] >= st_x[ix] - (double)win_s){
            
           iy--;
        }

        //if(debug) printf("\tstart iy = %d (%2.1f).\n",iy,sp_y[iy]);
        /* Do for each bin */ 
        for(ib = 0; ib < 2 * n_bin + 1; ib++){
            /* Compute the beginning of this and the next bin*/
            l_bnd = (int)(st_x[ix]) + (ib * bin_s) - win_s;
            u_bnd = (int)(st_x[ix]) - win_s + ((ib+1) * bin_s);
            /* Go to the first spike in this bin. It might skip to the next 
               bin if this one is empty. The lower bound is part of the bin. */
            while(iy < n_y && st_y[iy] < l_bnd)
                iy++;
            
            //if(debug) printf("\t\tib: %d [%d ... %d]. first iy = %d (%2.1f).\n",ib,l_bnd,u_bnd,iy,sp_y[iy]);
            /* For each spike (strictly) smaller than the upper bound increment
               the cross-correlation and go to the next spike. */
            while(iy < n_y && st_y[iy] < u_bnd){
              
                c_xy[ib] = c_xy[ib] + (sp_x[ix]*sp_y[iy]);
               // if(debug) printf("\t\t\tadd s_y[%d]=%2.1f to c_xy[%d]=%2.1f.\n",iy, sp_y[iy],ib,c_xy[ib]);
                iy++;
               
            } 
           
        }
    }
}

void print_array(int a[],int array_length){
    int i;
    for(i=0;i<array_length;i++){
        printf("%d ",a[i]);
                  //for incrementing the position of array.
    }
}