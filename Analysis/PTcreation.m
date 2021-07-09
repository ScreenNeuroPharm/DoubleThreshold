function [spkTs, spkLabel, nSamples, numElec, Pooled_folder] = PTcreation(peak_folder, minSpkRt, fs)
   
   cd(peak_folder);
   d = dir;
   for j = 3:length(d)
       sub_fold = d(j).name;
       if strfind(sub_fold,'_All')
          cd(sub_fold);
          trialFolder = pwd;
         [spkTs,spkLabel,nSamples,numElec,meanSpkRt] = Sparse2Pooled(trialFolder,minSpkRt,fs);
         cd ..\..
         string = 'PeakDetectionMATPooled_files';
         PDfolderPath = pwd;
         cd(PDfolderPath);
         mkdir(string);
         cd(string);
         Pooled_folder = pwd;
         saveFilename = ['ptrain_nbasal1.mat'];
         save(saveFilename,'spkTs','spkLabel','nSamples','numElec','meanSpkRt');
         cd ..
       end
   end
