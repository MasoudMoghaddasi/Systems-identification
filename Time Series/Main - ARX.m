clear all; close all; clc; warning 'off' ;


run_time = 3.99 ;
Ts = 0.01 ;
N = ceil( run_time / Ts ) + 1 ;
Time = 0 : Ts : run_time ;

%% Generating Input
% u = normrnd( 0 , 1 , N , 1 ) ;
% u = -1 + 2 .* rand( N , 1 ) ;
% u = idinput( [ N 1 1] , 'prbs' , [ 0 0.1 ] , [ 0 1 ] ) ;
u = chirp( Time , 0.5 , run_time , 50 )' ;

%% Noise Generation
white_noise = 0*normrnd( 0 , 0.1 , 1 , N ) ;
White_Noise = [ Time' white_noise' ] ;
C = 1 ;
D = 1 ;

%% Real System Part
[ A , B , C , D , A_p , B_p , A_c , B_c , y ] = Plant1( u , N , Ts , white_noise , C , D ) ;


% num_shuff = randperm( N ) ;
% num_test = sort( num_shuff( 1 : ceil( 0.25 * N ) ) , 'ascend' ) ;

num_test = ceil( 0.75 * N ) : N ;

u_test = u( num_test ) ;
u( num_test ) = [] ;
u_train = u ;

y_test = y( num_test ) ;
y( num_test ) = [] ;
y_train = y ;

Time_test = Time( num_test ) ;
Time( num_test ) = [] ;
Time_train = Time ;

%% Estimation Part
n_b = 2 ;
n_a = 2 ;
n_k = 1 ;
% 
[ A_hat , B_hat , y_hat , E_arx , Fitting ] = ARX_IV( y_train , u_train , n_a , n_b , n_k ) ;
A
A_hat
B
B_hat
Fitting

figure
subplot( 211 )
plot( Time_train , y_train ) ;
hold on
plot( Time_train , y_hat , 'r' ) ;
title( 'Real & Estimated Train Output' )
ylabel( 'Magnetude' ) 
xlabel( 'Time(sec)' )


y_hat_test = zeros( length( u_test ) , 1 ) ;
n_b_hat = n_k : n_b ;
n_a_hat = 1 : n_a ;
for t = 1 : length( u_test )          
    Y = Regressor_Gen( n_a_hat , n_b_hat , u_test , y_test , t ) ;
    y_hat_test( t ) = Y * [ A_hat( 2 : end ) B_hat ]' ;
end

Error = y_test - y_hat_test ;
SSE = sum( Error.^2 ) ;
SSE

subplot( 212 )
plot( Time_test , y_test ) ;
hold on
plot( Time_test , y_hat_test , 'r' ) ;
title( 'Real & Estimated Test Output' )
ylabel( 'Magnetude' ) 
xlabel( 'Time(sec)' )
legend( 'Real Output' , 'Estimated Output' ) 

figure
subplot( 211 )
plot( Time_test( 2 : end ) , Error( 2 : end ) ) ;
title( ' Test Error' )
ylabel( 'Magnetude' ) 
xlabel( 'Time(sec)' )
subplot( 212 )
crosscorr( Error( 2 : end ) , Error( 2 : end ) )
title( 'Cross Correlation Of Error' )

Real_Plant = tf( B , A , Ts ) ;
G_closeloop_modeled = tf( B_hat , A_hat , Ts ) ;
fprintf( '\nReal Close Loop System:' )
Real_Plant

fprintf( '\n\nEstimated Close Loop System:' )
G_closeloop_modeled

Gc_D = tf( B_c , A_c , Ts ) ;


fprintf( '\n\nReal Plant:' )
G = tf( B_p , A_p , Ts )

fprintf( '\n\nEstimated Plant:' )
Plant_modeled = zpk( minreal( G_closeloop_modeled / ( Gc_D - G_closeloop_modeled * Gc_D ) ) )
