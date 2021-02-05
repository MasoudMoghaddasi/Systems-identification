clear all; close all; clc;

run_time = 500 ;
Ts = 0.1 ;
N = ceil( run_time / Ts ) + 1 ;
Time = 0 : Ts : run_time ;

%% Generating Input
u = 15* normrnd( 0 , 1 , N , 1 ) ;

%% Noise Generation
white_noise = 0*normrnd( 0 , 0.1 , 1 , N ) ;
C = 1 ;
D = [ 1 -0.7 ] ;

%% Real System Part
[ A , B , y ] = Plant2( u , N , Ts , white_noise , C , D ) ;

%% Estimation Part
n_a = 2 ;
n_b = 2 ;
n_d = 1 ;
n_k = 1 ;

[ A_hat , B_hat , D_hat , y_hat , E_ararx , Fitting ] = ARARX_GLS( y , u , n_a , n_b , n_d , n_k ) ;

A
A_hat
B
B_hat
D
D_hat
crosscorr( E_ararx , E_ararx )
Fitting
figure

plot(y)
hold on
plot(y_hat,'r')

