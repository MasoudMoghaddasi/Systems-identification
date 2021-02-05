clear all; close all; clc; warning 'off' ;

randn('state',0)
run_time = 3.99 ;
Ts = 0.01 ;
N = ceil( run_time / Ts ) + 1 ;
Time = 0 : Ts : run_time ;

%% Generating Input
% u = normrnd( 0 , 1 , N , 1 ) ;
% u = -1 + 2 .* rand( N , 1 ) ;
% u = idinput( [ N 1 1] , 'prbs' , [ 0 0.1 ] , [ 0 1 ] ) ;
u = chirp( Time , 0.1 , run_time , 100 )' ;

%% Noise Generation
white_noise = 1*normrnd( 0 , 0.001 , 1 , N ) ;
White_Noise = [ Time' white_noise' ] ;
C = 1 ;
D = 1 ;

%% Real System Part
[ A , B , C , D , A_p , B_p , A_c , B_c , y ] = Plant1_delay( u , N , Ts , white_noise , C , D ) ;


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
n_c = 1 ;
n_d = 2 ;
n_f = n_a ;
n_k = 3 ;

%% BJ PART

[ F_hat , B_hat , D_hat , C_hat , y_hat , E_BJ , Fitting ] = BJ_GD( y_train , u_train , n_f , n_b , n_d , n_c , n_k ) ;
F = A
F_hat 
B
B_hat 
C
C_hat 
D
D_hat 

FC = conv( F_hat , C_hat ) ;
L_FC = length( FC ) ;
n_fc_hat = 1 : L_FC - 1 ;
BD = conv( B_hat , D_hat ) ;
L_BD = length( BD ) ;
n_bd_hat = n_k : L_BD + n_k - 1 ;
FD = conv( F_hat , D_hat ) ;
L_FD = length( FD ) ;
FC_FD = [ zeros( 1 , L_FD - L_FC ) FC ] - [ zeros( 1 , L_FC - L_FD ) FD ] ;
L_FC_FD = length( FC_FD ) ;
n_fc_fd_hat = 0 : L_FC_FD - 1 ;

y_hat_test = zeros( length( u_test ) , 1 ) ;
for t = 1 : length( u_test )
    y_hat_test( t ) = Updater( FC , BD , FC_FD , n_fc_hat , n_bd_hat , n_fc_fd_hat , -y_hat_test , u_test , y_test , t ) ;
end

A_hat = F_hat ;
%%
Fitting

Error = y_test - y_hat_test ;
SSE = sum( Error.^2 ) ;
SSE


%% Plotting Part

figure
subplot( 211 )
plot( Time_train , y_train ) ;
hold on
plot( Time_train , y_hat , 'r' ) ;
title( 'Real & Estimated Train Output' )
ylabel( 'Magnetude' ) 
xlabel( 'Time(sec)' )


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
