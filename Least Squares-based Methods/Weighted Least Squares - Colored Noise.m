clc;clear all;close all;warning off;

W = 1 ;
n = 10 ;
Q = 100 ;
N = 1000 ;
Noise_Eff = 1 ;
Normalize = 1 ;
Noise_Var = 0.0001 ;

%%------------------------ Generating Input ------------------------------
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
for q = 1 : 20
    for i = 1 : floor( length( u ) / Q )
        Start_TR = ( i - 1 ) * Q + 1 ;
        End_TR = Start_TR + ceil( 0.75 * Q ) - 1 ;
        Start_TE = End_TR + 1 ;
        End_TE = i * Q ;

        u_Train = u( Start_TR : End_TR , 1 )  ;

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

        theta( : , i ) = ( ( X' * W * X  )^-1 * X' * W * y_Train ) ./ X_normalize_term ;

        e_Train = X * theta( : , i ) - y_Train ;
        COV_e( : , : , i ) = cov( e_Train' ) ;

    %     Var_Noise_estim( 1 , i ) = ( e_Train' * W * e_Train ) / ( 0.75 * Q - n ) ;
    end
    W = mean( COV_e )^-1 ;
end

u_Test = sort( u_Test ) ;
y_Test = 1 - u_Test.^2 + 3*u_Test.^4 - 1.5*u_Test.^7 + u_Test.^9 + Noise_Eff * Noise_Test  ;

Theta = mean( theta , 2 ) ;

X_Test = zeros( floor( length( u ) / Q ) * ( Q - ceil( 0.75 * Q ) ) , n ) ;
for j = 0 : n - 1
    X_Test( : , j + 1 ) = u_Test.^j ;
end

y_hat_Test = X_Test * Theta ;

e = y_Test - y_hat_Test ;

J = 1/2 * ( ( e' * e ) ) ;

%% ----------------------- ErrorBars Computation --------------------------

% varN_es = mean( Var_Noise_estim ) ;

% cov_Theta = varN_es * ( X_Test' * W * X_Test + alpha * eye( size( X_Test' * W * X_Test ) ) )^-1 ...
%     * X_Test' * W * W * X_Test * ( X_Test' * W * X_Test + alpha * eye( size( X_Test' * W * X_Test ) ) )^-1 ;

cov_Theta = cov(theta');
cov_y = X_Test * cov_Theta * X_Test' ;

max_bar = y_hat_Test + sqrt( ( diag( cov_y ) ) ) ;
min_bar = y_hat_Test - sqrt( ( diag( cov_y ) ) ) ;


%% -------------------------Table Of Results------------------------------

fprintf('\n  Least Square Results :\n\n')
fprintf('    Parameter       Real Value   Estimated Value\n'  )
fprintf('      Theta0         % 1.4f        % 1.4f\n',Theta(1) , 1 )
fprintf('      Theta1         % 1.4f        % 1.4f\n',Theta(2) , 0 )
fprintf('      Theta2         % 1.4f        % 1.4f\n',Theta(3) , -1 )
fprintf('      Theta3         % 1.4f        % 1.4f\n',Theta(4) , 0 )
fprintf('      Theta4         % 1.4f        % 1.4f\n',Theta(5) , 3 )
fprintf('      Theta5         % 1.4f        % 1.4f\n',Theta(6) , 0 )
fprintf('      Theta6         % 1.4f        % 1.4f\n',Theta(7) , 0 )
fprintf('      Theta7         % 1.4f        % 1.4f\n',Theta(8) , -1.5 )
fprintf('      Theta8         % 1.4f        % 1.4f\n',Theta(9) , 0 )
fprintf('      Theta9         % 1.4f        % 1.4f\n',Theta(10), 1 )
fprintf('\n\n     Parameter           Value\n'  )
fprintf('        J            % 1.8f  \n'  ,    J     )


%% -------------------------Ploting Results-------------------------------
% hist_sec = -0.4:0.05:1.4;
% hist(u,hist_sec) ;
% title('Input Histogram') ;
% ylabel('Count Of Elements') ;
% xlabel('Elements Value') ;
% 
% figure
% plot(u)
% title('Input') ;
% xlabel('Number Of Element') ;
% ylabel('Elements Value') ;
% 
% figure
% plot(Noise)
% title('Noise') ;
% xlabel('Number Of Element') ;
% ylabel('Elements Value') ;

figure
plot( u_Test , y_hat_Test , 'r' )
hold on
plot( u_Test , y_Test , '-.' )
grid on
xlabel( 'u' )
ylabel( 'y' )
title( 'y & y_h_a_t For Test' )
legend( 'y_h_a_t' , 'y' ) ;

figure
plot( u_Test , e , 'r' )
grid on
xlabel( 'u' )
ylabel( 'e' )
title( 'Error' )

figure
crosscorr( e , e )
title( 'Cross Correlation Of Error' )


figure
plot( u_Test , y_hat_Test , 'k' )
hold on
plot( u_Test , y_Test , ' y ' )
hold on
plot( u_Test , max_bar , 'g--' )
plot( u_Test, min_bar , 'r--' )
grid on
xlabel( 'u' )
ylabel( 'y' )
title( 'Errorbars' )