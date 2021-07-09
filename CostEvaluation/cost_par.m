function [R]=cost_par(W,Filter)

R=zeros(length(W));
norm=ones(length(W));
%------------------------normalization matrix------------------------------
r=sum(abs(W),2);
r=repelem(r,1,length(W));
c=sum(abs(W),1);
c=repelem(c,length(W),1);
norm_par=r+c-2.*abs(W);
norm_par=norm_par-diag(diag(norm_par))+eye(length(W));
%% ------------------------compensation matrix------------------------------
% Wpos_out=zeros(length(W));
% Wneg_out=zeros(length(W));
% 
% Wpos=W.*(W>0);
% a=find(Wpos>0);
% out_pos=isoutlier(Wpos(Wpos>0),'percentiles', [0 80]);
% Wpos_out(a(out_pos))=1 ;                  %W(a(out_pos));
% 
% Wneg=W.*(W<0);
% a=find(Wneg<0);
% out_neg=isoutlier(abs(Wneg(Wneg<0)),'percentiles', [0 95]);
% Wneg_out(a(out_neg))=1 ;                  %W(a(out_neg));
% 
% Wout=Wpos_out+Wneg_out;
% r=sum(Wout,1);
% r=repelem(r,length(W),1);
% c=sum(Wout,2);
% c=repelem(c,1,length(W));
% N=r+c;
% % N(1:400*2,1:400*2)=weight_conversion(N(1:400*2,1:400*2),'normalize');
% % N(400*2:end,1:400*2)=weight_conversion(N(400*2:end,1:400*2),'normalize');
% % N(1:400*2,400*2:end)=weight_conversion(N(1:400*2,400*2:end),'normalize');
% 
% %%
% % tstart=tic;
% % for i=1:length(W)
% %     for j=1:length(W)
% %         weight=W(i,j);
% %         if weight~=0
% %             
% %             %norm(i,j) = sum(abs(W(i,:))) + sum(abs(W(:,j)))-2*weight;      % compute normalization term
% %             idx_i=(W(i,:)>0);
% %             idx_j=(W(:,j)>0);
% %             Npos =sum(isoutlier([abs(W(i,idx_i)) abs(W(idx_j,j))'],'percentiles', [0 75]));
% %             idx_i=(W(i,:)<0);
% %             idx_j=(W(:,j)<0);
% %             Nneg =sum(isoutlier([abs(W(i,idx_i)) abs(W(idx_j,j))'],'percentiles', [0 80]));
% %             N(i,j)=Npos+Nneg;                                            % comput compensation term
% %            
% %         end
% %        
% %     end
% %     fprintf("i=%f \n",i);
% %     
% %       
% % end
% % toc(tstart)
if Filter
    minNorm =min(norm(norm~=1));
    maxNorm =max(norm(:));
    NormSF=tanh(rescale(norm,0,(maxNorm-minNorm)/minNorm));
    R=W./norm.*N;
else 
    R=W./norm_par;   
end
