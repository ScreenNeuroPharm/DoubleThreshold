function [mfr,mfr_global]=MFRBoschi(start_folder, NumNeur, fs,peak_folder)
%------------analisys
cd(peak_folder)
cd('ptrain_All1_1')
neuron=dir;
load(neuron(3).name)
totaltime=length(new_train)./fs;                                           %[sec]
for i=1:NumNeur
    load(neuron(i+2).name)
    mfr(i)=length(find(new_train>0))./totaltime;
end
mfr_global=mean(mfr);
cd(start_folder)
mkdir("MFR_Analisys");
cd("MFR_Analisys");
save('mfr','mfr')
save('mfr_global','mfr_global')