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
n_u = [ 0 1 3 5 ] ;
n_y = 1 ;

N = length( y ) ;
%%



n = length( n_y ) + length( n_u ) ;
x_d  = zeros ( N , n ) ;
for t = 1 : N   
    f = 0 ;
    for k = n_y
        f = f + 1 ;
        if t - k > 0
            x_d( t , f ) = y( t - k ) ;
        end
    end
    
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


net=newff(x_dtr',y_dtr',[30,1],{'tansig','purelin'},'trainlm');
for j=1:20
    for i=1:size(x_dtr,1)-1 
        e=y_dtr(i,:)-sim(net,x_dtr(i,:)');
        x_dtr(i+1,end)=e;
    end
    net.trainparam.epochs=2;
    net.trainparam.goal=0;
    [net,tr]=train(net,x_dtr',y_dtr');
end



e=y_dtr(i,:)-sim(net,x_dtr');
x_dte(1,end)=e(size(e,2)-1);
yes=[];
for i=1:size(x_dte,1) 
    yes=[yes sim(net,x_dte(i,:)')];
    e=y_dte(i,:)-sim(net,x_dte(i,:)');
    if i==size(x_dte,1)
        break
    else
        x_dtr(i+1,end)=e;
    end
end

figure(2)
plot([1:size(yes,2)],yes,'r',[1:size(yes,2)],y_dte','b');
grid on
title('y & y_h_a_t For Test')
legend ('y','y_h_a_t')

figure(3)
crosscorr(yes-y_dte',yes-y_dte');
MSE_Test = mse(yes-y_dte')
Fitting=100*(1-((norm(yes-y_dte'))/norm(y_dte-mean(y_dte))))