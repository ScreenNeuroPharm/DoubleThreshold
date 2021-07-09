function [delays, post] = DelayPostConnection(ConnRule, NumNeur, FracExc, Dexc, Dinh, M, Net_SF,Net_M)
%
% This function assignes the synaptic delay to excitatory and inhibitory
% connections. It works for RND and SF networks
%
%                 Paolo Massobrio - last update 2nd March 2018
%
Ne = floor((NumNeur * FracExc)/100);

if strcmp(ConnRule,'RND')
    % Take special care not to have multiple connections between neurons
    delays = cell(NumNeur,Dexc);
    
for i = 1:Ne
    p = randperm(NumNeur);
    post(i,:) = p(1:M);
    for j = 1:M
        delays{i, ceil(Dexc*rand)}(end+1) = j;  % Assign random exc delays
    end
end

for i = Ne+1:NumNeur
    p = randperm(Ne);
    post(i,:) = p(1:M);
    delays{i,Dinh} = 1:M;                    % all inh delays are 1 ms.
end
elseif strcmp(ConnRule,'SF')
    Net_SF = cell2mat(varargin);
    [post, delays] = PostSynDel_SF(NumNeur, Dexc, Dinh, M, FracExc, Net_SF);

elseif strcmp(ConnRule,'SW')

    Net_SF = cell2mat(varargin);
    [post, delays] = PostSynDel_SW(NumNeur, Dexc, Dinh, M, FracExc, Net_SF,0.5);
    elseif strcmp(ConnRule,'MOD')


    [post, delays] = PostSynDel_MOD(NumNeur, Dexc, Dinh, M, FracExc, Net_SF,0.5,Net_M);
end






