function [ A_hat , B_hat , y_hat , E_arx , Fitting ] = ARX_IV( y , u , n_a , n_b , n_k )

    N = length( y ) ;
    
    n_b_hat = n_k : n_b ;
    n_a_hat = 1 : n_a ;

    J_pre = 1e24 ;
    J = 1e16 ;
    
    n = n_a + n_b - n_k + 1 ;
    
    yu = zeros( N , n + 1 ) ;
    X = zeros( N , n ) ;
    for t = 1 : N
        yu( t , : ) = Regressor_Gen( [ 0 n_a_hat ] , n_b_hat , -u , -y , t ) ;
        X( t , : ) = Regressor_Gen( n_a_hat , n_b_hat , u , y , t ) ;
    end

    theta_hat = ( X' * X )^-1 * X' * y ;
    counter = 0 ;
    while abs( J - J_pre ) > eps && counter <= 50
        counter = counter + 1 ;
        y_u = zeros( N , 1 ) ;
        Z = zeros( N , n ) ;
        for t = 1 : N
            Z( t , : ) = Regressor_Gen( n_a_hat , n_b_hat , u , y_u , t ) ;
            y_u( t ) =  Z( t , : ) * theta_hat ;
        end

        theta_hat = ( Z' * X )^-1 * Z' * y ; 
        
        y_hat = zeros( N , 1 ) ;

        for t = 1 : N            
            Y = Regressor_Gen( n_a_hat , n_b_hat , u , y , t ) ;
            y_hat( t ) = Y * theta_hat ;
        end
        J_pre = J ;
        J = sum( ( y - y_hat ).^2 ) ;

    end
    E_arx = yu * [ 1 ; theta_hat ] ;

    A_hat = [ 1 theta_hat( 1 : n_a )' ] ;
    
    B_hat = theta_hat( n_a + 1 : end )' ;
    
    Fitting = ( 1 - ( norm( y - y_hat ) / norm( y - mean( y ) ) ) ) * 100 ;
    
end

