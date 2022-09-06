clear all
load ('BTC.csv');%the file containing the historical data  for this stock
prclose=BTC(:,5);%the closing price for each day is in the fifth col. 
%prclose is a vector containing the historical closing price data
% the data in "BTC.csv" is arranged so the first row is the oldest data
% while "today" is the last row. We need to inver this
[m,n]=size(prclose)%how many data entries we have
pause
data = prclose
xx=linspace(1,m,m);%xx is a vector 1,2...m
[middle,upper,lower]= bollinger(data);
CloseBolling = [middle, upper,lower];
plot(xx,CloseBolling)
title('Bollinger Bands for BTC Closing Prices')
print('BTC_Bollinger','-dpdf')
