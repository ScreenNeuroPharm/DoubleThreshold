%% Create a Thresholded Connectivity Matrix
function [CCMeanStd,CC_bin_meanstd] = ThresholdMatrix1(CCfolder,nexc,ninh,syn,Filter)

    cd (CCfolder);
    DR = dir;
    Directednew=[];

    for k = 3:length(DR)
        if (~isempty(strfind(DR(k).name,'ConnectivityMatrix')))
            load(DR(k).name);
        end
    end
     for k = 3:length(DR)
        if (~isempty(strfind(DR(k).name,'DelayMatrix')))
            load(DR(k).name);
        end
     end
%-------------Building Structural delay Matrix-----------------------------
DelayStruct=zeros(length(Delaymatrix_ms));
for i=1:length(syn)
    DelayStruct(syn(i,1),syn(i,2))=syn(i,4);
end
%-------------------------Spatio-temporal Filter---------------------------
if Filter
%     %DeltaError = sigmoid(Delaymatrix_ms,20,0.5).*6+2;
%     %DeltaError=(Delaymatrix_ms./(5+Delaymatrix_ms)).*25;                      %[ms]
%     IdxToDelete = find(abs(Delaymatrix_ms-DelayStruct)>3 & DelayStruct>0);
%     ConnectivityMatrix(IdxToDelete)=0;          % delete connections with non phisiological delay
%     
%     ConnDeleted=length(IdxToDelete);
end
%--------------------------weigth histogram--------------------------------
%histogram(ConnectivityMatrix(ConnectivityMatrix~=0))
%% ---------------------- First Method Mean-std ---------------------------
n=length(ConnectivityMatrix);
ConnectivityMatrix(isnan(ConnectivityMatrix))=0;
CCMeanStd=zeros(n,n,length(nexc));
CC_bin_meanstd=zeros(n,n,length(nexc));
for k=1:length(nexc)
                            %% Calculation of matrices by setting a threshold
                            
                            CC = ConnectivityMatrix;
                            tmpCC = CC(CC~=0);
                            exc = nexc(k);
                            inh = ninh(k);
                          
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

               

                            fnameCC = fullfile(CCfolder,[strcat('TCM_nexc=',string(exc),'_ninh=',string(inh),'.mat')]);
                            %save(fnameCC, 'CC');

                            ratio = ecc*100 /(in+ecc);
                            values = [ratio, in, ecc];
                            fnameratio = fullfile(CCfolder,[strcat('Ratio_TCM_nexc=',string(exc),'_ninh=',string(inh),'.mat')]);
                            %save(fnameratio, 'values');

                            %% Given the matrix Directed, the analogous binary is defined
                            CC_bin = CC;
                            CC_bin(CC_bin ~= 0) = 1;

                            fnameBin = fullfile(CCfolder,[strcat('TCM_Binary_nexc=',string(exc),'_ninh=',string(inh),'.mat')]);
                            %save(fnameBin, 'CC_bin');

                            %% Graf Theory
                            % Based on the new calculated matrices we want to obtain the number of
                            % nodes and link

                            link= nnz (CC);
                            [r, c] = find(CC ~=0);
                            node = length(union (r, c));
                            fnameNode = fullfile(CCfolder,[strcat('LinkNode_nexc=',string(exc),'_ninh=',string(inh),'.mat')]);
                            %save(fnameNode, 'node','link');
                            
                            CCMeanStd(:,:,k)=CC;
                            CC_bin_meanstd(:,:,k)=CC_bin;
end
