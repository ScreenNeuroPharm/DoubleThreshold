function [Net_MOD, NumMaxSynPerNeuron, NumSynPerNeuron, PercBidirConn,Net_SW] = MODdirMatrix(NumNeur,numMOD,K,FracExc,beta1,beta2,NNM)


% 
% % --------------create MOD matrix ------------------------------------------
Ne = floor((NumNeur * FracExc)/100);
Ni= NumNeur-Ne;
kmod=round(K/numMOD);
NumNeurMOD=floor(NumNeur/numMOD);
Net=zeros(NNM,NNM,numMOD);
Net_SW=zeros(NumNeur);
Net_MOD=zeros(NumNeur);
difNN=NumNeurMOD-NNM;
for i=0:numMOD-1
    G_SW = WattsStrogatz(NNM,kmod,beta1);
    Net(:,:,i+1) = full(adjacency(G_SW));
    Net_SW(i*(NNM+difNN)+1:NNM+i*(NNM+difNN),i*(NNM+difNN)+80+1:NNM+i*(NNM+difNN)+80)=Net(:,:,i+1);
end  

% FullMat=rand(400,100);
% FullMat(FullMat>0.12)=0;
% FullMat(FullMat<0.12 & FullMat>0)=1;
% Net_SW(1:400,401:end)=FullMat;
%Rewire the target node of each edge with probability beta
R=rand(NumNeur);
for i=1:NumNeur
    for j=1:NumNeur
        if Net_SW(i,j)
            if R(i,j)< beta2 
                Net_MOD(i,randi(500,1,1))=Net_SW(i,j);
            else
                Net_MOD(i,j)=Net_SW(i,j);
            end
        end
    end 
end
FullMat=WattsStrogatz(500,5,1);
FullMat = full(adjacency(FullMat));
for i=1:500
    if Net_MOD(i,:)==0
        Net_MOD(i,:)=FullMat(i,:);
    end
end
Net_MOD(401:end,401:end)=0;



%% computing small-world-ness using the analytical approximations for the E-R graph
%  n = size(Net_SW,1);  % number of nodes
%  m = sum(sum(Net_SW)); %number of edges directed network
%  [Lrand,CrandWS] = NullModel_L_C(n,m,100,1);
%  [SW,Ccoeff,PL] = small_world_ness2(Net_SW,Lrand,CrandWS,1);
%  parameters=[Ccoeff, PL,SW];
%  fprintf("SWI=%f\n",SW);
%% ---------------------------------------------------------------------------


BidirConn = Net_SW .* Net_SW';
[r,c]= find(Net_SW == 1);
Conn = length(r);
[r,c] = find(BidirConn==1);
BidirConn2 =[r c];
NumBidirCon = size(BidirConn2,1)/2;
PercBidirConn = NumBidirCon/Conn * 100;
             

imagesc(Net_MOD)
% -------------------------------------------------------------------------
NumSynPerNeuron = [];
for j = 1:size(Net_SW,1)
    syn_temp = length(find(Net_SW(j,:)==1));% number of synapses per neuron
    NumSynPerNeuron = [NumSynPerNeuron;syn_temp];
end
NumMaxSynPerNeuron = max(NumSynPerNeuron);


