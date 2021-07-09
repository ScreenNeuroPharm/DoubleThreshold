function [s] = SynWeigthDistributions(distrib, NumLink, NumNeur, FracExc, w_E0, StdExc, w_I0, StdInh)


Ne = floor((NumNeur * FracExc)/100);
Ni = NumNeur - Ne;

if strcmp(distrib,'Normal')
    SynWeigthExc = [normrnd(w_E0, StdExc,NumLink, Ne)]';
    SynWeigthInh = [normrnd(w_I0, StdInh,NumLink, Ni)]';
    s = [SynWeigthExc;SynWeigthInh];
    
elseif strcmp(distrib,'Const')
    s = [w_E0 * ones(Ne,NumLink); w_I0 * ones(Ni,NumLink)];
    
elseif strcmp(distrib,'Unif')
    SynWeigthExc = [unifrnd(w_E0 - 3* StdExc, w_E0 + 3* StdExc, 1, NumLink)]';
    SynWeigthInh = [unifrnd(w_I0 - 3* StdInh, w_I0 + 3* StdInh, 1, NumLink)]';
    s = [SynWeigthExc;SynWeigthInh];

elseif strcmp(distrib,'LogNormal')
    SynWeigthExc = [lognrnd(wE_0, StdExc, NumLink, Ne)]';
    SynWeigthInh = [lognrnd(w_I0, std_Inh, NumLink, Ni)]';
    s = [SynWeigthExc;SynWeigthInh];
end