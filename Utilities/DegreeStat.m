function [DegreeStatistics] = DegreeStat(connMatrixTH)
%
% Script used to evauate the connection degree of each node. The input has
% to be a (thresholded) Connectivity Matrix.
%                             
% output: 
%         id            = indegree for all vertices
%         od            = outdegree for all vertices
%         deg           = degree for all vertices
%
% Computes the indegree, outdegree, and degree (indegree + outdegree) for a
% directed binary matrix.
%
% Olaf Sporns, Indiana University, 2002/2006
% =========================================================================

% ensure connMatrixTH is binary...
connMatrixTH = double(connMatrixTH~=0);

% compute degrees
INdegree  = sum(connMatrixTH,1);           % indegree = column sum of CIJ
OUTdegree = sum(connMatrixTH,2)';          % outdegree = row sum of CIJ
degree    = INdegree + OUTdegree;          % degree = indegree+outdegree

DegreeStatistics = struct('Degree_IN',INdegree,'Degree_OUT',OUTdegree,'Degree_All',degree);
