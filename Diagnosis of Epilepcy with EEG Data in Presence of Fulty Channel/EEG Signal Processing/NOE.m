clc;clear; close all;

load A.mat
load D.mat
load E.mat


u = [ A( : ,[ 93 95 ] ) 
    zeros( 20 , 2 )
    D( : , [ 93 95 ] )
    zeros( 20 , 2 ) 
    E( : , [ 93 95 ] ) ] ;
y = [ A( : , 94 ) 
    zeros( 20 , 1 )
    D( : , 94 )
    zeros( 20 , 1 ) 
    E( : , 94 ) ] ;


n_u{ 1 } = [0 1 2 5] ;
n_u{ 2 } = [0 1 2 4];%1:12 ;
%%
ClassNo=1;

%%
n = 0 ;
for i = 1 : length( n_u )
    n = n + length( n_u{ i } ) ;
end
N = length( y ) ;
phi  = zeros ( N , n ) ;
for t = 1 : N   
    f = 0 ;
    for i = 1 : length( n_u )
        for k = n_u{ i }
            f = f + 1 ;
            if t - k > 0
                phi( t , f ) = u( t - k , i ) ;
            end
        end
    end

end


x_dtr=phi(1:round(0.7*size(phi,1)),:);
y_dtr=y(1:round(0.7*size(phi,1)),:);
x_dte=phi(round(0.7*size(phi,1))+1:end,:);
y_dte=y(round(0.7*size(phi,1))+1:end,:);

net=newnarx(x_dtr',y_dtr',0,[1 2],19);
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