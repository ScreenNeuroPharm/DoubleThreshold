function [gof] = computeGof_KS(x, xmin, alpha)
%% Initializing variables
z     = x(x>=xmin);	nz   = length(z);	xmax = max(z);
% y = logspace(log10(xmin),log10(xmax),10);
y = xmin:xmax;
% y     = x(x<xmin); 	ny   = length(y);
%% Computing CDF
pdf = (y.^-alpha)./ (zeta(alpha) - sum((1:xmin-1).^-alpha));
npdf = pdf./sum(pdf);
fit = cumsum(npdf); 
% fit = (1-sqrt(xmin./y))/(1-sqrt(xmin./xmax));
cdi = cumsum(hist(z,y)./nz);
% fit = fit + (cdi(1)-fit(1));
%% Computing gof
% KS
gof = max(abs(fit - cdi));
% Shew
% gof = mean(fit-cdi);
% Thierry
% gof = sum(fit-cdi);
end