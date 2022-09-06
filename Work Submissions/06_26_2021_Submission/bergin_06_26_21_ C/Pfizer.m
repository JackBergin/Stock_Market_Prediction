clear all
load ('PFE.csv');%the file containing the historical data  for this stock
load ('DJI.csv');%the file containing the historical data  for DJI in the last year
DJIclose=DJI(:,5);
[m1,n1]=size(DJIclose)
prclose=PFE(:,5);%the closing price for each day is in the fifth col. 
%prclose is a vector containing the historical closing price data
% the data in "PFE.csv" is arranged so the first row is the oldest data
% while "today" is the last row. We need to inver this
[m,n]=size(prclose)%how many data entries we have
pause
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%normalize the data
today_price=prclose(505);
prclose=prclose/prclose(505);
DJIclose=DJIclose/DJIclose(505);
bdata=prclose;
ddata=DJIclose;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%TREAT PFE STOCK
xx=linspace(1,m,m);%xx is a vector 1,2...m
plot(xx,bdata)
%please add titles to your graphs
xlabel('Day number starting 05/27/2019')
ylabel('Closing Price')
title('Closing Stock Prices for PFE')
pause
autocorr(bdata,m-1)
pause
%the auto corrlation hit zero at day 65 in the past
%the relevant data is between day 187 and day 251 (=today) 
%this has to be adjusted for each stock individually
%the relevant data is between day 360 and day 502 (=today) 
RV=prclose(474:505);
rp=32;%relevant period
yy=linspace(1,rp,rp);
plot(yy,RV)
xlabel('days')
ylabel('closing price')
title('PFE closing prices for the relevant period')
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
title('Closing Stock Prices for PFE with Trendline')
print('PFE01','-dpdf')
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
title('Closing Stock Prices for PFE with Fourier Model')
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
title('PFE Prototype model-trend+Fourier')
legend('model','closing prices','errorband'),
print('PFE02','-dpdf')
hold
pause
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% now do the same for the DJI using relevant period of the stock!
DRV=ddata(474:505);
plot(yy,DRV)
xlabel('days')
ylabel('closing DJI index')
title('DJI closing for the relevant period of the stock')
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
ylabel('Closing DJI')
title('Closing DJI with Trendline')
print('DJI01','-dpdf')
hold off
pause
dprdiff=transpose(DRV)-dtrend;
plot(yy,dprdiff)
title('Difference between trend and DJI index')
pause
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
df=fit(yy',dprdiff','fourier3'); %f will have the coeff of the fourier expansion
%display the coefficients of the fourier expansion for the prdiff to make sure they are feasible
display(f)
for i=1:rp
dyh(i)=dtrend(i)+df(i);%trend plus Fourier adjustment for DJI
end
plot(yy,dyh,'r')
hold
plot(yy,DRV,'b')
xlabel('Day number starting 05/28/2021')
ylabel('Closing DJI')
title('Closing DJI with Fourier Model')
hold
pause
dprdiff2=transpose(DRV)-dyh;%difference between closing prices and fourier model
plot(yy,dprdiff2)% plot the residuals
title('Residuals DJI from prototype model')
pause
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%now find the correlation
alpha=corr(RV,DRV)
% construct the historical and future price of the stock

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOW to the predictions
load('PFEfuture.csv');%load txhe future data
[m,n]=size(PFEfuture)%find the numbet of days in the data
rp1=rp+m;%length of relevant historical period +length of future data
%create a vector containing the historical and future data
for i=1:rp
RV1(i)=RV(i);
end
for i=1:m
RV1(i+rp)=PFEfuture(i,5)/today_price;
end
%find the analytical model(ternd+Fourier) for the past and into the future
for i=1:rp1
trend1(i)=p(1)*i+p(2);%the equation of the line is p(1)*day+p(2)
end
for i=1:rp1
byhh(i)=trend1(i)+f(i);%trend plus Fourier adjustment-for the stock ONLY
end
%Do the same for the DJI  
for i=1:rp1
dtrend1(i)=dp(1)*i+dp(2);
end
for i=1:rp1
dyhh(i)=dtrend1(i)+df(i);
%trend plus Fourier adjustment-for DJI
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
yf(1)=36;
yf(2)=41;
plot(xf,yf,'g','LineWidth',2)%plot a line separating the the past from the future
xlabel('Days in relevant period and Future')
title('PFE Prototype+Market influence')
legend('closing prices','model','errorband','Location','southwest'),
print('PFE03','-dpdf')
hold