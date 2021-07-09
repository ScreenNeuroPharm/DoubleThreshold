cdata = [0 3 3 0; 6 0 4 2; 5 3 0 2; 0 2 3 0];
xvalues = {'A','B','C','D'};
yvalues =  {'A','B','C','D'};
Color = [0 0 1;0 0 1; 0 0 1;0 0 1;1 0 0];

h = heatmap(xvalues,yvalues,cdata,'ColorMap',Color);
h.ColorbarVisible='off';
h.Title = 'Rejected Connectivity Matrix';
h.XLabel = 'Pre-Synaptic Neuron';
h.YLabel =   'Post-Synaptic Neuron';
