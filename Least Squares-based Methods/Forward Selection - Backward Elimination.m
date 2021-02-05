clc;clear all;close all;warning off;

W = 1 ;
n = 10 ;
Q = 100 ;
N = 1000 ;
alpha = 0 ;
Noise_Eff = 1 ;
Normalize = 0 ;
Noise_Var = 0.0001 ;

%% ------------------------ Generating Input ------------------------------
u = normrnd( 0.5 , 0.5/3 , N , 1 ) ;
u = ( u - min(u) ) / ( max(u) - min(u) ) ;

%% ------------------------ Gnerating Noise -------------------------------
Noise =  normrnd( 0 , Noise_Var , N , 1 ) ;


%% --------------------------- Least Square -------------------------------

y = 1 - u.^2 + 3*u.^4 - 1.5*u.^7 + u.^9 + Noise_Eff * Noise ;
u_Train = u( 1 : ceil( 0.75 * Q ) , 1 ) ;
u_Test = u( ceil( 0.75 * Q ) + 1 : Q , 1 ) ;
y_train = y( 1 : ceil( 0.75 * Q ) , 1 ) ;
y_test = y( ceil( 0.75 * Q ) + 1 : Q , 1 ) ;

for j = 0 : n - 1
    X_normalize_term( j + 1 , 1 ) = 1 * ( ~Normalize ) + norm( u_Train.^j ) * Normalize ;
    x_train( : , j + 1 ) = u_Train.^j / X_normalize_term( j + 1 , 1 );        
end

for j = 0 : n - 1
    x_test( : , j + 1 ) = u_Test.^j / X_normalize_term( j + 1 , 1 );        
end

reg_all = 1:n ;
reg_sel = [] ;
L=10;
K=10;

[ reg_all , E ] = forward_sel( x_train , y_train , x_test , y_test , reg_all , reg_sel , L );
semilogy(E)
title('Error Of FS')
ylabel('Error')
xlabel('Regressor Number')
grid on
reg_all
[ reg , reg_elim , E ] = backward_elim( x_train , y_train , x_test , y_test , reg_all , K );
figure
semilogy(E)
title('Error Of BE')
ylabel('Error')
xlabel('Regressor Number')
grid on
reg_elim


Reg_real = [ 1 3 5 8 10 ]