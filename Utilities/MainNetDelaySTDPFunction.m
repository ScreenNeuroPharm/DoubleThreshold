function MainNetDelaySTDPFunction(varargin)
% spnet.m: Spiking network with axonal conduction delays and STDP
% Created by Eugene M.Izhikevich.                February 3, 2004
% Modified to allow arbitrary delay distributions.  April 16,2008
% Modified by Paolo Massobrio 26th April 2018
% -------------------------------------------------------------------------
    switch nargin
        case 2
            if ~isempty(strcmp(varargin{1},{'RND','SF','SW','MOD'}))
                ConnRule = varargin{1};
            else error('First Input must be a string among RND , SF , SW, MOD');
            end
        otherwise
             error('Too less input argument: %f.',nargin);
    end
close all
start_folder=pwd;
% -------------------------- Simulation Options ---------------------------
Stimulation = 0;                % if 1, a current pulse is delivered to one or more neurons
NetAnalysis = 1;                % if 1, topological analysis is performed
TrialDurationDefinition = 0;    % if 1 spike detection and following analysis are computetd in a time window defined by the user (Tstart-Tstop)
SpikeAnalysis = 0;              % if 1, spiking statistics are computed
BurstAnalysis = 0;              % if 1, burst detection, as well as bursting statistics are computed
aVaAnalysis = 0;                % if 1, computation of the IEI as well as avalanches' size and distribution are computed
RawData = 0;                    % if 1, voltage traces will be computed and stored
% ----------------------- Simulation parameters ---------------------------

NumHours = 0.1667*1.5;      % long simulation (0.1667=10 min)
StopSTDP = 300;         %375 per SF, no stdp per SW
isSTDPstopped = 0;
InterSimDurSec = 1;     % temporal window (seconds) gives when syn weights are recomputed with stdp
fs = 1000;              % sampling frequency (Hz)
dt = (1/fs) * 1000;     % integration time step (ms)
rng('shuffle')
% ----------------------- Parameters definition ---------------------------
NumNeur = 500;
FracExc = 80;

M = varargin{2};                      % number of synapses per neuron
Dexc = 20;                   % maximal conduction delay (ms)
Dinh = 1;                    % inhibitory delay (fixed at 1 ms)
NumMinConn_SF = varargin{2};
RewiringProb = 0.35;
SynWeightDistrib = 'Normal'; % Possible choices: Const, Normal, Unif, LogNormal
%ConnRule = 'RND';

w_E0 = 7;              % initial exc weights (def. 6 per RND)             SF=7(8)     SW=7
StdExc = 1;              % initial std for exc weights (def. 1 per RND)
w_I0 = -5;               % initial inh weights (def. -5 per RND)            SF = -7(-7)    SW=-7
StdInh = 1;              % initial std for inh weights (def. 1 per RND)

tau_stdp = 20;           % time constant of the STDP rule (ms)
sm = 10;                 % maximal synaptic strength (def. 10 per RND)      SF = 10    SW=10

% ------------------ Noise background stimulation -------------------------
IstimExc_avg = 15;       % current amplitude mean (def 20, 11 per rnd) to stimulate a random-chosen neuron (one per each time-stamp) SF=13(16)  SW=18
IstimExc_std = 2;
IstimInh_avg = 12;     % current amplitude mean (def 20, 7 per rnd) to stimulate a random-chosen neuron (one per each time-stamp) SF = 9(16)    SW=14
IstimInh_std = 2;

save('Initialization_Variables.mat');

IstimDistribExc = [normrnd(IstimExc_avg, IstimExc_std,100,1)]';
IstimDistribInh = [normrnd(IstimInh_avg, IstimInh_std,100,1)]';

%% ------------------------- Electrical stimulation ------------------------
if Stimulation
    % ------------------- Stimulation parameters -------------
    NeuronId2Stimulate = [100:200];
    % ------------------------- TEST STIMULUS -----------------------------
    IstimAmpl = 100;
    StimDur_ms = 50;
    Period_ms = 5000;
    NumberOfCycles = 50;
    [StimProtocol, SimulDurSample] = TestStimulusProtocol(fs, IstimAmpl, StimDur_ms, Period_ms, NumberOfCycles, NumHours);
     % --------------------------------------------------------  
    if length(StimProtocol) > SimulDurSample
        StimProtocol = StimProtocol(1: SimulDurSample);
    else
        StimProtocol = [StimProtocol; zeros(SimulDurSample - length(StimProtocol),1)];
    end
    [s] = StimProtocolPlot(fs, SimulDurSample, StimProtocol, IstimAmpl);
%     s = figure();
%     plot((1:1:SimulDurSample)/fs,StimProtocol);
%     xlabel('time (s)','FontSize',14,'FontName','arial');
%     ylabel('I_s_t_i_m (nA)','FontSize',14,'FontName','arial');
%     axis([0 SimulDurSample(end)/fs 0 IstimAmpl + 0.5]) ;
%     axis square
    ElectrophysiologyFolder();
    stim_folder = 'StimulationProtocol';
    mkdir(stim_folder);
    cd(stim_folder);
    save('StimulationProtocol.mat','StimProtocol','NeuronId2Stimulate','-mat');
    saveas(s,'StimulationProtocol.fig');
    saveas(s,'StimulationProtocol.jpg');
    cd ..\..
    close (s);
    clear IstimAmpl NumberOf* Period* StimDur* StimProtocol_temp* stim_folder SimulDurSample s
end
%% -------------------------------------------------------------------------
Firings = [];            % this huge variable contains the spike stamps and the firing neurons
Vraw = [];               % in this variable the raw data of the neurons will be stored
pos = 1;                 % dummy variable for raw data

% excitatory neurons   % inhibitory neurons      % total number
Ne = floor((NumNeur * FracExc)/100);              Ni = NumNeur - Ne;
a = [0.02*ones(Ne,1);                             0.1*ones(Ni,1)];     %0.1
b = 0.2;
c = -65;
d = [8 * ones(Ne,1);                              2 * ones(Ni,1)];
%%
if strcmp(ConnRule, 'RND')
    % creation of the postsynaptic and synaptic delays matrices
    [delays, post] = DelayPostConnection(ConnRule, NumNeur, FracExc, Dexc, Dinh, M);
    % creation of a synaptic weigth matrix
    [s] = SynWeigthDistributions(SynWeightDistrib, M, NumNeur, FracExc, w_E0, StdExc, w_I0, StdInh);    % This function creates a (NumNeur x M) connectivity matrix
    sd = zeros(NumNeur,M);                      % their derivatives
    
elseif strcmp(ConnRule, 'MOD')
    [Net_SF, NumMaxSynPerNeuron, NumSynPerNeuron, PercBidirConn,Net_M] = MODdirMatrix(NumNeur,3,M,FracExc,0.9,0.3,80);
      [delays, post] = DelayPostConnection(ConnRule, NumNeur, FracExc, Dexc, Dinh, NumMaxSynPerNeuron, Net_SF,Net_M);
      [s] = SynWeigthDistributions(SynWeightDistrib, M, NumNeur, FracExc, w_E0, StdExc, w_I0, StdInh); 
      sd = zeros(NumNeur,M); 
elseif strcmp(ConnRule, 'SF')
    [Net_SF, NumMaxSynPerNeuron, NumSynPerNeuron, PercBidirConn] = SFdirMatrix(NumNeur, NumMinConn_SF);
    [delays, post] = DelayPostConnection(ConnRule, NumNeur, FracExc, Dexc, Dinh, NumMaxSynPerNeuron, Net_SF);
    [s] = SynWeigthSF(SynWeightDistrib, NumMaxSynPerNeuron, NumSynPerNeuron, NumNeur, FracExc, w_E0, StdExc, w_I0, StdInh);
    noSyn=find(s==0);
    trueSyn=find(s>0);
    sd = zeros(NumNeur,NumMaxSynPerNeuron);      % their derivatives
elseif strcmp(ConnRule, 'SW')
      [Net_SF, NumMaxSynPerNeuron, NumSynPerNeuron, PercBidirConn] = SWdirMatrix(NumNeur,M,RewiringProb);
      [delays, post] = DelayPostConnection(ConnRule, NumNeur, FracExc, Dexc, Dinh, NumMaxSynPerNeuron, Net_SF);
      [s] = SynWeigthDistributions(SynWeightDistrib, M, NumNeur, FracExc, w_E0, StdExc, w_I0, StdInh); 
      sd = zeros(NumNeur,NumMaxSynPerNeuron);      % their derivatives
end
%%
% Make links at postsynaptic targets to the presynaptic weights
pre = cell(NumNeur,1);
aux = cell(NumNeur,1);
for i=1:Ne
    for j=1:Dexc
        for k=1:length(delays{i,j})
            pre{post(i, delays{i, j}(k))}(end+1) = NumNeur*(delays{i, j}(k)-1)+i;
            aux{post(i, delays{i, j}(k))}(end+1) = NumNeur*(Dexc-1-j)+i; % takes into account delay
        end
    end
end

STDP = zeros(NumNeur,1001+Dexc);
v = -c * ones(NumNeur,1);               % initial values
u = b .* v;                             % initial values
firings=[-Dexc 0];                      % spike timings

for sec = 1 : 60*60*NumHours            % simulation of NumHours hours
    for t = 1:dt:1000*InterSimDurSec    % simulation of 1 sec
        I = zeros(NumNeur,1);
        % at each dt, a new value of Istim is extracted from a Gaussian distribution
        [IstimExc, IstimInh]  = Inoise(IstimDistribExc, IstimDistribInh);         % Paolo added
        Neuron2Stimulate = ceil(NumNeur * rand);
        
        if Neuron2Stimulate <= Ne
            I(Neuron2Stimulate) = IstimExc;    % random thalamic input for exc neurons
        else
            I(Neuron2Stimulate) = IstimInh;    % random thalamic input for inh neurons
        end
        
        if Stimulation                         % delivering the external current pulse to the selected neurons
            if t*sec <= length(StimProtocol)
                I(NeuronId2Stimulate) = StimProtocol(t*sec);
            end
        end
        
        fired = find(v >= 30);                 % indices of fired neurons
        v(fired) = c;
        u(fired) = u(fired) + d(fired);
        STDP(fired,t+Dexc) = 0.1;
        for k = 1 : length(fired)
            sd(pre{fired(k)}) = sd(pre{fired(k)}) + STDP(NumNeur*t+aux{fired(k)});     % 1 in origine
        end
        firings = [firings;t*ones(length(fired),1),fired];
        k = size(firings,1);
        while firings(k,1) > t-Dexc
            del = delays{firings(k,2),t-firings(k,1)+1};
            ind = post(firings(k,2),del);
            
            if strcmp(ConnRule,'SF')||strcmp(ConnRule,'MOD')                % Paolo 24th April 2018
              active_stim = length(find(ind > 0)); 
              ind_new = ind(1:active_stim);
              AdditiveStimTerm = s(firings(k,2), del)';
          
%               Add_stop = length(find(AdditiveStimTerm ~= 0));
%               AdditiveStimTerm = AdditiveStimTerm(1:Add_stop);
              I(ind_new) = I(ind_new) + AdditiveStimTerm(1:length(ind_new));
              
              if firings(k,2)<Ne
                 sd(firings(k,2),del) = sd(firings(k,2),del)-1.2*STDP(ind,t+Dexc)';  
              end
               STDPupdateOrig = 1.2*STDP(ind_new,t+Dexc)';
%               ZerosComp = zeros(1,NumMaxSynPerNeuron - length(STDPupdateOrig));
%               STDPupdate = [STDPupdateOrig, ZerosComp];
              deriv_weights = sd(firings(k,2),20); %del
              
%               if ~isempty(deriv_weights)
                  deriv_weights = deriv_weights - STDPupdateOrig;
              
%               end
              
            elseif strcmp(ConnRule,'RND') ||  strcmp(ConnRule,'SW')
              I(ind) = I(ind) + s(firings(k,2), del)';
              sd(firings(k,2),del) = sd(firings(k,2),del)-1.2*STDP(ind,t+Dexc)';   
            end         
            k = k-1;
        end
        % ------------------ Plotting the raw data ------------------------
%         if RawData
%             NeurIndex = [57, 86, 103, 531, 656, 790, 990];               % label of the neuron to plot its raw data (1-NumNeur)
%             Vraw(pos,:) = v(NeurIndex,1);
%         else
%             Vraw = 0;
%         end
        % -----------------------------------------------------------------
        v = v + 0.5 * ((0.04 * v + 5) .* v + 140 - u + I);      % for numerical
        v = v + 0.5 * ((0.04 * v + 5) .* v + 140 - u + I);      % stability time
        u = u + a .* (b * v - u);                               % step is 0.5 ms
        STDP(:,t + tau_stdp + 1) = 0.95*STDP(:,t + tau_stdp);   % tau = 20 ms
        pos = pos + 1;                                          % for raw data plotting
        %------------------------------------------------------------------
        if  (t == 1 && sec == 1)   % saving initial conditions of the net
            if strcmp(ConnRule, 'SF') || strcmp(ConnRule,'SW') || strcmp(ConnRule,'MOD')
                [AdjacencyMatrix_0,f0] = AdjacencyMatrixEvaluation(post,s,ConnRule, Net_SF); % square matrix (not really adj, since not symm)
                %[h, FitParameters] = DistribDegreeExcInhAB(AdjacencyMatrix_0,ConnRule);
            else
               [AdjacencyMatrix_0,f0] = AdjacencyMatrixEvaluation(post,s,ConnRule); % square matrix (not really adj, since not symm)
            end
                [syn_0] = SynMatrix(AdjacencyMatrix_0, post, delays, Dexc);    % syn = [pre|post|w|del]
                
            
            filename = ['ConnectivityMatrix_',num2str(sec),'_sec.mat'];
            filename0 = ['AdjacencyMatrix_',num2str(sec),'_sec'];
            
            filename1 = ['SynapticDelayExcDistrib_',num2str(sec),'_sec'];
            filename3 = ['SynapticDelayInhDistrib_',num2str(sec),'_sec'];
            
            filename2 = ['SynapticWeigthExcDistrib_',num2str(sec),'_sec'];
            filename4 = ['SynapticWeigthInhDistrib_',num2str(sec),'_sec'];
            
            [f1_exc, f1_inh, f2_exc, f2_inh] =  del_weigth_distrib(syn_0, w_E0, w_I0);
            TopologyFolder();
            
            save(filename,'AdjacencyMatrix_0','syn_0','-mat');
            saveas(f0,filename0,'jpg');
            saveas(f1_exc,filename1,'jpg');
            saveas(f1_inh,filename3,'jpg');
            saveas(f2_exc,filename2,'jpg');
            saveas(f2_inh,filename4,'jpg');
            saveas(f0,filename0,'fig');
            saveas(f1_exc,filename1,'fig');
            saveas(f1_inh,filename3,'fig');
            saveas(f2_exc,filename2,'fig');
            saveas(f2_inh,filename4,'fig');
            
            close(f0); close(f1_exc); close(f2_exc); close(f1_inh); close(f2_inh);
            clear filename* f0 f1_exc f2_exc f1_inh f2_inh
            cd ..
        end
        % -----------------------------------------------------------------
    end
    if sec > 1
        start = min(find(firings(:,1)>0));
        adj_time = (sec-1) * 1000 * ones(size(firings(start:end,1),1),1);
        adj_spk = zeros(size(firings(start:end,1),1),1);
        adj = [adj_time,adj_spk];
        firings_adj = firings(start:end,:) + adj;
    else
        firings_adj = firings;
    end
    Firings = [Firings;firings_adj];
    %   -------------------------------------------------------
    STDP(:,1:Dexc+1) = STDP(:,1001:1001+Dexc);
    ind = find(firings(:,1) > 1001-Dexc);
    firings = [-Dexc 0;firings(ind,1)-1000,firings(ind,2)];
     if rem(sec,5) == 0
%         figure(1)
%         if strcmp(ConnRule,'SF') 
%             histogram(s(trueSyn))
%         else
%             histogram(s(1:Ne,:))
%         end
        str = ['Simulation time is ',num2str(sec/60),' minutes over a total of ', num2str(NumHours*60),' minutes'];
        display(str);
        if sec==StopSTDP
            figure
            histogram(s(1:Ne,:))
            h = Raster_Global(NumNeur, Firings,NumHours);
            [MatFirings,mfr]=matFirings(Firings,NumNeur,fs);
%             answer = questdlg('keep on STDP?','Options','yes','no','no');
%             if(strcmp('yes',answer))
%                 
%                 StopSTDP = StopSTDP + 10;
%                 close all
%             end
        end
    end 
    
    if sec<StopSTDP   % block STDP 5 min
        s(1:Ne,:) = max(6,min(sm,0.01+s(1:Ne,:) + sd(1:Ne,:)));            % set minimo per STDP 4-->0
         if strcmp(ConnRule,'SF') 
             s(noSyn)=0;
         end
        sd = 0.9 * sd;
    end
   

end
%% -------------------------- Output simulation ---------------------------
SimFilename = SimulationFilename();                                      % simulation id
[SimInfo] = SimulationInfo(NumHours, fs, NumNeur, FracExc, M, Dexc, sm, w_E0, w_I0, tau_stdp, IstimExc_avg,IstimExc_std, IstimInh_avg,IstimInh_std);
Firings = Firings(2:end,:);                                              % the first row contains initial conditions
save(SimFilename,'Firings', 'SimInfo', 'Vraw','-mat');
if strcmp(ConnRule, 'SF') ||  strcmp(ConnRule, 'SW') || strcmp(ConnRule,'MOD')
    [AdjacencyMatrix,h] = AdjacencyMatrixEvaluation(post,s, ConnRule, Net_SF);                 % square matrix (not really adj, since not symm)
else
    [AdjacencyMatrix,h] = AdjacencyMatrixEvaluation(post,s, ConnRule); 
end
    [syn] = SynMatrix(AdjacencyMatrix, post, delays, Dexc);                  % syn = [pre|post|w|del]
TopologyFolder();
filename = ['ConnectivityMatrix_',num2str(sec),'_sec.mat'];
save(filename,'AdjacencyMatrix','syn','-mat');
clear filename
close(h);
cd ..
%% ------------- Topology characterization and storing --------------------
if NetAnalysis
    TopologyFolder();
    %[h1, Graph_FitParameters] = DistribDegreeExcInhAB(AdjacencyMatrix,ConnRule);
    %close(h1);
    filename1 = ['SynapticDelayExcDistrib_',num2str(sec),'_sec'];
    filename3 = ['SynapticDelayInhDistrib_',num2str(sec),'_sec'];
    filename2 = ['SynapticWeigthExcDistrib_',num2str(sec),'_sec'];
    filename4 = ['SynapticWeigthInhDistrib_',num2str(sec),'_sec'];
    [f1_exc, f1_inh, f2_exc, f2_inh] =  del_weigth_distrib(syn, w_E0, w_I0);
    
    saveas(f1_exc,filename1,'jpg');
    saveas(f1_inh,filename3,'jpg');
    saveas(f2_exc,filename2,'jpg');
    saveas(f2_inh,filename4,'jpg');
    saveas(f1_exc,filename1,'fig');
    saveas(f1_inh,filename3,'fig');
    saveas(f2_exc,filename2,'fig');
    saveas(f2_inh,filename4,'fig');
    
    close(f1_exc); close(f2_exc); close(f1_inh); close(f2_inh);
    cd ..
end
clearvars -except StopSTDP Firings start_folder NumNeur fs NumHours SpikeAnalysis BurstAnalysis aVaAnalysis TrialDurationDefinition FracExc Stimulation StimProtocol NeuronId2Stimulate
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% ---------------- Electrophysiological characterization ------------------
%% --------------------- Raster Plot drawing ----------------------
ElectrophysiologyFolder();
h = Raster_Global(NumNeur, Firings,NumHours);
close(h);
%%  -------------- Spike detection computation --------------
if TrialDurationDefinition
    [x,y] = ginput(2);
    Tstart = x(1);
    Tstop = x(2);
    peak_folder = SpikeDetectionModelInterval(Tstart, Tstop, Firings, NumNeur, fs, NumHours);
else
    if Stimulation == 0
        StimProtocol = [];
        NeuronId2Stimulate = [];
        artifact = [];
    else
        % artifact detection
        artifact = artifactDetection(StimProtocol);
    end
    peak_folder = SpikeDetectionModel(Firings,artifact, NumNeur,fs,NumHours,Stimulation, NeuronId2Stimulate);
end

%% ----------------Adjusting Spike train length----------------------------
cd(peak_folder)
cd('ptrain_All1_1')
idxNeurons=dir;
for i=3: length(idxNeurons)
    temp_train=load(idxNeurons(i).name);
    temp_train=temp_train.peak_train;
    new_train = temp_train(StopSTDP:end);
    save(idxNeurons(i).name,'new_train')
end

SplitExcInhPeakTrain(peak_folder, FracExc);
[mfr,mfr_global]=MFRBoschi(start_folder, NumNeur, fs,peak_folder);
save('mfr_global','mfr_global')
%% ------------------------------------------------------------------------
if SpikeAnalysis
    % ------ PARAM ------
    mfr_thresh = 0.001;
    KernelWidth = [20 900]; % (ms) No more than 2!!!!
    if length(KernelWidth) > 2
        KernelWidth = KernelWidth(1:2);
    end
    undersamplingFactor = 1;
    % ------------------
    %MFR(peak_folder, NumNeur, fs, mfr_thresh);
    %[mfr,mfr_global]=MFRBoschi(start_folder, NumNeur, fs,peak_folder);
    [IFR_TABLE,CUM_IFR, IFR_folder] = IFR_evaluation(peak_folder,fs,KernelWidth,undersamplingFactor);
    IFRtracePlot(CUM_IFR, fs, undersamplingFactor,IFR_folder, NumNeur, Firings, NumHours);
end
%% -------------------------------------------------------------------------
if BurstAnalysis
    % ------ PARAM ------
    nspikes = 4;
    ISImax = 100;
    mbr_thresh = 0.4;
    IBIwin = 10;
    IBIbin = 1;
    % ------------------
    cd(peak_folder)
    [exp_num] = BurstDetection (peak_folder, nspikes, ISImax, mbr_thresh, fs, NumNeur, IBIwin, IBIbin);      % This function performs burst detection + Net IBI ditributiond
end
%% -------------------------------------------------------------------------
if aVaAnalysis
    % PARAM
    IEIth = 100; %ms
    minSpkRt = 0.1; %sp/s
    % Pooled Peak trains creation
    [spkTs, spkLabel, nSamples, numElec, Pooled_folder] = PTcreation(peak_folder, minSpkRt, fs);
    % Inter-event interval (IEI) computation
    [IEI_avg,IEI_std,IEI_ste,allIEI_ms,thmaxIEI] = IEI_aVa_comput(spkTs,fs,IEIth);
    IEI_folder = 'IEI_results';
    mkdir(IEI_folder);
    cd(IEI_folder);
    IEIFilename = 'IEIresults.mat';
    save(IEIFilename,'IEI_avg','IEI_std','IEI_ste','allIEI_ms','thmaxIEI');
    IEIplots(allIEI_ms);
    % avalanche computation
    binWidths = [];  % if empty, the avg IEI is used as bin
    aVa_evaluation(spkTs,spkLabel,nSamples,numElec, IEI_avg,fs);
end
%%-------------------------------------------------------------------------
if Stimulation               % PSTH computation and plotting
    binsize = 4;             % PSTH bin width (ms)
    cancwin = 1;             % bin width (ms) to ignore (artifact)
    psthend = 400;           % temporal window (ms) of PSTH
    
    [psthfiles_folder, psthresults_folder, exp_num] = ManagePSTHfiles(peak_folder, binsize, psthend);
    [PSTH_count_all] = PSTH_computation_model (exp_num, fs, NumNeur, binsize, cancwin, psthend, peak_folder, psthfiles_folder, psthresults_folder);
    PSTH_plot(psthfiles_folder, psthresults_folder, NumNeur);
end
%% %%-------------------------------------------------------------------------
%STPE_SpikeTrainFuncion(1000,peak_folder,1);
STPE_SpikeTrainFuncion(1000,peak_folder,0);



end