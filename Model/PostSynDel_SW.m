function [post, delays] = PostSynDel_SW(NumNeur, Dexc, Dinh, NumMaxSynPerNeuron, FracExc, Net_SW,beta)
% Function that assignes synaptic delays in a SF network.
% 
%                   Paolo Massobrio - last update 24th April 2018
% 

delays = cell(NumNeur,Dexc);
post = zeros(NumNeur,NumMaxSynPerNeuron);
for i = 1:NumNeur
    postneur = find(Net_SW(i,:));
    temp = find(Net_SW(i,:));
    post(i,1:size(temp,2))= temp;
end


Ne = floor((NumNeur * FracExc)/100);
MaxConnSW= round(NumMaxSynPerNeuron.*beta);

for i = 1:Ne
%     p = randperm(NumNeur);
%     post(i,:) = p(1:NumMaxSynPerNeuron);
        stopcycle = find(post(i,:) == 0,1) - 1;
        if isempty(stopcycle)
           stopcycle =  NumMaxSynPerNeuron;
        end
    for j = 1: stopcycle       %NumMaxSynPerNeuron
%         if abs(post(i,j)-i)< MaxConnSW
%              delays{i, ceil(10*rand)+1}(end+1) = j;  % Assign random exc delays
%         else    
             delays{i, ceil(Dexc*rand)}(end+1) = j;  % Assign random exc delays
%        end
    end
end

for i = Ne+1:NumNeur
%     p = randperm(Ne);
%     post(i,:) = p(1:NumMaxSynPerNeuron);
    delays{i,Dinh} = 1:NumMaxSynPerNeuron;      % all inh delays are 1 ms.
end
