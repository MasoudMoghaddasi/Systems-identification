clc;clear;close all
load A.mat
load D.mat
load E.mat
rand( 'state' , 0 ) ;
u = [ A( : , [ 1:93 95:end ] ) 
    D( : , [ 1:93 95:end ] ) 
    E( : , [ 1:93 95:end ] ) ] ;
y = [ A( : , 94 ) 
    D( : , 94 )
    E( : , 94 ) ] ;




%%
N = length( y ) ;


%%

Nn = randperm( N ) ;
N_Tr = sort( Nn( 1 : ceil( 0.75 * N ) ) ) ;
N_Te = sort( Nn( ceil( 0.75 * N ) + 1 : end ) ) ;
X_Train = u( N_Tr , : ) ;
X_Test = u( N_Te , : ) ;
Y_Train = y( N_Tr , : ) ;
Y_Test = y( N_Te , : ) ;
[ reg , reg_elim , E ] = backward_elim( X_Train , Y_Train , X_Test , Y_Test , 1:99 , 99 ) ;
figure
plot(E)
title('Error Of BE')
ylabel('Error')
xlabel('Regressor Number')
grid on
n = input( 'Plese Enter Your Selected Dimention:    ' ) ;
reg = sort(reg_elim( end - n : end )) ;
X_Train = X_Train( : , reg );
X_Test = X_Test( : , reg );

theta = ( X_Train' * X_Train )^-1 * X_Train' * Y_Train 

y_hat_test = X_Test * theta ;

plot( y_hat_test , 'r--' );
hold on
plot( Y_Test )
grid on
title('Test Output VS. Sample')
xlabel('Sample')
ylabel('Test Output')
legend('Estimated Output' , 'Real Output' )

figure
e = y_hat_test - Y_Test ;
crosscorr( e , e )
title( 'Autocorrelation OF LS Error' )

MSE=mse( e )

Fitting = ( 1 - ( norm( Y_Test - y_hat_test ) / norm( Y_Test - mean( Y_Test ) ) ) ) * 100 