function Wout = DDT(W,nexc,ninh,mexc,minh)
%Double Threshold Algorithm
%------------------------------input---------------------------------------
%      W: square weighted Connectivity Matrix with positive and negative
%      values
%      nexc: arbitrary positive value defining the first threshold
%      ninh: arbitrary positive value defining the first threshold
%      mexc: arbitrary positive value defining the first threshold
%      mexc: arbitrary positive value defining the first threshold
%-------------------------------output-------------------------------------
%      Wout: thresholded connectivity matrix

CCcost=zeros(n,n,length(nexc));
CC_bin_cost=zeros(n,n,length(nexc));
Wpositive=zeros(n,n,length(nexc));
%% ------------------------positive------------------------------
for k=1:length(nexc)

    Wpos_out=zeros(length(W));
    Wpos=W.*(W>0);
    a=find(Wpos>0);
    [out_pos,~,~,C]=isoutlier(Wpos(Wpos>0),'mean','ThresholdFactor',nexc(k)); %First Threshold
    Wpos_out(a(out_pos))=W(a(out_pos));
    Wpos_out(Wpos_out<C)=0;
    Wnoise_pos=Wpos-Wpos_out;
    [r,c]=find((Wnoise_pos)~=0);
    
    for i=1:length(r)
            weight=Wnoise_pos(r(i),c(i));
            if weight>0 
               noise = [Wnoise_pos((Wnoise_pos(:,c(i))>0),c(i))' Wnoise_pos(r(i),(Wnoise_pos(r(i),:)>0))];
               th=mean(noise)+(mexc)*std(noise);                           %Second Threshold
               if  weight>th                      
                   Wpos_out(r(i),c(i))= weight;
               end
            end
    end
Wpositive(:,:,k)=Wpos_out;

end
%% --------------------------negative----------------------------------------
Wnegative=zeros(n,n,length(ninh));
for k=1:length(ninh)

    W=ConnectivityMatrix;
    Wneg_out=zeros(length(W));
    Wneg=W.*(W<0);
    a=find(Wneg<0);
    [out_neg,~,~,C]=isoutlier(abs(Wneg(Wneg<0)),'mean','ThresholdFactor',ninh(k)); %First Threshold
    Wneg_out(a(out_neg))=Wneg(a(out_neg));
    Wneg_out(Wneg_out>(-C))=0;
    Wnoise_neg=Wneg-Wneg_out;
    [r,c]=find((Wnoise_neg)~=0);
    for i=1:length(r)
            weight=Wnoise_neg(r(i),c(i));
            if weight<0   
                noise = Wnoise_neg((Wnoise_neg(:,c(i))<0),c(i)); 
                th=mean(noise)-(minh)*std(noise);                             %Second Threshold
                if  weight<th   
                    Wneg_out(r(i),c(i))= weight;          
                end
            end
    end
    Wnegative(:,:,k)=Wneg_out;
end
%-------------------------------saving-------------------------------------
ind=1;
for i=1:length(ninh)
    for j=1:length(nexc)
        Wout(:,:,ind)=Wpositive(:,:,j)+Wnegative(:,:,i);
        ind=ind+1;
    end
end