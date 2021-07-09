for i=1:20
    
    BurstStatistics=RND_BS(i);
    BurstStatistics=BurstStatistics.MBR;
    
        meanMBRexc(i)=mean(double(BurstStatistics(:,3)))';
        meanBurstDurexc(i)=mean(double(BurstStatistics(:,7)))';
    
        meanMBRexc=meanMBRexc';
        meanBurstDurexc= meanBurstDurexc';
    
end