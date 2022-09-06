clear all
load ('ABNB.csv');
prclose=ABNB(:,5);
[m,n]=size(prclose)
data = prclose
% Dont need because the .csv files were already in the correct order
% for i=1:m
% data(i)= prclose(m+1-i);
% end
xx=linspace(1,m,m);%xx is a vector 1,2...m
set(gcf, 'position', [0,0,800,900]) % window size
subplot(3,2,1)
plot(xx,data)

xlabel('Day number starting 12/10/2020')
ylabel('Closing Price')
title('Closing Stock Prices for ABNB')
pause
subplot(3,2,2)
autocorr(data,m-1)
pause
RV=prclose(91:115);
rp=25;%relevant period
yy=linspace(1,rp,rp);
subplot(3,2,3)
plot(yy,RV)
xlabel('days')
ylabel('closing price')
title('ABNB closing prices for the relevant period')
hold%keep the plot for some additions
pause
%now plot the trend which is the best least quares fit for the data
p=polyfit(yy,transpose(RV),1)
for i=1:rp
trend(i)=p(1)*i+p(2);%the equation of the line is p(1)+p(2)*day
end
%[n,m]=size(yy)
%[n,m]=size(trend)
plot(yy,trend)
xlabel('Days in relevant period')
ylabel('Closing Price')
title('Closing Stock Prices for ABNB with Trendline')
hold
pause
prdiff=transpose(RV)-trend;
subplot(3,2,4)
plot(yy,prdiff)
title('Difference between trend and closing prices')
pause
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f=fit(yy',prdiff','fourier2'); %f will have the coeff of the fourier expansion
display(f)%display the coefficient of the fourier expansion for the prdiff
for i=1:rp
yh(i)=trend(i)+f(i);%trend plus Fourier adjustment
end
subplot(3,2,5)
plot(yy,yh,'r')
hold
plot(yy,RV,'b')
xlabel('Day number starting 12/10/2020')
ylabel('Closing Price')
title('Closing Stock Prices for ABNB with Fourier Model')
hold
pause
prdiff2=transpose(RV)-yh;%difference between closing prices and fourier model
subplot(3,2,6)
plot(yy,prdiff2)% plot the residuals
mm1=abs(min(prdiff2));
mm2=abs(max(prdiff2));
width=(mm1+mm2)/2;%uncertainty width due to random fluctuations
plot(yy,yh,'b')
hold
plot(yy,RV,'r')
plot(yy,yh+width,'m')
plot(yy,yh-width,'m')
xlabel('Days in relevant period')
title('Prototype model-trend+Fourier')
legend('model','closing prices','errorband'),
hold off
print('ABNB','-dpdf') % create pdf at end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOW to the predictions
load('ABNBFuture.csv');%load the future data
[m,n]=size(ABNBFuture)%find the numbet of days in the data
rp1=rp+m;%length of relevant historical period +length of future data
%create a vector containing the historical and future data
for i=1:rp
RV1(i)=RV(i);
end
for i=1:m
RV1(i+rp)=ABNBFuture(i,5);
end
%extend the analytical model(ternd+Fourier) into the future
for i=1:rp1
trend1(i)=p(1)*i+p(2);%the equation of the line is p(1)+p(2)*day
end
for i=1:rp1
yhh(i)=trend1(i)+f(i);%trend plus Fourier adjustment
end
zz=linspace(1,rp1,rp1);
plot(zz,RV1,'r','LineWidth',2)%plot the historical and future data
hold
plot(zz,yhh,'b','LineWidth',2)%plot analytical model
plot(zz,yhh+width,'m')%error margins
plot(zz,yhh-width,'m')
xf(1)=rp;
xf(2)=rp;
yf(1)=100;
yf(2)=180;
plot(xf,yf,'g','LineWidth',2)%plot a line separating the the past from the future
xlabel('Days in relevant period and Future')
title('ABNB Prototype model-trend+Fourier')
legend('model','closing prices','errorband'),
hold
print('ABNBFuture','-dpdf') % create pdf at end

