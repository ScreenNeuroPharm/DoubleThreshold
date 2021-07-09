function [AdjacencyMatrix, h] = AdjacencyMatrixEvaluation(post,s, ConnRule, varargin)

if strcmp(ConnRule, 'RND')
    AdjacencyMatrix = zeros(length(post),length(post));
    for i = 1:size(post,1)
        for j = 1:size(post,2)
            AdjacencyMatrix(i,post(i,j)) = s(i,j);
        end
    end
elseif strcmp(ConnRule, 'SF') ||  strcmp(ConnRule, 'SW') ||  strcmp(ConnRule, 'MOD')
    AdjacencyMatrix = cell2mat(varargin);
    for i = 1:size(AdjacencyMatrix,1)
        k = 0;
        for j = 1:size(AdjacencyMatrix,2)
            if AdjacencyMatrix(i,j) ~= 0
                k = k+1;
               AdjacencyMatrix(i,j) = AdjacencyMatrix(i,j) * s(i,k);
            end
        end
    end   
end


h = figure();
imagesc(AdjacencyMatrix)
axis square
xlabel('Presynaptic Neuron');
ylabel('Postsynaptic Neuron');
colorbar
drawnow