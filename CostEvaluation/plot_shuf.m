c=zeros(100,1);
a=zeros(100,1);
t=1:100;
s=randi(100,10);
a(s(1,:))=1;
b=Shuffle(a);
subplot(4,1,1)
c(find(a)+3)=1;
plot(t,c,'k','Linewidth',2)
box off
subplot(4,1,2)
plot(t,a,'k','Linewidth',2)
box off
subplot(4,1,3)
plot(t,b,'k','Linewidth',2)
box off
subplot(4,1,4)
plot(t,Shuffle(b),'k','Linewidth',2)
box off
%%
x = [-3:.1:3];
y = normpdf(x,0.5,0.4)./3;
plot(x,y,'k','Linewidth',2)
box off
