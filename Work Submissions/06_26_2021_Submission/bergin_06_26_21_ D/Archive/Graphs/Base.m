clear all
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
print('BAX01','dpdf')
hold
pause
prdiff=transpose(RV)-trend;
plot(yy,prdiff)
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
title('Prototype model-trend+Fourier')
legend('model','closing prices','errorband'),
hold


