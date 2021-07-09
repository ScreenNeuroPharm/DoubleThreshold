matrix=randi(2,10000,1)-1;
w_sample=20;
bin_sample=1;
Non=2;
NCC = c_corr_pro (matrix,bin_sample,w_sample,Non);
n=length(NCC)/(Non^2);
CC=zeros(Non,Non,n);
for i=1:Non
    for j=1:Non
     CC(i,j,:)=NCC((i-1)*n*Non+1+(j-1)*n:(i-1)*n*Non+(j-1)*n+n)  ; 
    end
end