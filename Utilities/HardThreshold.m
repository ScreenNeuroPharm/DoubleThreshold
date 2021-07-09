function CC = HardThreshold(W,nexc,ninh)
%HardThreshold.m evaluates the thresholded connectivity matrix  
%--------------------------input-------------------------------------------
%     W: square weighted Connectivity Matrix (NxN)
%     nexc: arbitrary positive value defining the first threshold
%     ninh: arbitrary positive value defining the first threshold
%--------------------------output------------------------------------------
%     CC: thresholded connectivity matrix  

CC = W;
tmpCC = CC(CC~=0);
exc = nexc;
inh = ninh;

thres_exc = mean(tmpCC(tmpCC>0))+exc*std(tmpCC(tmpCC>0));
thres_inh = mean(tmpCC(tmpCC<0))-inh*std(tmpCC(tmpCC<0));
ecc=0;
in=0;

for i=1:length(CC)
    for j=1:length(CC)
        if CC(i,j)>= 0
            if CC(i,j)<thres_exc
                CC(i,j) = 0;
            else 
                ecc = ecc+1;
            end
        else
            if CC(i,j) > thres_inh
                CC(i,j) = 0;
            else
                in = in+1;                    
            end
        end
    end
end
end