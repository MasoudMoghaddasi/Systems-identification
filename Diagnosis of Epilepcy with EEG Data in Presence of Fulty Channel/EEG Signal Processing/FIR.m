clc;clear;close all
load A.mat
load D.mat
load E.mat
rand( 'state' , 0 ) ;
u = [ A( : , [ 93 95 ] ) 
    zeros( 20 , 2 )
    D( : , [ 93 95 ] )
    zeros( 20 , 2 ) 
    E( : , [ 93 95 ] ) ] ;
y = [ A( : , 94 ) 
    zeros( 20 , 1 )
    D( : , 94 )
    zeros( 20 , 1 ) 
    E( : , 94 ) ] ;


n_u{ 1 } = [0 5 7 9 11] ;
n_u{ 2 } = [0 2 6 7 11] ;
n_y = [] ;

%%
ClassNo=1;

%%
n = length( n_y ) ;
for i = 1 : length( n_u )
    n = n + length( n_u{ i } ) ;
end
N = length( y ) ;
phi  = zeros ( N , n ) ;
for t = 1 : N   
    f = 0 ;
    for k = n_y
        f = f + 1 ;
        if t - k > 0
            phi( t , f ) = y( t - k ) ;
        end
    end
    for i = 1 : length( n_u )
        for k = n_u{ i }
            f = f + 1 ;
            if t - k > 0
                phi( t , f ) = u( t - k , i ) ;
            end
        end
    end

end

%%

Nn = randperm( N ) ;
N_Tr = sort( Nn( 1 : ceil( 0.75 * N ) ) ) ;
N_Te = sort( Nn( ceil( 0.75 * N ) + 1 : end ) ) ;
X_Train = phi( N_Tr , : ) ;
X_Test = phi( N_Te , : ) ;
Y_Train = y( N_Tr , : ) ;
Y_Test = y( N_Te , : ) ;

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
title( 'Autocorrelation OF FIR Error' )

MSE=mse( e )

Fitting = ( 1 - ( norm( Y_Test - y_hat_test ) / norm( Y_Test - mean( Y_Test ) ) ) ) * 100 