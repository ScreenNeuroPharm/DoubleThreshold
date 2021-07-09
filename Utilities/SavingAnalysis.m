function [] = SavingAnalysis(folder_name, filename, h)

if  exist(folder_name,'dir')
    cd (folder_name);
    saveas(h,filename,'fig');
    saveas(h,filename,'jpg');
    cd ..
else
    mkdir(folder_name);
    cd (folder_name);
    saveas(h,filename,'fig');
    saveas(h,filename,'jpg');
    cd ..
end
