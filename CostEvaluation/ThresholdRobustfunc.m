%% Create a Thresholded Connectivity Matrix
function [CCcost,W_check,density] = ThresholdRobustfunc(CCfolder)

    cd (CCfolder);
    DR = dir;
    Directednew=[];

    for k = 3:length(DR)
        if (~isempty(strfind(DR(k).name,'ConnectivityMatrix')))
            load(DR(k).name);
        end
    end


%% ---------------------- First Method Mean-std ---------------------------
n=length(ConnectivityMatrix);
ConnectivityMatrix(isnan(ConnectivityMatrix))=0;
%%        --------------------------------------------------------------------------
connExc=(500*499)*80/100;
%en = linspace(connExc*2/100,connExc*15/100,16);
 nexc=1;   %0:0.1:1;
 ninh=2;  %ones(length(nexc),1)*2';
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
           noise = [Wnoise_pos((Wnoise_pos(:,c(i))>0),c(i))' ];% %noise = Wnoise(r(i),(Wnoise(r(i),:)>0));
         
           th=mean(noise)+(3)*std(noise);              %RND:2 SW:3 SF: 3/3.5
           if  weight>th                       % ttest2(weight,noise,'Tail','right','Alpha',0.001)  
               Wpos_out(r(i),c(i))= weight;
               %fprintf("add positive\n");
           end

        end
       
    %end
   
      
end
Wpositive(:,:,k)=Wpos_out;
%-----------------------check prop threshold---------------------
enpos(k)= length(find(Wpos_out)); %rnd21956; 13968sw;mod 12974
Wpos_check(:,:,k) = threshold_proportional(Wpos,enpos(k));
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
           
            th=mean(noise)-(3.5)*std(noise);                    %4 per RND e SW-- SF:3.5
            if  weight<th   %ttest2(weight,noise,'Tail','left','Alpha',0.001) %weight<th         
                Wneg_out(r(i),c(i))= weight;
                %fprintf("add negative %f %f\n",r(i),c(i));            
            end
        end
       
    %end
end
Wnegative(:,:,k)=Wneg_out;
enneg(k)= length(find(Wneg_out)); %rnd5491; %sw3492; mod 3243
Wneg_check(:,:,k) = threshold_proportional(abs(Wneg), enneg(k));
neg = length(find((Wneg_out==(-Wneg_check(:,:,k)))==0))

end
density=(enneg+enpos)/(499*500)*100;
%--------------------------------------------------------------------------
ind=1;
for i=1:length(ninh)
    for j=1:length(nexc)
        R=Wpositive(:,:,j)+Wnegative(:,:,i);
        W_check(:,:,ind)=-Wneg_check(:,:,i)+Wpos_check(:,:,j);
        CCcost(:,:,ind)=R;
        ind=ind+1;
    end
end

end





