clc;clear;close all

%% Input & Output
% load 'exchanger.dat'
% phi = exchanger( : , 2 ) ;
% y = exchanger( : , 3 ) ;

load 'ballbeam.dat'
phi = ballbeam( : , 1 ) ;
y = ballbeam( : , 2 ) ;

N = length( y ) ;
%%
Nern_Num_Lim = input( 'Please Enter Minimum And Maximum Number Of Neurons:[min max]   ' ) ;
Nern_Step = input( 'Please Enter Step For Encreasing Neurons:   ' ) ;
Epochs = input( 'Please Enter Number Of Epochs:   ' ) ;


%%
sel = 1 : N ;
X_Test = phi( sort( sel( ceil( 0.85 * N ) + 1 : end ) ) , : ) ;
phi( sel( ceil( 0.85 * N ) + 1 : end ) , : ) = [] ;
X_Train = phi ;

Y = y ;
Y_Test = Y( sort( sel( ceil( 0.85 * N ) + 1 : end ) ) ) ;
Y( sel( ceil( 0.85 * N ) + 1 : end ) ) = [] ;
Y_Train = Y ;

%%
N_train = size( X_Train , 1 );

sel = randperm( N_train ) ;
X_Train_Test = X_Train( sort( sel( 1 : floor( 0.2 * N_train ) ) ) , : ) ;
X_Train( sort( sel( 1 : floor( 0.2 * N_train ) ) ) , : ) = [ ] ;
X_Train_Train = X_Train ;

Y_Train_Test = Y_Train( sort( sel( 1 : floor( 0.2 * N_train ) ) ) ) ;
Y_Train( sort( sel( 1 : floor( 0.2 * N_train ) ) ) ) = [ ] ;
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
count = 0 ;
for KN = Nern_Num_Lim( 1 ) : Nern_Step : Nern_Num_Lim( 2 )  
    count = count + 1 ;
    [ W , b , phi , MSE_train , MSE_test ] = MLP_BP( X_train_Normal , Y_Train_Train , X_test_Normal , Y_Train_Test , KN , Epochs ) ;
    Perm = randperm( n_train ) ;
    X_train_Normal = X_train_Normal( Perm , : ) ;
    Y_Train_Train = Y_Train_Train( Perm , : ) ;
    MSE_TE( count ) = MSE_test( end ) ;
    MSE_TR( count ) = MSE_train( end ) ;
end


%%

fig=1;
figure(fig)
plot((Nern_Num_Lim(1):Nern_Step:Nern_Num_Lim(2)),MSE_TE,'r')
hold on
plot((Nern_Num_Lim(1):Nern_Step:Nern_Num_Lim(2)),MSE_TR)
grid on
xlabel('Neuron')
ylabel('MSE')
title('MSE Per Neuron')
legend ('Test','Train')
fig=fig+1;

figure(fig)
plot(1:Epochs,MSE_test,'r')
hold on
plot(1:Epochs,MSE_train)
grid on
xlabel('Epochs')
ylabel('MSE')
title('MSE Per Epochs For Optimal Number Of Neuron')
legend ('Test','Train')
fig=fig+1;


%% Validation Part
y_hat_test = Simulate( W , b , X_test_all_Normal ) ;
y_hat_train = Simulate( W , b , X_train_Normal ) ;

figure(fig)
plot(Y_Train_Train)
hold on
plot(y_hat_train,'r--')
grid on
title('y & y_h_a_t For Train')
legend ('y','y_h_a_t')
fig=fig+1;


figure(fig)
plot(Y_Test)
hold on
plot(y_hat_test,'r--')
grid on
title('y & y_h_a_t For Test')
legend ('y','y_h_a_t')

figure

crosscorr( y_hat_test-Y_Test , y_hat_test-Y_Test )

Fitting = ( 1 - ( norm( Y_Test - y_hat_test ) / norm( Y_Test - mean( Y_Test ) ) ) ) * 100

