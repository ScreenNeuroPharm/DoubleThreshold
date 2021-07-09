
%% Create a Thresholded Connectivity Matrix
function [CCMeanStd, CCcost, CC_bin_meanstd,CC_bin_cost,W_check,CCShuffle] = ThresholdMatrixEvaluation(CCfolder,nexc,ninh,n_inh)

    cd (CCfolder);
    DR = dir;
    Directednew=[];

    for k = 3:length(DR)
        if (~isempty(strfind(DR(k).name,'ConnectivityMatrix')))
            load(DR(k).name);
        end
    end
     for k = 3:length(DR)
        if (~isempty(strfind(DR(k).name,'ShuffledCC')))
            load(DR(k).name);
        end
     end

%% ---------------------- First Method Mean-std ---------------------------
n=length(ConnectivityMatrix);
ConnectivityMatrix(isnan(ConnectivityMatrix))=0;
CCMeanStd=zeros(n,n,length(nexc));
CC_bin_meanstd=zeros(n,n,length(nexc));
for k=1:length(nexc)
                            %% Calculation of matrices by setting a threshold
                            
                            CC = ConnectivityMatrix;
                            tmpCC = CC(CC~=0);
                            exc = nexc(k);
                            inh = ninh(k);
                          
                            thres_exc = mean(tmpCC(tmpCC>0))+exc*std(tmpCC(tmpCC>0));
                            thres_inh = mean(tmpCC(tmpCC<0))-inh*std(tmpCC(tmpCC<0));
                            ecc=0;
                            in=0;

                            for i=1:length(CC)
                                for j=1:length(CC)
                                    if CC(i,j)>= 0
                                        if CC(i,j)<thres_exc
                                            CC(i,j) = 0;
                                        else 
                                            ecc = ecc+1;
                                        end
                                    else
                                        if CC(i,j) > thres_inh
                                            CC(i,j) = 0;
                                        else
                                            in = in+1;                    
                                        end
                                    end
                                end
                            end

               

                            fnameCC = fullfile(CCfolder,[strcat('TCM_nexc=',string(exc),'_ninh=',string(inh),'.mat')]);
                            save(fnameCC, 'CC');

                            ratio = ecc*100 /(in+ecc);
                            values = [ratio, in, ecc];
                            fnameratio = fullfile(CCfolder,[strcat('Ratio_TCM_nexc=',string(exc),'_ninh=',string(inh),'.mat')]);
                            save(fnameratio, 'values');

                            %% Given the matrix Directed, the analogous binary is defined
                            CC_bin = CC;
                            CC_bin(CC_bin ~= 0) = 1;

                            fnameBin = fullfile(CCfolder,[strcat('TCM_Binary_nexc=',string(exc),'_ninh=',string(inh),'.mat')]);
                            save(fnameBin, 'CC_bin');

                            %% Graf Theory
                            % Based on the new calculated matrices we want to obtain the number of
                            % nodes and link

                            link= nnz (CC);
                            [r, c] = find(CC ~=0);
                            node = length(union (r, c));
                            fnameNode = fullfile(CCfolder,[strcat('LinkNode_nexc=',string(exc),'_ninh=',string(inh),'.mat')]);
                            %save(fnameNode, 'node','link');
                            
                            CCMeanStd(:,:,k)=CC;
                            CC_bin_meanstd(:,:,k)=CC_bin;
end
%%        --------------------------------------------------------------------------
 nexc=[1];
 ninh=[2];
CCcost=zeros(n,n,length(nexc));
CC_bin_cost=zeros(n,n,length(nexc));
Wpositive=zeros(n,n,length(nexc));
for k=1:length(nexc)
fprintf("positive k=%f\n",k);
W=ConnectivityMatrix;
%% ------------------------positive------------------------------
Wpos_out=zeros(length(W));
Wpos=W.*(W>0);
a=find(Wpos>0);
[out_pos,~,~,C]=isoutlier(Wpos(Wpos>0),'mean','ThresholdFactor',nexc(k));
Wpos_out(a(out_pos))=W(a(out_pos));
Wpos_out(Wpos_out<C)=0;


Wnoise_pos=Wpos-Wpos_out;
[r,c]=find((Wnoise_pos)~=0);
for i=1:length(r)
    %for j=c
        weight=Wnoise_pos(r(i),c(i));
        if weight>0 
           noise = [Wnoise_pos((Wnoise_pos(:,c(i))>0),c(i))' Wnoise_pos(r(i),(Wnoise_pos(r(i),:)>0))];% Wnoise_pos(r(i),(Wnoise_pos(r(i),:)>0));            %noise = Wnoise(r(i),(Wnoise(r(i),:)>0));
         
           th=mean(noise)+(3)*std(noise);              %RND:2 SW:3 SF: 3/3.5
           if  weight>th                       % ttest2(weight,noise,'Tail','right','Alpha',0.001)  
               Wpos_out(r(i),c(i))= weight;
               %fprintf("add positive\n");
           end
%         elseif weight<0   
%             noise = Wnoise((Wnoise(:,c(i))<0),c(i));  %Wnoise((Wnoise(:,c(i))<0),c(i))'
%             %noise = Wnoise(r(i),(Wnoise(r(i),:)<0));
%             h=ttest2(weight,noise,'Tail','left','Alpha',0.001);
% %            th=mean(noise)-(3.5)*std(noise);
%             if h                             % weight<th
%                 Wneg_out(r(i),c(i))= weight;
%                 fprintf("add negative %f %f\n",r(i),c(i));            
%             end
        end
       
    %end
   
      
end
Wpositive(:,:,k)=Wpos_out;
%-----------------------check prop threshold---------------------
en=length(find(Wpos_out));
Wpos_check(:,:,k) = threshold_proportional(Wpos, en);
pos = length(find((Wpos_out==Wpos_check(:,:,k))==0))

end
%% --------------------------negative----------------------------------------
Wnegative=zeros(n,n,length(ninh));
for k=1:length(ninh)
fprintf("negative k=%f\n",k);
W=ConnectivityMatrix;
Wneg_out=zeros(length(W));
Wneg=W.*(W<0);
a=find(Wneg<0);
[out_neg,~,~,C]=isoutlier(abs(Wneg(Wneg<0)),'mean','ThresholdFactor',ninh(k));
Wneg_out(a(out_neg))=Wneg(a(out_neg));
Wneg_out(Wneg_out>(-C))=0;

Wnoise_neg=Wneg-Wneg_out;
[r,c]=find((Wnoise_neg)~=0);
for i=1:length(r)
    %for j=c
        weight=Wnoise_neg(r(i),c(i));
  
        if weight<0   
            noise = Wnoise_neg((Wnoise_neg(:,c(i))<0),c(i)); %Wnoise_neg(r(i),(Wnoise_neg(r(i),:)<0)); 
            %noise = Wnoise(r(i),(Wnoise(r(i),:)<0));
           
            th=mean(noise)-(3)*std(noise);                    %4 per RND e SW-- SF:3.5
            if  weight<th   %ttest2(weight,noise,'Tail','left','Alpha',0.001) %weight<th         
                Wneg_out(r(i),c(i))= weight;
                %fprintf("add negative %f %f\n",r(i),c(i));            
            end
        end
       
    %end
end
Wnegative(:,:,k)=Wneg_out;
en=length(find(Wneg_out));
Wneg_check(:,:,k) = threshold_proportional(abs(Wneg), en);
neg = length(find((Wneg_out==(-Wneg_check(:,:,k)))==0))
end
%--------------------------------------------------------------------------
ind=1;
for i=1:length(ninh)
    for j=1:length(nexc)
        R=Wpositive(:,:,j)+Wnegative(:,:,i);
        W_check=-Wneg_check(:,:,i)+Wpos_check(:,:,j);
        fnameCC = fullfile(CCfolder,'TCM_Nlink.mat');
        save(fnameCC, 'W_check');
        W_check_bin=weight_conversion(W_check,'binarize');
        fnameBin = fullfile(CCfolder,'TCM_Binary_Nlink.mat');
        save(fnameBin, 'W_check_bin');
        fnameCC = fullfile(CCfolder,[strcat('TCM_Cost',string(nexc(j)),'_',string(ninh(i)),'.mat')]);
        save(fnameCC, 'R');
        fnameCC = fullfile(CCfolder,[strcat('TCM_Binary_Cost',string(nexc(j)),'_',string(ninh(i)),'.mat')]);
        R_bin=weight_conversion(R,'binarize');
        save(fnameCC,'R_bin');
        CCcost(:,:,ind)=R;
        CC_bin_cost(:,:,ind)=R_bin;
        ind=ind+1;
    end
end
%% ------------------------- SHUFFLING ------------------------------------
ShuffledCC(ShuffledCC>0)=ShuffledCC(ShuffledCC>0);
ShuffledCC(ShuffledCC<0)=ShuffledCC(ShuffledCC<0);

c=ConnectivityMatrix;
a=zeros(500);
% s_exc=std(ShuffledCC(ShuffledCC>0),0,3);
% s_inh=std(ShuffledCC(ShuffledCC<0),0,3);
% mean_exc = mean(ShuffledCC(ShuffledCC>0),3);
% mean_inh = mean(ShuffledCC(ShuffledCC<0),3);
% thres_exc = mean_exc+4*s_exc;
% thres_inh = mean_inh-3*s_inh;
     for i=1:length(c)
            for j=1:length(c)
                
                if c(i,j)>= 0
                    if i<401
                        tmp=ShuffledCC(i,j,:);
                        thres_exc=mean(tmp(tmp>0)) + 8.5*std(tmp(tmp>0));
                        if c(i,j)>thres_exc
                            a(i,j) = c(i,j);
                        end
                    end
                else
                    if i>400
                        tmp=ShuffledCC(i,j,:);
                        thres_inh=mean(tmp(tmp<0)) - n_inh*std(tmp(tmp<0));
                        if c(i,j) < thres_inh
                           a(i,j) = c(i,j);
                        end
                    end
                end
            end
        end

CCShuffle=a;
fnameBin = fullfile(CCfolder,'TCM_Shuffle.mat');
save(fnameBin, 'CCShuffle');
CCbinShuffle=c;
CCbinShuffle(CCbinShuffle~=0)=1;
fnameBin = fullfile(CCfolder,'TCM_Binary_Shuffle.mat');
save(fnameBin, 'CCbinShuffle');


end





