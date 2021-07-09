function [Net_SW, NumMaxSynPerNeuron, NumSynPerNeuron, PercBidirConn,parameters] = SWdirMatrix(NumNeur,K,beta)
% This function generates a directed not symmetric SW matrix from the
% Albert-Barabasi algorithm
% 
%                   

% 
% % --------------create SW matrix ------------------------------------------
G_SW = WattsStrogatz_Boschi(NumNeur,K,beta,80);
Net_SW = full(adjacency(G_SW));



%% computing small-world-ness using the analytical approximations for the E-R graph
 n = size(Net_SW,1);  % number of nodes
 m = sum(sum(Net_SW)); %number of edges directed network
 [Lrand,CrandWS] = NullModel_L_C(n,m,100,1);
 [SW,Ccoeff,PL] = small_world_ness2(Net_SW,Lrand,CrandWS,1);
 parameters=[Ccoeff, PL,SW];
 fprintf("SWI=%f\n",SW);
%% ---------------------------------------------------------------------------


BidirConn = Net_SW .* Net_SW';
[r,c]= find(Net_SW == 1);
Conn = length(r);
[r,c] = find(BidirConn==1);
BidirConn2 =[r c];
NumBidirCon = size(BidirConn2,1)/2;
PercBidirConn = NumBidirCon/Conn * 100;
             


% -------------------------------------------------------------------------
NumSynPerNeuron = [];
for j = 1:size(Net_SW,1)
    syn_temp = length(find(Net_SW(j,:)==1));% number of synapses per neuron
    NumSynPerNeuron = [NumSynPerNeuron;syn_temp];
end
NumMaxSynPerNeuron = max(NumSynPerNeuron);


