load ('BAX.csv');%the file containing the historical data  for this stock
prclose=BAX(:,5);%the closing price for each day is in the fifth col. 
%prclose is a vector containing the historical closing price data
% the data in "BAX.csv" is arranged so the first row is the oldest data
% while "today" is the last row. We need to inver this
[m,n]=size(prclose)%how many data entries we have
for i=1:m
data(i)=prclose(m+1-i);
end
xx=linspace(1,m,m);%xx is a vector 1,2...m
plot(xx,data)
%please add titles to your graphs
xlabel('Day number starting 11/5/2018')
ylabel('Closing Price')
title('Closing Stock Prices for BAX')
pause
autocorr(data,m-1)
pause
%the auto corrlation hit zero at day 143 in the past
%the relevant data is between day 360 and day 502 (=today) 
RV=prclose(360:502);
rp=143;%relevant period
yy=linspace(1,rp,rp);
plot(yy,RV)
xlabel('days')
ylabel('closing price')
title('BAX closing prices for the relevant period')
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
title('Closing Stock Prices for BAX with Trendline')
print('BAX01','-dpdf')
hold
pause
prdiff=transpose(RV)-trend;
plot(yy,prdiff)
title('Difference between trend and closing prices')
pause
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f=fit(yy',prdiff','fourier3'); %f will have the coeff of the fourier expansion
display(f)%display the coefficient of the fourier expansion for the prdiff
for i=1:rp
yh(i)=trend(i)+f(i);%trend plus Fourier adjustment
end
plot(yy,yh,'r')
hold
plot(yy,RV,'b')
xlabel('Day number starting 11/5/2018')
ylabel('Closing Price')
title('Closing Stock Prices for BAX with Fourier Model')
hold
pause
prdiff2=transpose(RV)-yh;%difference between closing prices and fourier model
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
title('BAX Prototype model-trend+Fourier')
legend('model','closing prices','errorband'),
print('BAX02','-dpdf')
hold
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOW to the predictions
load('BAXfuture.csv');%load the future data
[m,n]=size(BAXfuture)%find the numbet of days in the data
rp1=rp+m;%length of relevant historical period +length of future data
%create a vector containing the historical and future data
for i=1:rp
RV1(i)=RV(i);
end
for i=1:m
RV1(i+rp)=BAXfuture(i,5);
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
yf(1)=70;
yf(2)=95;
plot(xf,yf,'g','LineWidth',2)%plot a line separating the the past from the future
xlabel('Days in relevant period and Future')
title('BAX Prototype model-trend+Fourier')
legend('model','closing prices','errorband'),
print('BAX03','-dpdf')
hold

