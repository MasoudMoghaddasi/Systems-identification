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

cost=[];
spread=[0.001:0.01:1];
for i=spread
    net = newgrnn(x_dtr',y_dtr',i);
    yest=sim(net,x_dte');
    cost=[cost mse(y_dte'-yest)];
end
figure(1)
semilogy(spread,cost,'-+');
title( 'MSE Vs. Spread' )
grid on
[c,I]=min(cost);
net = newgrnn(x_dtr',y_dtr',spread(I));
yest=sim(net,x_dte');
figure(2)
plot([1:size(y_dte,1)],y_dte','b',[1:size(y_dte,1)],yest,'r');
grid on
title('y & y_h_a_t For Test')
legend ('y','y_h_a_t')

figure(3)
crosscorr(y_dte'-yest,y_dte'-yest);

MSE_Test = mse(y_dte'-yest)


Fitting=100*(1-((norm(yest-y_dte'))/norm(y_dte-mean(y_dte))))
