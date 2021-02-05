clc ;clear all;close all
%% Input & Output
% load 'exchanger.dat'
% u=exchanger( : , 2 );
% y_d=exchanger( : , 3 );
% n_u = [ 3 5 6 7 8 ] ;
% n_y = 1 ;

load 'ballbeam.dat'
u = ballbeam( : , 1 ) ;
y_d = ballbeam( : , 2 ) ;
n_y = 1 ;
n_u = [ 0 1 3 5 ] ;

N = length( y_d ) ;
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
y_dtr=y_d(1:round(0.7*size(x_d,1)),:);
x_dte=x_d(round(0.7*size(x_d,1))+1:end,:);
y_dte=y_d(round(0.7*size(x_d,1))+1:end,:);

net=newnarx(x_dtr',y_dtr',0,n_y,[30 1]);
net.trainparam.epochs=20;
net.trainparam.goal=0;
[net,tr]=train(net,x_dtr',y_dtr');
yest=sim(net,x_dte');
figure(1)
plot([1:size(yest,2)],y_dte','b',[1:size(yest,2)],yest,'r');
grid on
title('y & y_h_a_t For Test')
legend ('y','y_h_a_t')



e=y_dte'-yest;
figure(2)
crosscorr(e,e)

Fitting=100*(1-((norm(yest-y_dte'))/norm(y_dte-mean(y_dte))))