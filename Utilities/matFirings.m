function [mat,ALL_MFR]= matFirings(Firings,numNeur,fs)
maxtime=Firings(end,1);   %[ms]
mat=zeros(1000,maxtime);
for i=1:numNeur
    idx_spike=find(Firings(:,2)==i);
    spike = Firings(idx_spike,1);
    mat(i,spike)=1;
end
if(length(mat)>=60*fs)
    MFRmat=mat(:,end-60*fs+1:end);
else
    MFRmat=mat;
end
mfr=sum(MFRmat,2)./60;
ALL_MFR=mean(mfr);