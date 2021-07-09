function [CMres, DMres, sumWin] = TSPE(sdf, d, neg_wins, co_wins, pos_wins, FLAG_NORM)
% Parameters:
%   sdf         - Time series in Spike Data Format (SDF)
%   d           - Maximal delay time (default 25)
%   neg_wins    - Windows for before and after area of interest (default [3, 4, 5, 6, 7, 8])
%   co_wins     - Cross-over window size (default 0)
%   pos_wins    - Sizes of area of interest (default [2, 3, 4, 5, 6])
%   FLAG_NORM   - 0 - no usage of normalization (default)
%               - 1 - usage of normalization
%
% Returns:
%   CMres       - NxN matrix where N(i, j) is the total spiking probability edges (TSPE) i->j
%   DMres       - NxN matrix where N(i, j) is the transmission time with highest TSPE Value i->j
%
% Wrote by Stefano De Blasi, UAS Aschaffenburg in 2018
filter = 1;
switch nargin
  case 1
    d = [];
    neg_wins = [];
    co_wins = [];
    pos_wins = [];
    FLAG_NORM = [];
  case 2
    neg_wins = [];
    co_wins = [];
    pos_wins = [];
    FLAG_NORM = [];
  case 3
    co_wins = [];
    pos_wins = [];
    FLAG_NORM = [];
  case 4
    pos_wins = [];
    FLAG_NORM = [];
  case 5
    FLAG_NORM = [];
  case 6 
      % all parameters are already set
%   otherwise
%     error('Input error.')
end
if isempty(pos_wins)
  pos_wins=[2, 3, 4, 5, 6];
end
if isempty(co_wins)
  co_wins=0;
end
if isempty(neg_wins)
  neg_wins=[3, 4, 5, 6, 7, 8];
end
if isempty(d)
  d=25;
end
if isempty(FLAG_NORM)
  FLAG_NORM=0;
end

format long g

%% Generation of sparse matrices
    a=sdf{end};
    NrC = a(1);
    vec1=[];
    vec2=[];
    for i=1:NrC
        vec1=[vec1 sdf{i}];
        vec2=[vec2 i*ones(1,length(sdf{i}))];
    end
    if find(floor(vec1(vec1>0 & vec1 <= a(2)))==0)
        mat=sparse(ceil(vec1(vec1>0 & vec1 <= a(2))),floor(vec2(vec1>0 & vec1 <= a(2))),1,a(2),a(1));
    else
        mat=sparse(floor(vec1(vec1>0 & vec1 <= a(2))),floor(vec2(vec1>0 & vec1 <= a(2))),1,a(2),a(1));
    end
    NrS=a(2);  
%% Calculation of std deviation and mean values   
    l=ones(1,NrS);
    u_mean=l*mat/NrS;
    u_0=mat-u_mean;
    r=std(u_0);  
   %% Fast Cross-Correlation 
   
    ran=1-max(neg_wins)-max(co_wins):max(neg_wins)+d;
    CM=(zeros(length(ran),NrC,NrC));
    ind=max(neg_wins)+max(co_wins);                                                
    if(ind <= 0)
        ind=1;
    end
 
    for i=0:d+max(neg_wins)
%         CM(ind,:,:)=(mat(1+i:end,:)'*mat(1:end-i,:))./(r'*r)/NrS;
        
        % Correct form: 
        CM(ind,:,:)=(u_0(1+i:end,:)'*u_0(1:end-i,:))./(r'*r)/NrS;
        % takes longer, no performance impact
        fprintf("Cross-Correlation %.2f%s completed \n",((i./(d+max(neg_wins))).*100),"%");
        ind=ind+1;
    end

% Usage of symmetric construction of cross correlation for faster
% calculation:
    if(max(neg_wins)+max(co_wins) > 0)
        bufCM=zeros(NrC);
        ind=0;
        for j=max(neg_wins)+max(co_wins)-1:-1:1
            bufCM(:)=CM(max(neg_wins)+max(co_wins)+j,:,:);
            ind=ind+1;
            CM(ind,:,:)=bufCM';
        end
    end
   
% Additional scaling for reduction of network burst impacts:
    if FLAG_NORM
      s=zeros(length(ran),1);
      for i=1:length(ran)
          zwi=CM(i, ~ diag(ones(NrC,1)));
          s(i)=sum(sum(  zwi(~ isnan(CM(i, ~ diag(ones(NrC,1)))))));
      end
      CM=CM./s;
    end  
%% Generation of edge filters
    WB=max(neg_wins)+max(co_wins);
    sumWin=zeros(d+WB,NrC,NrC);  
    in=0;
    for win_before=neg_wins
      for win_p1=co_wins 
        for win_in=pos_wins
            in=in+1;
            win_p2=win_p1;
            win_after=win_before;
            windows{in}=[-1*ones(win_before,1) /win_before; zeros(win_p1,1);2/win_in* ones(win_in,1);zeros(win_p2,1);-1*ones(win_after,1)/win_after];
            beginnings{in}=1+WB-win_before-win_p1;
            win_inner{in}=win_in;
        end
      end
    end
    m=d+max(neg_wins)+max(co_wins)+max(pos_wins);    
   
%% Usage of edge filters: 
    for j=1:in         
            CM3=convn(convn(CM(beginnings{j}:end, : , :),windows{j},'valid'),[ones(win_inner{j},1)],'full');
            m=min(m,length(CM3(:,1,1)));
            sumWin(1:size(CM3,1),:,:)=CM3+sumWin(1:size(CM3,1),:,:);
    end
  
%% Only look at valid window
    
    sumWin=sumWin(1:m,:,:);   %1:m

%% Adjustment and looking for maximum at each delay time 
    sumWin=permute(sumWin, [1 3 2]);
    [~,index] = max(abs(sumWin));
    CMres=zeros(NrC);
    DMres=squeeze(index)-2;
    for i=1:size(sumWin,2)
        CMres(:,i)=sumWin(sub2ind(size(sumWin), index(1,1:size(sumWin,2),i), 1:size(sumWin,2), i * ones(1,size(sumWin,2)))    );
    end
    fprintf("Cross-Correlation completed \n");
end