clc;clear all;close all;warning off;

TR_DO = 1 ;
n = 10 ;
Q = 100 ;
N = 1000 ;
Alpha = logspace(-11,-5,100);
% Alpha = 0 : 1e-5 : 0.02 ;
Noise_Eff = 1 ;
Normalize = 1 ;
Noise_Var = 0.0001 ;

%% ------------------------ Generating Input ------------------------------
u = normrnd( 0.5 , 0.5/3 , N , 1 ) ;
u = ( u - min(u) ) / ( max(u) - min(u) ) ;

%% ------------------------ Gnerating Noise -------------------------------
Noise =  normrnd( 0 , Noise_Var , N , 1 ) ;

%% --------------------------- Least Square -------------------------------

u_Test = zeros( floor( length( u ) / Q ) * ( Q - ceil( 0.75 * Q ) ) , 1 ) ;
Noise_Test = zeros( floor( length( u ) / Q ) * ( Q - ceil( 0.75 * Q ) ) , 1 ) ;
theta = zeros( n , floor( length( u ) / Q ) ) ;
X = zeros( ceil( 0.75 * Q ) , n ) ;
X_normalize_term = zeros( n , 1 ) ;
Var_Noise_estim = zeros( 1 , floor( length( u ) / Q ) ) ;
for q = 1 : length( Alpha )
    alpha = Alpha( q ) ;
    for i = 1 : floor( length( u ) / Q )
        Start_TR = ( i - 1 ) * Q + 1 ;
        End_TR = Start_TR + ceil( 0.75 * Q ) - 1 ;
        Start_TE = End_TR + 1 ;
        End_TE = i * Q ;

        u_Train = u( Start_TR : End_TR , 1 ) * TR_DO ;

        y_Train = 1 - u_Train.^2 + 3*u_Train.^4 - 1.5*u_Train.^7 + u_Train.^9 + ...
            Noise_Eff * Noise( Start_TR : End_TR , 1 ) ;

        u_Test( ( i - 1 ) * ( Q - ceil( 0.75 * Q ) ) + 1 : i * ( Q - ceil( 0.75 * Q ) ) , : ) = ...
            u( Start_TE : End_TE , 1 ) ;

        Noise_Test( ( i - 1 ) * ( Q - ceil( 0.75 * Q ) ) + 1 : i * ( Q - ceil( 0.75 * Q ) ) , : ) = ...
            Noise( Start_TE : End_TE , 1 ) ;

        for j = 0 : n - 1
            X_normalize_term( j + 1 , 1 ) = 1 * ( ~Normalize ) + norm( u_Train.^j ) * Normalize ;
            X( : , j + 1 ) = u_Train.^j / X_normalize_term( j + 1 , 1 );        
        end

        theta( : , i ) = ( ( X' * X + alpha * eye( size( X' * X ) ) )^-1 * X' * y_Train ) ./ X_normalize_term ;

%         e_Train = X * theta( : , i ) - y_Train ;
% 
%         Var_Noise_estim( 1 , i ) = ( e_Train' * e_Train ) / ( 0.75 * Q - n ) ;
    end

    u_Test = sort( u_Test ) ;
    y_Test = 1 - u_Test.^2 + 3*u_Test.^4 - 1.5*u_Test.^7 + u_Test.^9 + Noise_Eff * Noise_Test  ;

    Theta(:,q) = mean( theta , 2 ) ;

    X_Test = zeros( floor( length( u ) / Q ) * ( Q - ceil( 0.75 * Q ) ) , n ) ;
    for j = 0 : n - 1
        X_Test( : , j + 1 ) = u_Test.^j ;
    end

    y_hat_Test = X_Test * Theta(:,q) ;

    e = y_Test - y_hat_Test ;

    J( q ) = 1/2 * ( ( e' * e ) + alpha * ( Theta(:,q)' * Theta(:,q) ) ) ;
end
figure;
for i = 1 : 5
    subplot(3,2,i);semilogy(Alpha,Theta(i,:))
    if i~=10
        title(['\theta_' num2str(i)])
    else
        title('\theta_1_0')
    end
    ylabel('\theta')
    xlabel('\alpha')
    grid on
end
figure;
for i = 6 : 10
    subplot(3,2,i-5);semilogy(Alpha,Theta(i,:))
    if i~=10
        title(['\theta_' num2str(i)])
    else
        title('\theta_1_0')
    end
    ylabel('\theta')
    xlabel('\alpha')
    grid on
end