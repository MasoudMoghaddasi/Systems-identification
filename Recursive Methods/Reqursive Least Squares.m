clc;clear all;close all;warning off;

n = 5 ;
N = 1000 ;
TR_DO = 0.7 ;
Noise_Eff = 1 ;
Noise_Var = 0.001 ;
Landa = 1 ;
Q = zeros( n , n ) ;


%% ------------------------ Generating Input ------------------------------
u = normrnd( 0.5 , 0.5/3 , N , 1 ) ;
u = ( u - min(u) ) / ( max(u) - min(u) ) ;

%% ------------------------ Gnerating Noise -------------------------------
Noise =  normrnd( 0 , Noise_Var , N , 1 ) ;



%%
u_Train = u( 1 : ceil( 0.75 * N ) , 1 ) * TR_DO ;

theta_real = [ 1 -1 3 -1.5 1 ]' * ones( 1 , ceil( 0.75 * N ) ) ;

y_Train = theta_real( 1 )' + theta_real( 2 )' .* u_Train.^2 + ...
    theta_real( 3 )' .* u_Train.^4 + theta_real( 4 )' .* u_Train.^7 + ...
     theta_real( 5 )' .* u_Train.^9 + Noise_Eff * Noise( 1 : ceil( 0.75 * N ) , 1 ) ;


%%

theta = rand ( n , 1) ;
P = 10^5 * eye( n ) ;
Eig_P = eig( P ) ;

for i = 1 : ceil( 0.75 * N )
    phi( : , i ) = [ 1 , u_Train(i)^2 , u_Train(i)^4 , u_Train(i)^7 , u_Train(i)^9 ] ;
    [ theta( : , i+1 ) , P ] = RLS( theta( : , i ) , P , phi( : , i ) , y_Train( i ) , Landa , Q );
    Eig_P( : , i + 1 ) = real( eig( P ) ) ;
end
figure
for i = 1 : n
    subplot( ceil(n/2) , 2 * ( n >= 2 ) + ( n < 2 ) , i )
    stairs ( ( 1 : ceil( 0.75 * N ) ) , theta( i , 1 : end - 1 ) ) ;
    hold on
    stairs ( ( 1 : ceil( 0.75 * N ) ) , theta_real( i , : ) , ' r ' ) ;
    title( ['\theta_' num2str(i)] )
    ylabel( ' Parameter ' )
    xlabel( ' Sample NO. ' )
    grid on
end
legend( ' Estimated \theta ' , ' Real \theta ' )
    
figure
for i = 1 : n
    subplot( ceil(n/2) , 2 * ( n >= 2 ) + ( n < 2 ) , i )
    stairs ( ( 1 : ceil( 0.75 * N ) ) , Eig_P( i , 1 : end - 1 ) ) ;
    title( ['\lambda_' num2str(i)] )
    ylabel( ' Parameter ' )
    xlabel( ' Sample NO. ' )
    grid on
end