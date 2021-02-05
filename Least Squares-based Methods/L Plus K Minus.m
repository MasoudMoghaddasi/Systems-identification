clc;clear all;close all;warning off;

n = 10 ;
Q = 100 ;
N = 1000 ;
Noise_Eff = 1 ;
Normalize = 1 ;
Noise_Var = 0.001 ;

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
flag = 1 ;
reg_sel = [] ;
while( flag ~= 100 )
    reg = reg_sel ;
    L = ceil( ( 7 - length( reg_sel ) ) * rand ) ;
    K = ceil( 3 * rand ) ;

    [ reg_all , ~ ] = forward_sel( x_train , y_train , x_test , y_test , ( 1 : n ) , reg_sel , L );

    [ reg_sel , ~ , EE ] = backward_elim( x_train , y_train , x_test , y_test , reg_all , K );
    
    EEE(flag) = EE(end);
    REG{flag} = reg_sel ;
    m(flag) = length( reg_sel ) ;
    [M h] = sort( m ) ;
    eEe = EEE( h ) ;
    flag_reg = reg_sel ;
%     for i = 1 : length( reg )
%         flag_reg( flag_reg == reg( i ) ) = [] ;
%     end
%     if  isempty(flag_reg) 
%         flag = flag + 1 ;
%     end
flag = flag + 1 ;
end

% semilogy( eEe )
% title('Error Vs. Itteration')
% ylabel('Error')
% xlabel('Itteration')
% grid on
% 
% SS=input('Input Ittration Number:   ');
[~ , o ] = min(eEe);
REG_LK=REG{ h ( o ) }




% reg_sel
Reg_real = [ 1 3 5 8 10 ]