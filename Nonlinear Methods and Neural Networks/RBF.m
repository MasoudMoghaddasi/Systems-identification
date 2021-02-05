clc ;clear all;close all
%% Input & Output
% load 'exchanger.dat'
% x_d=exchanger( : , 2 );
% y_d=exchanger( : , 3 );

load 'ballbeam.dat'
x_d = ballbeam( : , 1 ) ;
y_d = ballbeam( : , 2 ) ;

%%

x_dtr=x_d(1:round(0.7*size(x_d,1)),:);
y_dtr=y_d(1:round(0.7*size(x_d,1)),:);
x_dte=x_d(round(0.7*size(x_d,1))+1:end,:);
y_dte=y_d(round(0.7*size(x_d,1))+1:end,:);
goal=0.002;
spread=0.1;
MN=round(0.7*size(x_d,1));
DF=10;
net = newrb(x_dtr',y_dtr',goal,spread,MN,DF);
yest=sim(net,x_dte');
figure(1)
plot([1:size(y_dte,1)],y_dte','b',[1:size(y_dte,1)],yest,'r');
grid on
title('y & y_h_a_t For Test')
legend ('y','y_h_a_t')

MSE_Test = mse(y_dte'-yest)
figure(2)
crosscorr(y_dte'-yest,y_dte'-yest)

Fitting = 100*(1-((norm(yest-y_dte'))/norm(y_dte-mean(y_dte))))


