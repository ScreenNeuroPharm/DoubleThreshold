function[h, FitParameters] = DistribDegree(AdjacencyMatrix)
% This function plots the degree distribution of a generic graph. The input
% is the directed adjacency matrix (binary or weigthed).
% 
%               Paolo Massobrio last update 27th January 2016
% 

Net = double(logical(AdjacencyMatrix)); 

connections = single(sum(Net)); % Number of connections per node
frequency = single(zeros(1,length(Net))); % how many nodes have each degree

plotvariables = zeros(2,length(Net)); % variable to plot
P = [];

for T = 1:length(Net)
    % Variable will be used as a list of possible degrees that a node can have
    P(1,T) = T;
    if connections(1,T) ~= 0
        frequency(1,connections(1,T)) = frequency(1,connections(1,T)) + 1;
    end
end

for c = 1:length(frequency)
    % Disregard degrees with no frequency
    if frequency(1,c) ~= 0
        [X,Y] = find(plotvariables == 0);
        plotvariables(1,min(Y)) = P(1,c);
        plotvariables(2,min(Y)) = frequency(1,c);
    end
end

% Find the last non-zero element in plotvariables
for d = 1:length(plotvariables)
    if plotvariables(1,d) == 0 && plotvariables(2,d) == 0
        break
    end
end

x = plotvariables(1,1:d-1); % only non-zero elements are stored and plotted (degree)
y = plotvariables(2,1:d-1); % only non-zero elements are stored and plotted (frequency)

% ------- Gaussian Fit ------
[g,f,b] = fit(x',y','poly1');  %y = a1*exp(-((x-b1)/c1)^2)
a = g.a1; coeff = num2str(a);
b = g.b1; num = num2str(b);
c = g.c1; den = num2str(c);
rsquare = f.rsquare;
equation = g;
FitParameters = [a;b;c;rsquare];

h = figure();
hold on;
plot(x,y,'r*');
plot(g,'b');
xlim([min(sum(Net))-10 max(sum(Net))+10]);
ylim([0 (max(y)+10)]);
legend off;
leg1 = 'Data';
leg2 = 'Gauss fit';
legend(leg1, leg2,'FontSize',8,'FontName','arial');
legend('boxoff');
string = ['R^2=',num2str(rsquare)];
text(max(sum(Net))-10,max(y)/2, string(1:end-2));

xlabel('Degrees','FontSize',12,'FontName','arial');
ylabel('Frequency','FontSize',12,'FontName','arial');
axis('square');

save('Degree_Distrib_Fit.mat','FitParameters','-mat');
saveas(h,'DegreeDistribution.fig','fig');
saveas(h,'DegreeDistribution.jpg','jpg');
