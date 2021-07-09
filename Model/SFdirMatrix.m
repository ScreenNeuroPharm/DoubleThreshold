function [Net_SF, NumMaxSynPerNeuron, NumSynPerNeuron, PercBidirConn] = SFdirMatrix(NumNeur, NumMinConn)
% This function generates a directed not symmetric SF matrix from the
% Albert-Barabasi algorithm
% 
%                   Paolo Massobrio - last update 24th April 2018


% NumMinConn = 20;
PercLinksToDeleteUp = 25;
PercLinksToDeleteLow = 10;
PercLinksToDeleteUp_orig = 0;
PercLinksToDeleteLow_orig = 0;

FractLinksToDeleteUp = PercLinksToDeleteUp / 100;
FractLinksToDeleteLow = PercLinksToDeleteLow / 100;
FractLinksToDeleteUp_orig = PercLinksToDeleteUp_orig / 100;
FractLinksToDeleteLow_orig = PercLinksToDeleteLow_orig / 100;

% -------------------------------------------------------------------------
SF_net_sym = ScaleFreeAlgo2(NumNeur,NumMinConn);

[DegreeStatistics_sym] = DegreeStat(SF_net_sym);
Degree_sym_IN_TOT = sum(DegreeStatistics_sym.Degree_IN);
Degree_sym_OUT_TOT = sum(DegreeStatistics_sym.Degree_OUT);
NumLinksToDeleteUP = floor(FractLinksToDeleteUp * Degree_sym_IN_TOT);
NumLinksToDeleteLOW = floor(FractLinksToDeleteLow * Degree_sym_OUT_TOT);
NumLinksToDeleteUP_orig = floor(FractLinksToDeleteUp_orig * Degree_sym_IN_TOT);
NumLinksToDeleteLOW_orig = floor(FractLinksToDeleteLow_orig * Degree_sym_OUT_TOT);

%--------delete connection TRIUP ORIG--------------
TriUp_orig = triu(SF_net_sym);
[r_up,c_up] = find (TriUp_orig);
nodes_up = [r_up,c_up];
maskUp = ones(length(nodes_up), 1);
maskUp(randperm(numel(maskUp), NumLinksToDeleteUP_orig)) = 0;
DeleteConnUp = find(maskUp == 0);
r = nodes_up(DeleteConnUp,1);
c = nodes_up(DeleteConnUp,2);
IndexToDeleteUp = [r,c];
for i = 1 : length(IndexToDeleteUp)
    TriUp_orig(IndexToDeleteUp(i,1),IndexToDeleteUp(i,2)) = 0;
end

%----------delete connection TRIUP-----------------
TriUp = triu(SF_net_sym);
[r_up,c_up] = find (TriUp);
nodes_up = [r_up,c_up];
maskUp = ones(length(nodes_up), 1);
maskUp(randperm(numel(maskUp), NumLinksToDeleteUP)) = 0;
DeleteConnUp = find(maskUp == 0);
r = nodes_up(DeleteConnUp,1);
c = nodes_up(DeleteConnUp,2);
IndexToDeleteUp = [r,c];
for i = 1 : length(IndexToDeleteUp)
    TriUp(IndexToDeleteUp(i,1),IndexToDeleteUp(i,2)) = 0;
end
%----------------------delete connection TRILOW orig------------
TriLow_orig = tril(SF_net_sym);
[r_low,c_low] = find (TriLow_orig);
nodes_low = [r_low,c_low];
maskLow = ones(length(nodes_low), 1);
maskLow(randperm(numel(maskLow), NumLinksToDeleteLOW_orig)) = 0;
DeleteConnLow = find(maskLow == 0);
c = nodes_up(DeleteConnLow,1);
r = nodes_up(DeleteConnLow,2);
IndexToDeleteLow = [r,c];
for i = 1 : length(IndexToDeleteLow)
    TriLow_orig(IndexToDeleteLow(i,1),IndexToDeleteLow(i,2)) = 0;
end
%----------------------delete connection TRILOW-------------------------
TriLow = tril(SF_net_sym);
[r_low,c_low] = find (TriLow);
nodes_low = [r_low,c_low];
maskLow = ones(length(nodes_low), 1);
maskLow(randperm(numel(maskLow), NumLinksToDeleteLOW)) = 0;
DeleteConnLow = find(maskLow == 0);
c = nodes_up(DeleteConnLow,1);
r = nodes_up(DeleteConnLow,2);
IndexToDeleteLow = [r,c];
for i = 1 : length(IndexToDeleteLow)
    TriLow(IndexToDeleteLow(i,1),IndexToDeleteLow(i,2)) = 0;
end

Net_SF = TriUp_orig+TriLow_orig;
%-------------------------------------------------------------------------
A=triu(ScaleFreeAlgo2(500,NumMinConn));
for i=1:500
    A(i,:)=Shuffle(A(i,:));
end
Net_SF(:,NumNeur*80/100:end)=Net_SF(:,NumNeur*80/100:end)+A(:,NumNeur*80/100:end);
%--------------------------------------------------------------------------
for i=1:100
    TriUp(i,1:400)=Shuffle(TriUp(i,1:400));
end
Net_SF(401:end,:)=Net_SF(401:end,:)+TriUp(1:100,:);
Net_SF(NumNeur*80/100:end,NumNeur*80/100:end)=0;
%--------------------------------------------------------------------------
for i=1:400
    Net_SF(i,1:400)=Shuffle(Net_SF(i,1:400));
end
%--------------------------------------------------------------------------
Net_SF = weight_conversion(Net_SF,'binarize');
imagesc(Net_SF)
BidirConn = Net_SF .* Net_SF';
[r,c]= find(Net_SF == 1);
Conn = length(r);
[r,c] = find(BidirConn==1);
BidirConn2 =[r c];
NumBidirCon = size(BidirConn2,1)/2;
PercBidirConn = NumBidirCon/Conn * 100;
             


% -------------------------------------------------------------------------
NumSynPerNeuron = [];
for j = 1:size(Net_SF,1)
    syn_temp = length(find(Net_SF(j,:)==1));% number of synapses per neuron
    NumSynPerNeuron = [NumSynPerNeuron;syn_temp];
end
NumMaxSynPerNeuron = max(NumSynPerNeuron);


