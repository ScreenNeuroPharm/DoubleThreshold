function value=weightDist(S,A,B)
StructWeigthINH=S(S<0);
FunctInhMS=A(A<0);
FunctInhCost=B(B<0);

[InhStructProf,xS]=histcounts(StructWeigthINH,100);
[InhMSProf,xMs]=histcounts(FunctInhMS,100);
[InhCostProf,xCost]=histcounts(FunctInhCost,100);

 options = fitoptions('gauss1', 'Upper', [100 100 100]);
 [g,f,b] = fit(xS(1:end-1)',InhStructProf','gauss1',options);  %y = a1*exp(-((x-b1)/c1)^2)
 [g_Ms,fMs,b_exc] = fit(xMs(1:end-1)',InhMSProf','gauss1',options);  %y = a1*exp(-((x-b1)/c1)^2)
 options = fitoptions('gauss1', 'Upper', [100 100 100]);
 [g_Cost,fCost,b_inh] = fit(xCost(1:end-1)',InhCostProf','gauss1',options);  %y = a1*exp(-((x-b1)/c1)^2)
  
 value=[fMs.rsquare,fCost.rsquare];


hold on
plot(InhStructProf,'*g')
plot(InhMSProf,'*b')
plot(InhCostProf,'*r')
plot(g,'g')
plot(g_Ms,'b')
plot(g_Cost,'r')
legend('Struct','MS','Cost')

end