clear all; close all; clc;

run_time = 400 ;
Ts = 0.1 ;
N = ceil( run_time / Ts ) + 1 ;
Time = 0 : Ts : run_time ;

%% Generating Input
u = 15* normrnd( 0 , 1 , N , 1 ) ;

%% Noise Generation
white_noise = 1 * normrnd( 0 , 0.1 , 1 , N ) ;
C = [ 1 0.2  ] ;
D = 1 ;

%% Real System Part
[ A , B , y ] = Plant2( u , N , Ts , white_noise , C , D ) ;

%% Estimation Part
n_a = 2 ;
n_b = 2 ;
n_c = 1 ;
n_k = 1 ;

[ A_hat , B_hat , C_hat , y_hat , E_armax , J ] = ARMAX_ELS( y , u , n_a , n_b , n_c , n_k ); 
A
A_hat 
B
B_hat
C
C_hat
crosscorr( E_armax , E_armax )
figure
plot( Time , y )
hold on
plot( Time , y_hat , 'r' )
    