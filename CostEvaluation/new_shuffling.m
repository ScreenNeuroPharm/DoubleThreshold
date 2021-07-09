function [R]=new_shuffling(W)

R=zeros(length(W));
%------------------------normalization matrix------------------------------

%% ------------------------compensation matrix------------------------------
Wpos_out=zeros(length(W));
Wneg_out=zeros(length(W));

Wpos=W.*(W>0);
a=find(Wpos>0);
out_pos=isoutlier(Wpos(Wpos>0),'percentiles', [0 80]);
Wpos_out(a(out_pos))=W(a(out_pos));

Wneg=W.*(W<0);
a=find(Wneg<0);
out_neg=isoutlier(abs(Wneg(Wneg<0)),'percentiles', [0 95]);
Wneg_out(a(out_neg))=W(a(out_neg));

Wnoise_pos=Wpos-Wpos_out;
Wnoise_neg=Wneg-Wneg_out;
Wnoise=Wnoise_pos+Wnoise_neg;
[r,c]=find(Wnoise);
Wout=Wpos_out+Wneg_out;

for i=1:length(r)
    %for j=1:length(W)
        weight=Wnoise(r(i),c(i));
        if weight>0 
           %noise = [Wnoise(i,(Wnoise(i,:)>0)) Wnoise((Wnoise(:,j)>0),j)'];
           %R(i,j)=W(i,j)./abs(mean(noise));
            idx_i=(Wnoise(r(i),:)>0);
            idx_j=(Wnoise(:,c(i))>0);
            noise=[(W(r(i),idx_i)) (W(idx_j,c(i)))'];
             if (weight > mean(noise)+3*std(noise)) 
                 Wout(r(i),c(i))=weight;
             end
        else
%            noise = [Wnoise(i,(Wnoise(i,:)<0)) Wnoise((Wnoise(:,j)<0),j)'];
%            R(i,j)=W(i,j)./abs(mean(noise));
            idx_i=(W(r(i),:)<0);
            idx_j=(W(:,c(i))<0);
            noise=[(W(r(i),idx_i)) (W(idx_j,c(i)))'];
             if (weight < mean(noise)-3*std(noise)) 
                 Wout(r(i),c(i))=weight;
             end   
        end
       
    %end
   
      
end
R=Wout; 
end
