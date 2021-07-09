function [] = SplitExcInhPeakTrain (peak_folder, FracExc)

cd(peak_folder)
d = dir;
ExcFolder = 'ptrain_exc1_2';
mkdir(ExcFolder);
cd(ExcFolder);
ExcFolder = pwd;
cd ..

InhFolder = 'ptrain_inh1_3';
mkdir(InhFolder);
cd(InhFolder);
InhFolder = pwd;
cd ..

for i = 3:length(d)
    subfold = d(i).name;
    cd(subfold);
    dd = dir;
    for j = 3:round((length(dd)-2)*FracExc/100) + 2
        filename = dd(j).name;
        copyfile(filename,ExcFolder);
    end
    
    for j = ceil(((length(dd)-2)*FracExc/100)) + 3 : length(dd)
        filename = dd(j).name;
        copyfile(filename,InhFolder);
    end
end
cd ..\..
