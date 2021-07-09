function[h, FitParameters] = DistribDegreeExcInh(AdjacencyMatrix, ConnRule)
% This function plots the degree distribution of a generic graph. The input
% is the directed adjacency matrix (binary or weigthed). The last version
% of this script plots the global distribution as well as distinguishing
% between excitatory and inhibitory connections.
% 
%               Paolo Massobrio last update 26th April 2016
% 



Net = double(logical(AdjacencyMatrix)); 

connections = single(sum(Net));                     % Number of connections per node
connections_exc = single(sum(AdjacencyMatrix > 0)); % Number of connections per node
connections_inh = single(sum(AdjacencyMatrix < 0)); % Number of connections per node

frequency = single(zeros(1,length(Net)));                     % how many nodes have each degree
frequency_exc = single(zeros(1,length(AdjacencyMatrix > 0))); % how many nodes have each degree
frequency_inh = single(zeros(1,length(AdjacencyMatrix < 0))); % how many nodes have each degree

plotvariables = zeros(2,length(Net));                     % variable to plot
plotvariables_exc = zeros(2,length(AdjacencyMatrix > 0)); % variable to plot
plotvariables_inh = zeros(2,length(AdjacencyMatrix < 0)); % variable to plot

P = [];
P_exc = [];
P_inh = [];

for T = 1:length(Net)
    % Variable will be used as a list of possible degrees that a node can have
    P(1,T) = T;
    P_exc(1,T) = T;
    P_inh(1,T) = T;

    if connections(1,T) ~= 0
        frequency(1,connections(1,T)) = frequency(1,connections(1,T)) + 1;
    end
    
   if connections_exc(1,T) ~= 0
        frequency_exc(1,connections_exc(1,T)) = frequency_exc(1,connections_exc(1,T)) + 1;
   end
    
    if connections_inh(1,T) ~= 0
        frequency_inh(1,connections_inh(1,T)) = frequency_inh(1,connections_inh(1,T)) + 1;
    end
end

for c = 1:length(frequency)
    % Disregard degrees with no frequency
    if frequency(1,c) ~= 0
        [X,Y] = find(plotvariables == 0);
        plotvariables(1,min(Y)) = P(1,c);
        plotvariables(2,min(Y)) = frequency(1,c);
    end
        clear X Y
end
%
for c = 1:length(frequency_exc)
    % Disregard degrees with no frequency
    if frequency_exc(1,c) ~= 0
        [X,Y] = find(plotvariables_exc == 0);
        plotvariables_exc(1,min(Y)) = P_exc(1,c);
        plotvariables_exc(2,min(Y)) = frequency_exc(1,c);
    end
    clear X Y
end
%
for c = 1:length(frequency_inh)
    % Disregard degrees with no frequency
    if frequency_inh(1,c) ~= 0
        [X,Y] = find(plotvariables_inh == 0);
        plotvariables_inh(1,min(Y)) = P_inh(1,c);
        plotvariables_inh(2,min(Y)) = frequency_inh(1,c);
    end
        clear X Y
end
% Find the last non-zero element in plotvariables
for d = 1:length(plotvariables)
    if plotvariables(1,d) == 0 && plotvariables(2,d) == 0
        break
    end
end
x = plotvariables(1,1:d-1); % only non-zero elements are stored and plotted (degree)
y = plotvariables(2,1:d-1); % only non-zero elements are stored and plotted (frequency)
%
for d = 1:length(plotvariables_exc)
    if plotvariables_exc(1,d) == 0 && plotvariables_exc(2,d) == 0
        break
    end
end
x_exc = plotvariables_exc(1,1:d-1); % only non-zero elements are stored and plotted (degree)
y_exc = plotvariables_exc(2,1:d-1); % only non-zero elements are stored and plotted (frequency)
%
for d = 1:length(plotvariables_inh)
    if plotvariables_inh(1,d) == 0 && plotvariables_inh(2,d) == 0
        break
    end
end
x_inh = plotvariables_inh(1,1:d-1); % only non-zero elements are stored and plotted (degree)
y_inh = plotvariables_inh(2,1:d-1); % only non-zero elements are stored and plotted (frequency)

%%
if strcmp(ConnRule, 'RND')
    % ------- Gaussian Fit ------
    [g,f,b] = fit(x',y','gauss1');  %y = a1*exp(-((x-b1)/c1)^2)
    [g_exc,f_exc,b_exc] = fit(x_exc',y_exc','gauss1');  %y = a1*exp(-((x-b1)/c1)^2)
    [g_inh,f_inh,b_inh] = fit(x_inh',y_inh','gauss1');  %y = a1*exp(-((x-b1)/c1)^2)
    % 
    a = g.a1; coeff = num2str(a);
    b = g.b1; num = num2str(b);
    c = g.c1; den = num2str(c);
    rsquare = f.rsquare;
    equation = g;
    FitParameters = [a;b;c;rsquare];
    % 
    a_exc = g_exc.a1; coeff_exc = num2str(a_exc);
    b_exc = g_exc.b1; num_exc = num2str(b_exc);
    c_exc = g_exc.c1; den_exc = num2str(c_exc);
    rsquare_exc = f_exc.rsquare;
    equation_exc = g_exc;
    FitParameters_exc = [a_exc;b_exc;c_exc;rsquare_exc];
    %
    a_inh = g_inh.a1; coeff_inh = num2str(a_inh);
    b_inh = g_inh.b1; num_inh = num2str(b_inh);
    c_inh = g_inh.c1; den_inh = num2str(c_inh);
    rsquare_inh = f_inh.rsquare;
    equation_inh = g_inh;
    FitParameters_inh = [a_inh;b_inh;c_inh;rsquare_inh];

    % all the distribution plotted together
    h = figure();
    hold on;
    plot(x,y,'k*');             % all connections
    plot(x_exc,y_exc,'r*');     % exc connections
    plot(x_inh,y_inh,'b*');     % inh connections

    plot(g,'k');
    plot(g_exc,'r');
    plot(g_inh,'b');

    xlim([0 max(sum(Net))+10]);
    ylim([0 (max(y_inh)+10)]);

    legend off;
    leg1 = 'all links';
    leg2 = 'exc links';
    leg3 = 'inh links';
    leg4 = 'Gauss fit';
    leg5 = 'Gauss fit';
    leg6 = 'Gauss fit';

    % leg2 = 'Gauss fit';
    legend(leg1, leg2,leg3,leg4,leg5,leg6,'FontSize',8,'FontName','arial');
    legend('boxoff');
    string = ['R^2=',num2str(rsquare)];
    text(max(sum(Net))-10,max(y)/2, string(1:end-2));

    string_exc = ['R^2=',num2str(rsquare_exc)];
    text(max(sum(Net>0))-85,max(y)/2, string_exc(1:end-2));

    string_inh = ['R^2=',num2str(rsquare_inh)];
    text(max(sum(Net<0))+10, max(y)/2, string_inh(1:end-2));
    xlabel('Degrees','FontSize',12,'FontName','arial');
    ylabel('Frequency','FontSize',12,'FontName','arial');
    axis('square');
    %%
elseif strcmp(ConnRule, 'SF')
%     all
    equation = zeros(1,2);
    xlog = log10(x);
    ylog = log10(y);
    [fit_data S] = polyfit(xlog', ylog', 1); % Y =mx+q
    m = fit_data(1); m_txt = num2str(m); q = fit_data(2);
    equation(1) = m; equation(2) = q;
    plotFittedData = 10^q.*x.^m;
%     exc
    equation_exc = zeros(1,2);
    xlog_exc = log10(x_exc);
    ylog_exc = log10(y_exc);
    [fit_data_exc S_exc] = polyfit(xlog_exc', ylog_exc', 1); % Y =mx+q
    m_exc = fit_data_exc(1); m_txt_exc = num2str(m_exc); q_exc = fit_data_exc(2);
    equation_exc(1) = m_exc; equation_exc(2) = q_exc;
    plotFittedData_exc = 10^q_exc.*x_exc.^m_exc;
%  inh
    equation_inh = zeros(1,2);
    xlog_inh = log10(x_inh);
    ylog_inh = log10(y_inh);
    [fit_data_inh S_inh] = polyfit(xlog_inh', ylog_inh', 1); % Y =mx+q
    m_inh = fit_data_inh(1); m_txt_inh = num2str(m_inh); q_inh = fit_data_inh(2);
    equation_inh(1) = m_inh; equation_inh(2) = q_inh;
    plotFittedData_inh = 10^q_inh.*x_inh.^m_inh;

    % Plot in a Log-Log plane
    h = figure();
    loglog(x,y,'k*');
    hold on;
    loglog(x,plotFittedData,'k');
    
    loglog(x_exc,y_exc,'r*');
    hold on;
    loglog(x_exc,plotFittedData_exc,'r');
  
    loglog(x_inh,y_inh,'b*');
    hold on;
    loglog(x_inh,plotFittedData_inh,'b');
 
    leg1 = 'Data';
    leg2 = strcat('slope=',m_txt);
    leg1_exc = 'Data exc';
    leg2_exc = strcat('slope exc=',m_txt_exc);
    leg1_inh = 'Data inh';
    leg2_inh = strcat('slope inh=',m_txt_inh);
   
    legend(leg1, leg2, leg1_exc, leg2_exc, leg1_inh, leg2_inh,'FontSize',8,'FontName','arial');
    legend('boxoff');
    xlim([0.9 (max(sum(Net)) + 10)]);
    ylim([0.9 length(Net)]);
    xlabel('Degrees','FontSize',12,'FontName','arial');
    ylabel('Frequency','FontSize',12,'FontName','arial');
    axis('square');
    FitParameters = [m;q];
    FitParameters_exc = [m_exc;q_exc];
    FitParameters_inh = [m_inh;q_inh];  
end


% plot(g,'b');
% xlim([min(sum(Net))-10 max(sum(Net))+10]);
% ylim([0 (max(y)+10)]);

% legend off;
% leg1 = 'Data';
% leg2 = 'Gauss fit';
% legend(leg1, leg2,'FontSize',8,'FontName','arial');
% legend('boxoff');
% string = ['R^2=',num2str(rsquare)];
% text(max(sum(Net))-10,max(y)/2, string(1:end-2));
% 
% xlabel('Degrees','FontSize',12,'FontName','arial');
% ylabel('Frequency','FontSize',12,'FontName','arial');
% axis('square');
Distrib_All = [x', y'];
Distrib_exc = [x_exc', y_exc'];
Distrib_inh = [x_inh', y_inh'];

save('Degree_Distrib_Fit.mat','FitParameters','FitParameters_exc','FitParameters_inh','Distrib_All','Distrib_exc','Distrib_inh','-mat');

saveas(h,'DegreeDistribution.fig','fig');
saveas(h,'DegreeDistribution.jpg','jpg');
