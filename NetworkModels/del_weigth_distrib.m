function [f1_exc, f1_inh, f2_exc, f2_inh] =  del_weigth_distrib(syn, w_E0, w_I0)

% -------------------------- synaptic delay -------------------------------
% --- excitation ----
bin_step_e = 2;
delay_exc = syn(1:max(find(syn(:,3)>0)),4);
bin_vector_e = [0:bin_step_e:max(syn(:,4))];
f1_exc = figure();
if ~isempty(delay_exc)
    hist(delay_exc,bin_vector_e);
    xlabel('synaptic delay (ms)','FontSize',14,'FontName','arial');
    ylabel('Frequency','FontSize',14,'FontName','arial');
    axis([-2 bin_vector_e(end)+2 0 9000]);
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor',[0.5 0.5 0.5]);
end
% --- inhibition ----
bin_step_i = 1;
delay_inh = syn((max(find(syn(:,3)>0)+1):end),4);
bin_vector_i = [0:bin_step_i:max(syn(:,4))];
f1_inh = figure();
if ~isempty(delay_inh)
    hist(delay_inh,bin_vector_i);
    xlabel('synaptic delay (ms)','FontSize',14,'FontName','arial');
    ylabel('Frequency','FontSize',14,'FontName','arial');
    axis([-2 bin_vector_i(end)+2 0 20000]);
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor',[0.5 0.5 0.5]);
end

% -------------------------- synaptic weigth ------------------------------
% --- excitation ----
bin_step_w = 0.2;
weigth_exc = syn(1:max(find(syn(:,3)>0)),3);
bin_vector_e = [0:bin_step_w:max(syn(:,3))];
f2_exc = figure();
if ~isempty(weigth_exc)
    hold on
    hist(weigth_exc,bin_vector_e);
    plot(w_E0*ones(1,2),[0,10000],'r-.','LineWidth',2);
    xlabel('synaptic weigth','FontSize',14,'FontName','arial');
    ylabel('Frequency','FontSize',14,'FontName','arial');
    axis([-1 bin_vector_e(end)+1 0 10000]);
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor',[0.5 0.5 0.5]);
end
% --- inhibition ----
bin_step_w = 0.2;
weigth_inh = syn(max(find(syn(:,3)>0))+1:end,3);
bin_vector_i = [floor(min(syn(:,3))):bin_step_w:0];
f2_inh = figure();
if ~isempty(weigth_inh)
    hold on
    hist(weigth_inh,bin_vector_i);
    plot(w_I0*ones(1,2),[0,4000],'r-.','LineWidth',2);
    xlabel('synaptic weigth','FontSize',14,'FontName','arial');
    ylabel('Frequency','FontSize',14,'FontName','arial');
    axis([-10 bin_vector_i(end)+1 0 2000]);
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor',[0.5 0.5 0.5]);
end



