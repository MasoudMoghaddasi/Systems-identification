clc;clear;close all

%% Input & Output

y = [1 : 1000]' ;
u = [3 : 1002]' ;

%%
Nern_Max=input('Please Enter Maximum Number Of Neurons:   ');
MsE=input('Please Enter MSE For RBF:   ');
n_y = input( 'Please Enter Output Dynamics:   ' ) ;
n_u = input( 'Please Enter Input Dynamics:   ' ) ;


N = length( y ) ;
n = length( n_y ) + length( n_u ) ;
phi  = zeros ( N , n ) ;
for t = 1 : N   
    f = 0 ;
    for k = n_u
        f = f + 1 ;
        if t - k > 0
            phi( t , f ) = u( t - k ) ;
        end
    end
    
    for j = n_y
        f = f + 1 ;
        if t - j > 0
           phi( t , f ) = y( t - j ) ;
        end
    end
end

%%
sel = randperm( N ) ;
X_Test = phi( sort( sel( 1 : floor( 0.25 * N ) ) ) , : ) ;
phi( sel( 1 : floor( 0.25 * N ) ) , : ) = [] ;
X_Train = phi ;

Y_Test = y( sort( sel( 1 : floor( 0.25 * N ) ) ) ) ;
y( sel( 1 : floor( 0.25 * N ) ) ) = [] ;
Y_Train = y ;

%%
N_train = size( X_Train , 1 );

sel = randperm( N_train ) ;
X_Train_Test = X_Train( sort( sel( 1 : floor( 0.25 * N_train ) ) ) , : ) ;
X_Train( sort( sel( 1 : floor( 0.25 * N_train ) ) ) , : ) = [ ] ;
X_Train_Train = X_Train ;

Y_Train_Test = Y_Train( sort( sel( 1 : floor( 0.25 * N_train ) ) ) ) ;
Y_Train( sort( sel( 1 : floor( 0.25 * N_train ) ) ) ) = [ ] ;
Y_Train_Train = Y_Train ;

%%

Min = min( X_Train_Train );
h = max( X_Train_Train ) - min( X_Train_Train );
n_train = size( X_Train_Train , 1 ) ;
n_test = size( X_Test , 1 ) ;
%%
X_train_Normal = ( ( X_Train_Train - ones( n_train , 1 ) * Min )./( ones( n_train , 1 ) * h ) ) * 2 - 1 ;
X_test_Normal=((X_Train_Test-ones(size(X_Train_Test,1),1)*Min)./(ones(size(X_Train_Test,1),1)*h))*2-1;
X_test_all_Normal=( ( X_Test - ones( n_test , 1 ) * Min )./( ones( n_test , 1 ) * h ) ) * 2 - 1 ;

%%
net = newrb( X_train_Normal' , Y_Train_Train' , MsE , 1 , Nern_Max , 5 );   
net = init( net ) ;

Out_TR = sim(net,X_train_Normal');
E_TR=Out_TR-Y_Train_Train';
Out_TE = sim(net,X_test_Normal');
E_TE = Out_TE - Y_Train_Test' ;
MSE_TR=mse(E_TR)
MSE_TE=mse(E_TE)


%% Y_hat
y_hat_test = sim( net , X_test_all_Normal' ) ;

%%

fig=1;
Out_TR = sim(net,X_train_Normal');
Out_TE = sim(net,X_test_Normal');

figure(fig)
plot(Y_Train_Train)
hold on
plot(Out_TR,'r--')
set(findall(figure(fig),'type','line'),'linewidth',1)
grid on
title('y & y_h_a_t For Train')
legend ('y','y_h_a_t')
fig=fig+1;


figure(fig)
plot(Y_Train_Test)
hold on
plot(Out_TE,'r--')
set(findall(figure(fig),'type','line'),'linewidth',1)
grid on
title('y & y_h_a_t For Test')
legend ('y','y_h_a_t')
