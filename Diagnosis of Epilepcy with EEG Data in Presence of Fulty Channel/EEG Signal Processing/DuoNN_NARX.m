clc;clear; close all;

load A.mat
load D.mat
load E.mat

rand( 'state' , 0 ) ;
u = [ A( : ,[ 93 95 ] ) 
    zeros( 20 , 2 )
    D( : , [ 93 95 ] )
    zeros( 20 , 2 ) 
    E( : , [ 93 95 ] ) ] ;
y = [ A( : , 94 ) 
    zeros( 20 , 1 )
    D( : , 94 )
    zeros( 20 , 1 ) 
    E( : , 94 ) ] ;

n_y = [] ;
n_u{ 1 } = [0 1 2 5] ;
n_u{ 2 } = [0 1 2 4];%1:12 ;
n_u{ 3 } = [];%1:12 ;
n_u{ 4 } = [];%1:12 ;
n_u{ 5 } = [];%1:12 ;
n_u{ 6 } = [];%1:12 ;
%%
ClassNo=1;

%%
n = length( n_y ) ;
for i = 1 : length( n_u )
    n = n + length( n_u{ i } ) ;
end
N = length( y ) ;
phi  = zeros ( N , n ) ;
for t = 1 : N   
    f = 0 ;
    for k = n_y
        f = f + 1 ;
        if t - k > 0
            phi( t , f ) = y( t - k ) ;
        end
    end
    for i = 1 : length( n_u )
        for k = n_u{ i }
            f = f + 1 ;
            if t - k > 0
                phi( t , f ) = u( t - k , i ) ;
            end
        end
    end

end

%%
Nn = randperm( N ) ;
N_Tr = sort( Nn( 1 : ceil( 0.75 * N ) ) ) ;
N_Te = sort( Nn( ceil( 0.75 * N ) + 1 : end ) ) ;
x_train = phi( N_Tr , : ) ;
x_test = phi( N_Te , : ) ;
T = y( N_Tr , : ) ;
Y_Test = y( N_Te , : ) ;

hT=max(T)-min(T);
MinT = min( T ) ;
T = ( T - MinT ) / hT ;

n_train = length( T ) ;
n_test = length( Y_Test ) ;

Min=min(x_train);
h=max(x_train)-min(x_train);
%%
X_train=((x_train-ones(size(x_train,1),1)*Min)./(ones(size(x_train,1),1)*h))*2-1;
X_test=((x_test-ones(size(x_test,1),1)*Min)./(ones(size(x_test,1),1)*h))*2-1;


%%  
[ ~ , in ] = size(X_train) ; 
    
l = 5 ;
alfa = 0.05;
eta = 0.35;
X_b = 1 ;

%% Hidden Layer
W_D = rand(in,l)*0.3 ;
W_Dhb = rand(1,l)*0.3 ;
W_V = rand(in,l)*0.3 ;
W_Vhm = rand(1,l)*0.3 ;

%% Output Layer
W = rand(l,ClassNo)*0.3 ;
W_jb = rand(1,ClassNo)*0.3 ;
W_jm = rand(1,ClassNo)*0.3 ;

%%
W_D_t_1 = zeros(in,l) ;
W_Dhb_t_1 = zeros(1,l) ;
W_V_t_1 = zeros(in,l) ;
W_Vhm_t_1 = zeros(1,l) ;
W_t_1 = zeros(l,ClassNo) ;
W_jb_t_1 = zeros(1,ClassNo) ;
W_jm_t_1 = zeros(1,ClassNo) ;

%%   Pn=S^2*XI
Y_nPAT = 1/in * sum( X_train , 2 );
pn=sum(n_train);
for t = 1 : 40
    if t==1
        k=0;
        mu=1;
    else
        k=K(t-1);
        mu=Mu(t-1);
    end
    
    for p=1:pn
        XI= X_train(p,:) ;
        YI= XI ;

        TP_DhL= YI * W_D ;
        TP_Dhb = X_b * W_Dhb ;
        X_HD = TP_DhL + TP_Dhb ;

        Y_AcP = 1/p * sum( Y_nPAT(1:p,:) ) ;
        TP_VhG = Y_AcP * ones(1,in) * W_V ;
        TP_Vm = Y_AcP * W_Vhm ;   
        X_HV = TP_VhG + TP_Vm ;

        Y_H = 1./(1 + exp( - X_HD - X_HV ));
        TP_jc = Y_H * W ;

        TP_jb = X_b * W_jb ;
        TP_jm = Y_AcP * W_jm ;

        XJ = TP_jc + TP_jb + TP_jm ;

        YJ = 1./( 1 + exp( - XJ ) ) ;

        e(p) = sum( ( T(p,:) - YJ ) .^2 ) ;

        Y_AvPAT = 1/pn * sum( Y_nPAT ) ;

        W_D_t = W_D ;
        W_Dhb_t = W_Dhb ;
        W_V_t = W_V ;
        W_Vhm_t = W_Vhm ;
        W_t = W ;
        W_jb_t = W_jb ;
        W_jm_t = W_jm ;

        delta = YJ .* ( ones(size(YJ)) - YJ ) .* ( T(p,:) - YJ ) ;
        
        W = W + eta *  Y_H' * delta + alfa * ( W - W_t_1 );

        W_jb = W_jb + eta  * delta + alfa * ( W_jb - W_jb_t_1 );

        W_jm = W_jm + mu *  Y_AvPAT * delta + k * ( W_jm - W_jm_t_1 );

        delta_h = Y_H .* ( ones(size(Y_H)) - Y_H ) .* (  delta * W' ) ;

        W_D = W_D + eta *  YI' * delta_h + alfa * ( W_D - W_D_t_1 );

        W_Dhb = W_Dhb + eta * delta_h + alfa * ( W_Dhb - W_Dhb_t_1 );

        W_V = W_V + mu *  ( Y_AvPAT + YI )' * delta_h + k * ( W_V - W_V_t_1 );

        W_Vhm = W_Vhm + mu *  Y_AvPAT * delta_h + k * ( W_Vhm - W_Vhm_t_1 );

        W_D_t_1 = W_D_t ;
        W_Dhb_t_1 = W_Dhb_t ;
        W_V_t_1 = W_V_t ;
        W_Vhm_t_1 = W_Vhm_t ;
        W_t_1 = W_t ;
        W_jb_t_1 = W_jb_t ;
        W_jm_t_1 = W_jm_t ;
        
    end
        
    E(t) = sum( e )/ ( pn * ClassNo )  ;

    Mu(t) = Y_AvPAT + E(t) ;
    if t==1
        Mu0=Mu(t);
    end
    K(t) = Mu0 - Mu(t) ;
    
end


%%
figure
plot(Mu)
hold all
plot(K)
hold off
grid on
legend('Anxiety Coefficient','Confidence Coefficient');
title('Anxiety & Confidence Coefficients VS. Iteration')
xlabel('Iteraion')
ylabel('Anxiety & Confidence Coefficients')

%% Test Part
Y_nPAT = 1/in * sum( X_test , 2 );
pn=sum(n_test);
for p=1:pn
    XI= X_test(p,:) ;
    YI= XI ;

    TP_DhL= YI * W_D ;
    TP_Dhb = X_b * W_Dhb ;
    X_HD = TP_DhL + TP_Dhb ;

    Y_AcP = 1/p * sum( Y_nPAT(1:p,:) ) ;
    TP_VhG = Y_AcP * ones(1,in) * W_V ;
    TP_Vm = Y_AcP * W_Vhm ;   
    X_HV = TP_VhG + TP_Vm ;

    Y_H = 1./(1 + exp( - X_HD - X_HV ));
    TP_jc = Y_H * W ;

    TP_jb = X_b * W_jb ;
    TP_jm = Y_AcP * W_jm ;

    XJ = TP_jc + TP_jb + TP_jm ;

    YJ(p,:) = 1./( 1 + exp( - XJ ) ) ;

end
figure
plot( YJ  * hT + MinT )
hold on
plot(Y_Test,'r')
grid on
title('Test Output VS. Sample')
xlabel('Sample')
ylabel('Test Output')

y_hat_test = YJ * hT + MinT  ;
figure
crosscorr( y_hat_test-Y_Test , y_hat_test-Y_Test )

Fitting = ( 1 - ( norm( Y_Test - y_hat_test ) / norm( Y_Test - mean( Y_Test ) ) ) ) * 100