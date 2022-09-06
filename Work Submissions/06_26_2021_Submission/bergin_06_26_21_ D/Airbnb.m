clear all
load ('ABNB.csv');%the file containing the historical data  for this stock
load ('VIX.csv');%the file containing the historical data  for VIX in the last year
VIXclose=VIX(:,5);
[m1,n1]=size(VIXclose)
prclose=ABNB(:,5);%the closing price for each day is in the fifth col. 
%prclose is a vector containing the historical closing price data
% the data in "ABNB.csv" is arranged so the first row is the oldest data
% while "today" is the last row. We need to inver this
[m,n]=size(prclose)%how many data entries we have
pause
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%normalize the data
today_price=prclose(115);
prclose=prclose/prclose(115);
VIXclose=VIXclose/VIXclose(115);
bdata=prclose;
ddata=VIXclose;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%TREAT ABNB STOCK
xx=linspace(1,m,m);%xx is a vector 1,2...m
plot(xx,bdata)
%please add titles to your graphs
xlabel('Day number starting 12/10/2020')
ylabel('Closing Price')
title('Closing Stock Prices for ABNB')
pause
autocorr(bdata,m-1)
pause
%the auto corrlation hit zero at day 65 in the past
%the relevant data is between day 187 and day 251 (=today) 
%this has to be adjusted for each stock individually
%the relevant data is between day 360 and day 502 (=today) 
RV=prclose(91:115);
rp=25;%relevant period
yy=linspace(1,rp,rp);
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
print('ABNB01','-dpdf')
hold
pause
prdiff=transpose(RV)-trend;
plot(yy,prdiff)
title('Difference between trend and closing prices')
pause
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f=fit(yy',prdiff','fourier3'); %f will have the coeff of the fourier expansion
%display the coefficients of the fourier expansion for the prdiff to make sure they are feasible
display(f)
for i=1:rp
yh(i)=trend(i)+f(i);%trend plus Fourier adjustment
end
plot(yy,yh,'r')
hold
plot(yy,RV,'b')
xlabel('Day number starting 05/28/2021')
ylabel('Closing Price')
title('Closing Stock Prices for ABNB with Fourier Model')
hold
pause
prdiff2=transpose(RV)-yh;%difference between closing prices and fourier model
plot(yy,prdiff2)% plot the residuals
title('residuals from closing price and prototype model')
pause
mm1=abs(min(prdiff2));
mm2=abs(max(prdiff2));
width=(mm1+mm2)/2;%uncertainty width due to random fluctuations
plot(yy,yh,'b')
hold
plot(yy,RV,'r')
plot(yy,yh+width,'k')
plot(yy,yh-width,'k')
xlabel('Days in relevant period')
title('ABNB Prototype model-trend+Fourier')
legend('model','closing prices','errorband'),
print('ABNB02','-dpdf')
hold
pause
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% now do the same for the VIX using relevant period of the stock!
DRV=ddata(91:115);
plot(yy,DRV)
xlabel('days')
ylabel('closing VIX index')
title('VIX closing for the relevant period of the stock')
hold%keep the plot for some additions
pause
%now plot the trend which is the best least quares fit for the data
dp=polyfit(yy,transpose(DRV),1)
for i=1:rp
dtrend(i)=dp(1)*i+dp(2);%the equation of the line is p(1)+p(2)*day
end
%[n,m]=size(yy)
%[n,m]=size(trend)
plot(yy,dtrend)
xlabel('Days in relevant period')
ylabel('Closing VIX')
title('Closing VIX with Trendline')
print('VIX01','-dpdf')
hold off
pause
dprdiff=transpose(DRV)-dtrend;
plot(yy,dprdiff)
title('Difference between trend and VIX index')
pause
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
df=fit(yy',dprdiff','fourier3'); %f will have the coeff of the fourier expansion
%display the coefficients of the fourier expansion for the prdiff to make sure they are feasible
display(f)
for i=1:rp
dyh(i)=dtrend(i)+df(i);%trend plus Fourier adjustment for VIX
end
plot(yy,dyh,'r')
hold
plot(yy,DRV,'b')
xlabel('Day number starting 05/28/2021')
ylabel('Closing VIX')
title('Closing VIX with Fourier Model')
hold
pause
dprdiff2=transpose(DRV)-dyh;%difference between closing prices and fourier model
plot(yy,dprdiff2)% plot the residuals
title('Residuals VIX from prototype model')
pause
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%now find the correlation
alpha=corr(RV,DRV)
% construct the historical and future price of the stock

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOW to the predictions
load('ABNBfuture.csv');%load txhe future data
[m,n]=size(ABNBfuture)%find the numbet of days in the data
rp1=rp+m;%length of relevant historical period +length of future data
%create a vector containing the historical and future data
for i=1:rp
RV1(i)=RV(i);
end
for i=1:m
RV1(i+rp)=ABNBfuture(i,5)/today_price;
end
%find the analytical model(ternd+Fourier) for the past and into the future
for i=1:rp1
trend1(i)=p(1)*i+p(2);%the equation of the line is p(1)*day+p(2)
end
for i=1:rp1
byhh(i)=trend1(i)+f(i);%trend plus Fourier adjustment-for the stock ONLY
end
%Do the same for the VIX  
for i=1:rp1
dtrend1(i)=dp(1)*i+dp(2);
end
for i=1:rp1
dyhh(i)=dtrend1(i)+df(i);
%trend plus Fourier adjustment-for VIX
end
%finally the stock price
for i=1:rp1
stockp(i)=(((1-alpha)*(byhh(i))+alpha*(dyhh(i)))*today_price);%actual model stock price
end
for i=rp1-10:rp1
stockp(i)=(((1-alpha)*(byhh(i))+alpha*(dyhh(i)))*today_price);%actual model stock price
m = [stockp(i-9) stockp(i-8) stockp(i-7) stockp(i-6) stockp(i-5) stockp(i-4) stockp(i-3) stockp(i-2) stockp(i-1) stockp(i); 
     stockp(i-9)+width*today_price stockp(i-8)+width*today_price stockp(i-7)+width*today_price stockp(i-6)+width*today_price stockp(i-5)+width*today_price stockp(i-4)+width*today_price stockp(i-3)+width*today_price stockp(i-2)+width*today_price stockp(i-1)+width*today_price stockp(i)+width*today_price;
     stockp(i-9)-width*today_price stockp(i-8)-width*today_price stockp(i-7)-width*today_price stockp(i-6)-width*today_price stockp(i-5)-width*today_price stockp(i-4)-width*today_price stockp(i-3)-width*today_price stockp(i-2)-width*today_price stockp(i-1)-width*today_price stockp(i)-width*today_price];
writematrix(m, 'A_test.csv');
end
zz=linspace(1,rp1,rp1);
plot(zz,RV1*today_price,'r','LineWidth',2)%plot the historical and future data
hold
plot(zz,stockp,'b','LineWidth',2)%plot analytical model
plot(zz,stockp+width*today_price,'k')%error margins
plot(zz,stockp-width*today_price,'k')
xf(1)=rp;
xf(2)=rp;
yf(1)=100;
yf(2)=180;
plot(xf,yf,'g','LineWidth',2)%plot a line separating the the past from the future
xlabel('Days in relevant period and Future')
title('ABNB Prototype+Market influence')
legend('closing prices','model','errorband','Location','southwest'),
print('ABNB03','-dpdf')
hold