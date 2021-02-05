clear all; close all; clc;

run_time = 500 ;
Ts = 0.1 ;
N = ceil( run_time / Ts ) + 1 ;
Time = 0 : Ts : run_time ;

%% Generating Input
u = 15* normrnd( 0 , 1 , N , 1 ) ;

%% Noise Generation
white_noise = 0*normrnd( 0 , 0.1 , 1 , N ) ;
[ ~ , C ] = tfdata( c2d( tf( [ 2 2 ] , [ 1 2 3 ] ) , Ts , 'zoh' ) , 'v' ) ;
D = 1 ;

%% Real System Part
[ F , B , y ] = Plant2( u , N , Ts , white_noise , C , D ) ;

%% Estimation Part
n_b = 2 ;
n_f = 2 ;
n_k = 2 ;

[ F_hat , B_hat , y_hat , E_OE , Fitting ] = OE_RLS( y , u , n_f , n_b , n_k ) ;
F
F_hat
B
B_hat
    
crosscorr( E_OE , E_OE ) 

Fitting
figure

plot(y)
hold on
plot(y_hat,'r')