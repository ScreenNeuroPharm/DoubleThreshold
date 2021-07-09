function [index,numPhase]=findfolderStim(name_dir_cell, stimel)
% Find the folder relative to a specific stimulating electrodes
k=0;
for i=1:length(name_dir_cell) 
    sep = max(strfind(name_dir_cell{i},'_'));
    if (str2num(name_dir_cell{i}(sep+1:end))==stimel) 
        k=k+1;
        stimString = regexpi(name_dir_cell{i},'stim\d','match','once');
        numPhase(k)=str2num(stimString(end));
        index(k)=i;        
    end
end

