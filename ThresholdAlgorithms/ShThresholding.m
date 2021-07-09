function Wout=ShThresholding(W,Wshuffled,alpha_exc,alpha_inh)
%ShThresholding.m evaluates the thresholded connectivity matrix known a
%surrogate datased 'Wshuffled' and alpha 
%--------------------------input-------------------------------------------
%     W: square weighted Connectivity Matrix (NxN)
%     Wshuffled: surrogate shuffled dataset (NxNxM)
%     aplha: accuracy of a single tail z-test
if alpha_exc>1 || alpha_inh>1 
    error("alpha values should be minor than 1")
end 
if size(W,1)~=size(Wshuffled,1)
    error("different W and Wshuffled dimension")
end
Wout=zeros(length(W));
for i=1:length(W)
    for j=1:length(W)
        if W(i,j)>0
          if ztest(W(i,j),mean(Wshuffled(i,j,:)),std(Wshuffled(i,j,:)),'alpha',alpha_exc,'tail','right') Wout(i,j)=W(i,j); end
        else
          if ztest(W(i,j),mean(Wshuffled(i,j,:)),std(Wshuffled(i,j,:)),'alpha',alpha_inh,'tail','left') Wout(i,j)=W(i,j); end
        end
    end
end




