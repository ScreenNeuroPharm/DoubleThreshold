%% Create a Thresholded Connectivity Matrix
function [CCnew,CC_bin_new] = ThresholdMatrix2(CC)

n=length(CC);
nexc=1;
ninh=2;
mexc=2:0.1:3.5;
minh=2:0.1:3.5;

Wpositive=zeros(n,n,length(mexc));
for k=1:length(mexc)
fprintf("positive k=%f\n",k);
W=CC;
%% ------------------------positive------------------------------
Wpos_out=zeros(length(W));
Wpos=W.*(W>0);
a=find(Wpos>0);
[out_pos,~,~,C]=isoutlier(Wpos(Wpos>0),'mean','ThresholdFactor',nexc);
Wpos_out(a(out_pos))=W(a(out_pos));
Wpos_out(Wpos_out<C)=0;


Wnoise_pos=Wpos-Wpos_out;
[r,c]=find((Wnoise_pos)~=0);
for i=1:length(r)
    %for j=c
        weight=Wnoise_pos(r(i),c(i));
        if weight>0 
           noise =[ Wnoise_pos(r(i),(Wnoise_pos(r(i),:)>0))   Wnoise_pos((Wnoise_pos(:,c(i))>0),c(i))'];  % Wnoise((Wnoise(:,c(i))>0),c(i))'
           %noise = Wnoise(r(i),(Wnoise(r(i),:)>0));
         
           th=mean(noise)+(mexc(k))*std(noise);              %RND:2 SW:3 SF: 3/3.5
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

end
%% --------------------------negative----------------------------------------
Wnegative=zeros(n,n,length(minh));
for k=1:length(minh)
fprintf("negative k=%f\n",k);
W=CC;
Wneg_out=zeros(length(W));
Wneg=W.*(W<0);
a=find(Wneg<0);
[out_neg,~,~,C]=isoutlier(abs(Wneg(Wneg<0)),'mean','ThresholdFactor',ninh);
Wneg_out(a(out_neg))=Wneg(a(out_neg));
Wneg_out(Wneg_out>(-C))=0;

Wnoise_neg=Wneg-Wneg_out;
[r,c]=find((Wnoise_neg)~=0);
for i=1:length(r)
    %for j=c
        weight=Wnoise_neg(r(i),c(i));
  
        if weight<0   
            noise = Wnoise_neg((Wnoise_neg(:,c(i))<0),c(i));  %Wnoise((Wnoise(:,c(i))<0),c(i))'
            %noise = Wnoise(r(i),(Wnoise(r(i),:)<0));
           
            th=mean(noise)-(minh(k))*std(noise);                    %4 per RND e SW-- SF:3.5
            if  weight<th   %ttest2(weight,noise,'Tail','left','Alpha',0.001) %weight<th         
                Wneg_out(r(i),c(i))= weight;
                %fprintf("add negative %f %f\n",r(i),c(i));            
            end
        end
       
    %end
end
Wnegative(:,:,k)=Wneg_out;
%-----------------------check prop threshold---------------------
en=length(find(Wneg_out));
Wneg_check(:,:,k) = threshold_proportional(abs(Wneg), en);
neg = length(find((Wneg_out==(-Wneg_check(:,:,k)))==0))
end
%--------------------------------------------------------------------------
ind=1;
CCnew=zeros(n,n,length(mexc).^2);
CC_bin_new=zeros(n,n,length(mexc).^2);
for i=1:length(minh)
    for j=1:length(mexc)
        R=Wpositive(:,:,j)+Wnegative(:,:,i);
        %W_check(:,:,ind)=Wneg_check(:,:,j)+Wpos_check(:,:,i);
%         fnameCC = fullfile(CCfolder,[strcat('TCM_Cost',string(mexc(j)),'_',string(minh(i)),'.mat')]);
%         save(fnameCC, 'R');
%         fnameCC = fullfile(CCfolder,[strcat('TCM_Binary_Cost',string(mexc(j)),'_',string(minh(i)),'.mat')]);
         R_bin=weight_conversion(R,'binarize');
%         save(fnameCC,'R_bin');
        CCnew(:,:,ind)=R;
        CC_bin_new(:,:,ind)=R_bin;
        ind=ind+1;
    end
end
end
