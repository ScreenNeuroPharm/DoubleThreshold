function [LRT, H, p] = LogRatioTest(LogLikelihood_distrib1, LogLikelihood_distrib2, pvalue, dof)
% LogLikelihood_distrib1 è la distribuzione da testare e paragonare con le
% altre LogLikelihood_distrib2


LRT = 2*(LogLikelihood_distrib2- LogLikelihood_distrib1);
p = 1-chi2cdf(LRT, dof);
H = -(pvalue >= p);
if H == 1
    str = ['Reject the null hypothesis at significance level of p = ', num2str(pvalue)];
    display(str);
elseif H == 0
       str = ['Do not reject the null hypothesis at significance level of p = ', num2str(pvalue)];
       display(str);
end
