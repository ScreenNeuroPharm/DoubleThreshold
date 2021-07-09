function [syn] = SynMatrix(AdjacencyMatrix, post, delays, D)
syn = [];
for i = 1 : size(AdjacencyMatrix,1)
    for j = 1: size(AdjacencyMatrix,2)
        if AdjacencyMatrix(i,j) ~= 0
            conn = find(post(i,:)==j);
            for k = 1:D
                flag = find(delays{i,k} == conn);
                if flag
                    del = k;
                    syn = [syn; i, j, AdjacencyMatrix(i,j), del];
                end
            end
        end
    end
end
