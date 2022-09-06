clear all
load ('QSR.csv');%the file containing the historical data  for this stock
prclose=QSR(:,5);
[m,n]=size(prclose)%how many data entries we have
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%smooth the vector prclose using moving averages algorithm
%i.e. we replace each data point in prclose by taking the average of the data
%values in a window of a chosen size
wz=10;%window size
%first wz elements -forward ave
for i=1:wz
sbb(i)=0;
for j=i:i+wz-1
sbb(i)=sbb(i)+prclose(j);
end
sbb(i)=sbb(i)/wz;
end
%the rest of the data up to the last wz elements
for i=wz+1:m-wz
sbb(i)=0;
for j=i-wz:i+wz-1
sbb(i)=sbb(i)+prclose(j);
end
sbb(i)=sbb(i)/(2*wz);
end
%last wz elements -backward ave
%m=data size
for i=m-wz+1:m
sbb(i)=0;
for j=i-wz+1:i
sbb(i)=sbb(i)+prclose(j);
end
sbb(i)=sbb(i)/wz;
end
%plot the original and smoothed data
xx=linspace(1,m,m);%xx is a vector 1,2...m
plot(xx,prclose,'r')
hold
plot(xx,sbb,'b')
title('Historical vs. smoothed data')
legend('historical','smoothed')
print('QSRSmoothedVHistorical','-dpdf') % create pdf at end
hold
pause
%now move the smoothed data back to prclose
for i=1:m
prclose(i)=sbb(i);
end
%a matlab implementation of moving avarage is the following.
%Please read the matlab documentation if you want to use.
%smoothdata(sb,window-size)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data = prclose
% Dont need because the .csv files were already in the correct order
% for i=1:m
% data(i)= prclose(m+1-i);
% end
set(gcf, 'position', [0,0,800,900]) % window size
subplot(3,2,1)
plot(xx,data)
%please add titles to your graphs
xlabel('Day number starting 05/26/2019')
ylabel('Closing Price')
title('Closing Stock Prices for QSR')
pause
subplot(3,2,2)
autocorr(data,m-1)
pause
%the auto corrlation hit zero at day 173 in the past
%the relevant data is between day 360 and day 502 (=today) 
RV=prclose(393:505);
rp=113;%relevant period
yy=linspace(1,rp,rp);
subplot(3,2,3)
plot(yy,RV)
xlabel('days')
ylabel('closing price')
title('QSR closing prices for the relevant period')
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
title('Closing Stock Prices for QSR with Trendline')
hold
pause
prdiff=transpose(RV)-trend;
subplot(3,2,4)
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
subplot(3,2,5)
plot(yy,yh,'r')
hold
plot(yy,RV,'b')
xlabel('Day number starting 05/26/2019')
ylabel('Closing Price')
title('Closing Stock Prices for QSR with Fourier Model')
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
print('QSR','-dpdf') % create pdf at end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOW to the predictions
load('QSRFuture.csv');%load the future data
[m,n]=size(QSRFuture)%find the numbet of days in the data
rp1=rp+m;%length of relevant historical period +length of future data
%create a vector containing the historical and future data
for i=1:rp
RV1(i)=RV(i);
end
for i=1:m
RV1(i+rp)=QSRFuture(i,5);
end
%extend the analytical model(ternd+Fourier) into the future
for i=1:rp1
trend1(i)=p(1)*i+p(2);%the equation of the line is p(1)+p(2)*day
end
for i=1:rp1
yhh(i)=trend1(i)+f(i);%trend plus Fourier adjustment
end

for i=rp1-10:rp1
yhh(i)=trend1(i)+f(i);%trend plus Fourier adjustment
m = [yhh(i-9) yhh(i-8) yhh(i-7) yhh(i-6) yhh(i-5) yhh(i-4) yhh(i-3) yhh(i-2) yhh(i-1) yhh(i); 
     yhh(i-9)+width yhh(i-8)+width yhh(i-7)+width yhh(i-6)+width yhh(i-5)+width yhh(i-4)+width yhh(i-3)+width yhh(i-2)+width yhh(i-1)+width yhh(i)+width;
     yhh(i-9)-width yhh(i-8)-width yhh(i-7)-width yhh(i-6)-width yhh(i-5)-width yhh(i-4)-width yhh(i-3)-width yhh(i-2)-width yhh(i-1)-width yhh(i)-width];
writematrix(m, 'test.csv');
end


zz=linspace(1,rp1,rp1);
plot(zz,RV1,'r','LineWidth',2)%plot the historical and future data
hold
plot(zz,yhh,'b','LineWidth',2)%plot analytical model
plot(zz,yhh+width,'m')%error margins
plot(zz,yhh-width,'m')
xf(1)=rp;
xf(2)=rp;
yf(1)=55;
yf(2)=75;
plot(xf,yf,'g','LineWidth',2)%plot a line separating the the past from the future
xlabel('Days in relevant period and Future')
title('QSR Prototype model-trend+Fourier')
legend('model','closing prices','errorband'),
hold
print('QSRFuture','-dpdf') % create pdf at end