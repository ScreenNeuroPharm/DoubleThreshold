%% This function set up the spike trains for TSPE shuffling algorithm (TSPE_shuffling.m)


function STPE_shuff_INVITRO(SaRa,peak_dir,NetDir,shuffling)

format long g
cd(peak_dir);
d = dir;
nEl = length(d)-2;

if nEl~=100 & nEl~= 60 & nEl~=256 & nEl~=120 & nEl~=500
    errordlg('Selection Failed - Select the folder with all electrodes', 'Error');
    return
end

cc = d(3).name;
cc = split(cc,'.');
cc = split(cc{1},'_');
cc = cc{end};
chars =  regexp(cc,'([A-Z]+)','match');

if nEl == 120
    mcmea_electrodes = MEA120_lookuptable;
elseif nEl == 60 & isempty(chars)
    mcmea_electrodes = string([12:18,21:28,31:38, 41:48,51:58,61:68,71:78,82:87]);
elseif nEl == 60 & ~isempty(chars)
    mcmea_electrodes = MEA4Q_lookuptable;
elseif  nEl == 256
     mcmea_electrodes = MEA256_lookuptable;
end
n=0;
if nEl~=1000
    for k = 3:length(d)
        el = split(d(k).name,'.');
        el = split(el(1),'_');
        el = el{end};
        if isempty(chars)
            el = str2num(el);
        else
            el = str2num(str2mat(mcmea_electrodes(strcmp(mcmea_electrodes(:,1),string(el)),2)));
        end

        load(d(k).name);
        %peak_train=new_train;
        pk{el} = peak_train';
       
    end
elseif nEl==1000
     for k = 3:length(d)
        el = split(d(k).name,'.');
        el = split(el(1),'_');
        el = el{end};
        load(d(k).name);
        peak_train=new_train;
        pk{k-2} = peak_train';
    end
end

if length(pk)==87
    pk([1:11,18:20,29:30,39:40,49:50,59:60,69:70,79:81])=[];
end

rectime_ms = length(peak_train)./SaRa.*1000;
data.recordingtime_ms = rectime_ms;
data.SaRa = SaRa;
data.NumEL_rec = nEl;

 
%% Create the peak train with only the time [ms] when the spike occurs
peak_train_new=cell(nEl,1);
for j = 1:length(pk)
    tmp = pk{j};
    index = find(tmp~=0);
    time = index/SaRa*1000;
    peak_train_new{j,1} = time;
end


peak_train_new{j+1,1} = 1;
peak_train_new{j+2,1} = [nEl rectime_ms];
 

data.asdf = peak_train_new;
clear peak_train_new pk
if shuffling
            kh=SaRa/1000;
            kh=1;
            ShuffledCC=TSPE_shuffling(data.asdf,25,[3, 4, 5, 6, 7, 8]*kh,0,[2, 3, 4, 5, 6]*kh,0);
            cd(NetDir);
            mkdir('CrossCorrelation');
            cd('CrossCorrelation');

            save('ShuffledCC', 'ShuffledCC');


            if nEl == 60 & isempty(chars)
            type = 1;
            else
            type = 0;
            end
 
else
     kh=SaRa/1000;
     kh=1;
     [ConnectivityMatrix, Delaymatrix_ms, CrossCorrelogram]=TSPE(data.asdf,25,[3, 4, 5, 6, 7, 8]*kh,0,[2, 3, 4, 5, 6]*kh,0);

cd(NetDir);
mkdir('CrossCorrelation');
cd('CrossCorrelation');

%ConnectivityMatrix(1==(diag(ones(1,data.NumEL_rec))))=0;
%ConnectivityMatrix(400:end,400:end)=0;

save('ConnectivityMatrix', 'ConnectivityMatrix');
save('DelayMatrix_ms', 'Delaymatrix_ms');
save('CrossCorrelogram', 'CrossCorrelogram');

if nEl == 60 & isempty(chars)
    type = 1;
else
    type = 0;
end
imagesc(ConnectivityMatrix)
end
