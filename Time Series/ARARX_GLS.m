function [ A_hat , B_hat , D_hat , y_hat , E_ararx , Fitting ] = ARARX_GLS( y , u , n_a , n_b , n_d , n_k )

    N = length( y ) ;
    
    n_b_hat = n_k : n_b ;
    n_a_hat = 1 : n_a ;
    n_d_hat = 0 : n_d ;
    
    y_f = y ;
    u_f = u ;

    J_pre = 1e24 ;
    J = 1e16 ;
    
    n = n_a + n_b - n_k + 1 ;
    
    yu = zeros( N , n + 1 ) ;
    Y = zeros( N , n_d + 1 ) ;
    U = zeros( N , n_d + 1 ) ;
    for t = 1 : N
        yu( t , : ) = Regressor_Gen( [ 0 n_a_hat ] , n_b_hat , -u , -y , t ) ;
        Y( t , : ) = Regressor_Gen( [] , n_d_hat , y , [] , t ) ;
        U( t , : ) = Regressor_Gen( [] , n_d_hat , u , [] , t ) ;
    end
    counter = 0 ;
    while abs( J - J_pre ) > 1e-6 && counter < 100
        counter = counter + 1 ;
        Z = zeros( N , n ) ;
        for t = 1 : N
            [ Z( t , : ) ] = Regressor_Gen( n_a_hat , n_b_hat , u_f , y_f , t ) ;
        end

        theta_hat = ( Z' * Z )^-1 * Z' * y_f ;    
        
        E_arx = yu * [ 1 ; theta_hat ] ;
        %%
        V = zeros( N , n_d ) ;
        for t = 1 : N
            [ V( t , : ) ] = Regressor_Gen( n_d_hat( 2 : end ) , [] , [] , E_arx , t ) ;
        end

        D_hat = ( V' * V )^-1 * V' * E_arx ;

        y_f = Y * [ 1 ; D_hat ] ;

        u_f = U * [ 1 ; D_hat ] ;   

        y_hat = zeros( N , 1 ) ;
        for t = 1 : N
            X = Regressor_Gen( n_a_hat , n_b_hat , u , y_hat , t ) ;
            y_hat( t ) = X * theta_hat ;
        end
        J_pre = J ;
        J = sum( ( y - y_hat ).^2 ) ;

    end
    V = zeros( N , n_d + 1 ) ;
    for t = 1 : N
        [ V( t , : ) ] = Regressor_Gen( n_d_hat , [] , [] , E_arx , t ) ;    
    end
    E_ararx = V * [ 1 ; D_hat ] ;

    A_hat = [ 1 theta_hat( 1 : n_a )' ] ;
    
    B_hat = theta_hat( n_a + 1 : end )' ;
    
    D_hat = [ 1 D_hat' ] ;

    BD_hat = conv( B_hat , D_hat ) ;
    AD_hat = conv( A_hat , D_hat ) ;
    n_ad_hat = 1 : n_d + n_a ;
    n_bd_hat = n_k : n_d + n_b ;

    y_hat = zeros( N , 1 ) ;
    for t = 1 : N
        X = Regressor_Gen( n_ad_hat , n_bd_hat , u , y , t ) ;
        y_hat( t ) = X * [ AD_hat( 2 : end ) BD_hat ]'  ;
    end
    Fitting = ( 1 - ( norm( y - y_hat ) / norm( y - mean( y ) ) ) ) * 100 ;
end

