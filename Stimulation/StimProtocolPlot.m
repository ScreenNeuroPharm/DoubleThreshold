function [s] = StimProtocolPlot(fs, SimulDurSample, StimProtocol, IstimAmpl)
% This function draws the implemented stimulation protocol.
% 
%            Paolo Massobrio - last update 20th October 2016
% 
% 
s = figure();
plot((1:1:SimulDurSample)/fs,StimProtocol);
xlabel('time (s)','FontSize',14,'FontName','arial');
ylabel('I_s_t_i_m (nA)','FontSize',14,'FontName','arial');
axis([0 SimulDurSample(end)/fs min(StimProtocol) - 0.5 IstimAmpl + 0.5]) ;
axis square

