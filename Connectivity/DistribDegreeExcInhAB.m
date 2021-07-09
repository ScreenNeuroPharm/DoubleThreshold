function[h, FitParameters] = DistribDegreeExcInhAB(varargin)
% This function plots the degree distribution of a generic graph. The input
% is the directed adjacency matrix (binary or weigthed). The last version
% of this script plots the global distribution as well as distinguishing
% between excitatory and inhibitory connections.
% DistribDegreeExcInhAB(Net, ConnRule,Y_struct,plotFittedData_struct)
%               Paolo Massobrio last update 3rd May 2018
%               
Net=cell2mat(varargin(1));
ConnRule=cell2mat(varargin(2));

[M1,M2,M3]=size(Net);
Net(Net>0)=1;
Net(Net<0)=-1;
Net_pos=zeros(M1,M2,M3);
Net_neg=zeros(M1,M2,M3);
Net_pos(Net>0)=Net(Net>0);
Net_neg(Net<0)=Net(Net<0);
if strcmp(ConnRule,'RND')
    [connections,~,~] = degrees_dir(Net);         % Number of connections per node
    [connections_exc,~,~] = degrees_dir(Net_pos); % Number of connections per node
    [connections_inh,~,~] = degrees_dir(Net_neg); % Number of connections per node
else
    
    [~,connections,~] = degrees_dir(Net);         % Number of connections per node
    [~,connections_exc,~] = degrees_dir(Net_pos); % Number of connections per node
    [~,connections_inh,~] = degrees_dir(Net_neg); % Number of connections per node
end

edges=0.5:1:500;
x_e=[];
y_e=[];
x_i=[];
y_i=[];
X=[];
Y=[];
for k=1:M3
    [x,y]=histcounts(connections(:,k),edges);             % how many nodes have each degree
    [x_exc,y_exc]=histcounts(connections_exc(:,k),edges); % how many nodes have each degree
    [x_inh,y_inh]=histcounts(connections_inh(:,k),edges); % how many nodes have each degree
    
    X=[X x(2:end)];
    Y=[Y y(2:end)];
    x_e=[x_e x_exc];
    y_e=[y_e y_exc(2:end)];
    x_i=[x_i x_inh];
    y_i=[y_i y_inh(2:end)];
end


idx=X>0;
X=X(idx);
Y=Y(idx);
idx=x_e>0;
x_e=x_e(idx);
y_e=y_e(idx);
idx=x_i>0;
x_i=x_i(idx);
y_i=y_i(idx);

if strcmp(ConnRule,'SF')
idx=Y>mean(Y(find(X==max(X))))-40 & Y<200; 
X=X(idx);
Y=Y(idx);
idx=y_e> 15 %mean(y_e(find(x_e==max(x_e))))-6 & y_e<200;    %mean(y_e(find(x_e==max(x_e))))-6
x_e=x_e(idx);
y_e=y_e(idx);
idx=y_i> 10 %mean(y_i(find(x_i==max(x_i)))) & y_i<200;
x_i=x_i(idx);
y_i=y_i(idx);
end




%%
if strcmp(ConnRule, 'RND') ||  strcmp(ConnRule, 'SW')
    % ------- Gaussian Fit ------
 
    x_exc=x_e;
    y_exc=y_e;
    x_inh=x_i;
    y_inh=y_i;
    
     X_exc=y_exc; X_inh=y_inh;
     y_exc=x_exc; y_inh=x_inh;
     x_exc=X_exc; x_inh=X_inh;
    options = fitoptions('gauss1', 'Upper', [1000 1000 1000]);
      [g,f,b] = fit(Y',X','gauss1',options);  %y = a1*exp(-((x-b1)/c1)^2)
    [g_exc,f_exc,b_exc] = fit(x_exc',y_exc','gauss1',options);  %y = a1*exp(-((x-b1)/c1)^2)
    options = fitoptions('gauss1', 'Upper', [1000 1000 1000]);
    [g_inh,f_inh,b_inh] = fit(x_inh',y_inh','gauss1',options);  %y = a1*exp(-((x-b1)/c1)^2)
    % 
%     a = g.a1; coeff = num2str(a);
%     b = g.b1; num = num2str(b);
%     c = g.c1; den = num2str(c);
%     rsquare = f.rsquare;
%     equation = g;
%     FitParameters = [rsquare,b];
    % 
    a_exc = g_exc.a1; coeff_exc = num2str(a_exc);
    b_exc = g_exc.b1; num_exc = num2str(b_exc);
    c_exc = g_exc.c1; den_exc = num2str(c_exc);
    rsquare_exc = f_exc.rsquare;
    equation_exc = g_exc;
    FitParameters_exc = [rsquare_exc,b_exc,c_exc];                   %[a_exc;b_exc;c_exc;rsquare_exc]
    %
    a_inh = g_inh.a1; coeff_inh = num2str(a_inh);
    b_inh = g_inh.b1; num_inh = num2str(b_inh);
    c_inh = g_inh.c1; den_inh = num2str(c_inh);
    rsquare_inh = f_inh.rsquare;
    equation_inh = g_inh;
    FitParameters_inh = [rsquare_inh,b_inh,c_inh];

    % all the distribution plotted together
    h = figure();
    hold on;
   % plot(Y,X,'k*');             % all connections
    plot(x_exc,y_exc,'r*');     % exc connections
    plot(x_inh,y_inh,'b*');     % inh connections

    %plot(g,'k');
    plot(g_exc,'r');
    plot(g_inh,'b');
    %plot(ones(60,1)*40,1:60,'k--','Linewidth',2);
    %xlim([0 max(sum(Net))+10]);
    %ylim([0 (max(y_inh)+10)]);

    legend off;
    leg1 = 'structural target';
    leg2 = 'Exc links';
    leg3 = 'Inh links';
    %leg4 = 'Gauss fit';
    leg5 = ' ExcGauss fit';
    leg6 = 'Inh Gauss fit';

%     % leg2 = 'Gauss fit';
    legend(leg2,leg3,leg5,leg6,leg1); %,'FontSize',8,'FontName','arial');
%     legend('boxoff');
    
%     string = ['R^2=',num2str(rsquare)];
%     text(max(sum(Net)),max(y)/2, string(1:end-2));

    string_exc = ['R^2=',num2str(rsquare_exc)];
    text(b_exc, max(y_exc)/2,string_exc(1:end-2),'Color','red');

    string_inh = ['R^2=',num2str(rsquare_inh)];
    text(b_inh, max(y_inh)/2, string_inh(1:end-2),'Color','blue');
   

    FitParameters =[ FitParameters_exc , FitParameters_inh ];
    
    xlabel('Degrees','FontSize',12,'FontName','arial');
    ylabel('Frequency','FontSize',12,'FontName','arial');
    %axis('square');
    %%
elseif strcmp(ConnRule, 'SF')
Y_struct=varargin(3);
plotFittedData_struct=varargin(4);

    equation = zeros(1,2);
    xlog = log10(Y);
    ylog = log10(X);
    [fit_data,G] = fit(xlog', ylog','poly1'); % Y =mx+q
    rsq=G.rsquare;
    m = fit_data.p1; m_txt = num2str(m); q = fit_data.p2;
    equation(1) = m; equation(2) = q;
    plotFittedData = 10^q.*Y.^m;

    equation_exc = zeros(1,2);
    xlog_exc = log10(y_e);
    ylog_exc = log10(x_e);
    [fit_data_exc,G_exc] = fit(xlog_exc', ylog_exc','poly1'); % Y =mx+q
    rsq_exc=G_exc.rsquare;
    m_exc = fit_data_exc.p1; m_txt_exc = num2str(m_exc); q_exc = fit_data_exc.p2;
    plotFittedData_exc = 10^q_exc.*y_exc.^m_exc;

    equation_inh = zeros(1,2);
    xlog_inh = log10(y_i);
    ylog_inh = log10(x_i);
   [fit_data_inh,G_inh] = fit(xlog_inh', ylog_inh','poly1'); % Y =mx+q
    rsq_inh=G_inh.rsquare;
    m_inh = fit_data_inh.p1; m_txt_inh = num2str(m_inh); q_inh = fit_data_inh.p2;
    plotFittedData_inh = 10^q_inh.*y_inh.^m_inh;

    % Plot in a Log-Log plane
    h = figure();
    loglog(Y,X,'k*');
    hold on;
    loglog(Y,plotFittedData,'k','LineWidth',2);
%    loglog(cell2mat(Y_struct),cell2mat(plotFittedData_struct),'r','LineWidth',2);
    
%     loglog(y_e,x_e,'r*');
%     hold on;
%     loglog(plotFittedData_exc,'r');
%   
%     loglog(y_i,x_i,'b*');
%     hold on;
%     loglog(plotFittedData_inh,'b');
%  
    leg1 = 'Data';
    leg2 = strcat('slope=',m_txt);
%     leg1_exc = 'Data exc';
%     leg2_exc = strcat('slope exc=',m_txt_exc);
%     leg1_inh = 'Data inh';
%     leg2_inh = strcat('slope inh=',m_txt_inh);
   
    %legend(leg1_exc, leg2_exc, leg1_inh, leg2_inh,'FontSize',8,'FontName','arial');
    legend(leg1, leg2); %,'FontSize',8,'FontName','arial');
    legend('boxoff');
    %xlim([0.9 (max(sum(Net)) + 10)]);
    ylim([0.9 length(Net)]);
    xlabel('Degrees','FontSize',12,'FontName','arial');
    ylabel('Frequency','FontSize',12,'FontName','arial');
    axis('square');
    FitParameters = [m,rsq];
    FitParameters_exc = [m_exc,rsq_exc];
    FitParameters_inh = [m_inh,rsq_inh];  
    FitParameters =[FitParameters, FitParameters_exc , FitParameters_inh ]
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

% Distrib_exc = [x_exc', y_exc'];
% Distrib_inh = [x_inh', y_inh'];

% save('Degree_Distrib_Fit.mat','FitParameters','FitParameters_exc','FitParameters_inh','Distrib_All','Distrib_exc','Distrib_inh','-mat');
% saveas(h,'DegreeDistribution.fig','fig');
% saveas(h,'DegreeDistribution.jpg','jpg');
