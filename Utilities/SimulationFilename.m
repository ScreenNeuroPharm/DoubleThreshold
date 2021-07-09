function SimFilename = SimulationFilename()
% To assign a filename to a simulation
c = clock;
SimFilename = ['Simulation_',date,'_',num2str(c(4)),num2str(c(5)),'.mat'];

