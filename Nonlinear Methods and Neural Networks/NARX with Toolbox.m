clc ;clear all;close all
%% Input & Output
% load 'exchanger.dat'
% u=exchanger( : , 2 );
% y=exchanger( : , 3 );
% n_u = [ 3 5 6 7 8 ] ;
% n_y = 1 ;

load 'ballbeam.dat'
u = ballbeam( : , 1 ) ;
y = ballbeam( : , 2 ) ;
n_y = 1 ;
n_u = [ 0 1 3 5 ] ;


N = length( y ) ;
%%


n =  length( n_u ) ;
x_d  = zeros ( N , n ) ;
for t = 1 : N   
    f = 0 ;
    
    for k = n_u
        f = f + 1 ;
        if t - k > 0
            x_d( t , f ) = u( t - k ) ;
        end
    end

end

x_dtr=x_d(1:round(0.7*size(x_d,1)),:);
y_dtr=y(1:round(0.7*size(x_d,1)),:);
x_dte=x_d(round(0.7*size(x_d,1))+1:end,:);
y_dte=y(round(0.7*size(x_d,1))+1:end,:);
 
cost=[];
ep= 100 ;
for j=ep
    nnn= 45 ;
    for i=nnn
        net=newnarxsp(x_dtr',y_dtr', 0 , n_y ,[i 1],{'tansig','purelin'},'trainlm');
        net.trainparam.epochs=j;
        %net.trainparam.Lr=0.05;
        net.trainparam.goal=0;
        net=train(net,[x_dtr';y_dtr'],y_dtr');
        yest=sim(net,[x_dte';y_dte']);
        e=y_dte'-yest;
        cost=[cost;mse(e)];
    end
end
figure(1)
plot([1:size(yest,2)],y_dte','b',[1:size(yest,2)],yest,'r');
grid on
title('y & y_h_a_t For Test')
legend ('y','y_h_a_t')

figure(2)
crosscorr(e,e)
% figure(4)
% plot(ep,cost');
yes=sim(net,[x_dte';y_dte']);
Fitting=100*(1-((norm(yes-y_dte'))/norm(y_dte-mean(y_dte))))