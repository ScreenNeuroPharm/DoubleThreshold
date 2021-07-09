
% Copyright 2015 The MathWorks, Inc.

function h = WattsStrogatz_Boschi(N,K,beta,FracExc)
% H = WattsStrogatz(N,K,beta) returns a Watts-Strogatz model graph with N
% nodes, N*K edges, mean node degree 2*K, and rewiring probability beta.
%
% beta = 0 is a ring lattice, and beta = 1 is a random graph.

% Connect each node to its K next and previous neighbors. This constructs
% indices for a ring lattice.
s = repelem((1:N)',1,K);
t = s + repmat(1:K,N,1);
t = mod(t-1,N)+1;
t = t - round(K/2);
t((t<=0))=t(t<=0)+N;
% compute number of exc neuron 80/20
Ne = floor((N * FracExc)/100);
Ni= N-Ne;
for i=1:4:Ne
 if t(i,1)>i
   t(i,:)=abs(t(i,:)+randi(floor(K/2),1)+randi(420,1)-i);
   idx=find(t(i,:)>=500);
   t(i,idx)=t(i,idx)-500;
 else
   %t(i,:)=abs(t(i,:)+randi([-i (500-K/2-i)],1));
   t(i,:)=abs(t(i,:)+randi([400-i floor(500-K/2-i)],1));
 end
end
if length(find(t(:)==0))>0
    t(find(t(:)==0))=randi(500,[length(find(t(:)==0)),1]);
end

% Rewire the target node of each EXCITATORY edge with probability beta
for source=1:Ne  
    switchEdge = rand(K, 1) < beta;
    
    newTargets = rand(N, 1);    %N -source
    newTargets(source) = 0;
    newTargets(s(t==source)) = 0;
    newTargets(t(source, ~switchEdge)) = 0;
    
    [~, ind] = sort(newTargets, 'descend');
    t(source, switchEdge) = ind(1:nnz(switchEdge));     %+ nulla +source
end
% Rewire the target node of each Inhibitory edge with probability beta    
% %Boschi Added
for source=Ne+1:Ni+Ne   
    switchEdge = rand(K, 1) <= 1;
    
    newTargets = rand(Ne, 1);
    newTargets(source) = 0;
    newTargets(s(t==source)) = 0;
    newTargets(t(source, ~switchEdge)) = 0;
    
    [~, ind] = sort(newTargets, 'descend');
    t(source, switchEdge) = ind(1:nnz(switchEdge));
end

h = digraph(s,t);  %digraph

end