function [ A_hat , B_hat , C_hat , y_hat , E_armax , Fitting ] = ARMAX_ELS( y , u , n_a , n_b , n_c , n_k )

    N = length( y ) ;
    
    n_b_hat = n_k : n_b ;
    n_a_hat = 1 : n_a ;
    n_c_hat = 1 : n_c ;

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
    
    E_arx = yu * [ 1 ; theta_hat ] ;
       
    E_armax = E_arx ;
    
    theta_armax = [ theta_hat ; zeros( n_c , 1 ) ] ;     
    y_hat = zeros( N , 1 ) ;
    for t = 1 : N
        E_armax_dynamic = Regressor_Gen( [] , n_c_hat , E_armax , [] , t ) ;
        Y = [ Regressor_Gen( n_a_hat , n_b_hat , u , y , t ) E_armax_dynamic ] ;
        y_hat( t ) = Y * theta_armax  ;
    end
    J = sum( ( y - y_hat ).^2 ) ;
    counter = 0 ;
        while  norm( E_armax ) > 1e-10 && counter < 100
            counter = counter + 1 ;

            E_arx_dynamic = zeros( N , length( n_c_hat ) ) ;
            for t = 1 : N
                E_arx_dynamic( t , : ) = Regressor_Gen( [] , n_c_hat , E_armax , [] , t ) ;
            end
            X_armax = [ X , E_arx_dynamic ] ;

            theta_armax = ( X_armax' * X_armax )^-1 * X_armax' * y ;    

            E_armax = zeros( N , 1 ) ;

            y_hat = zeros( N , 1 ) ;
            for t = 1 : N
    %             E_armax_dynamic = Regressor_Gen( [] , n_c_hat , y - y_hat , [] , t ) ;
                E_armax_dynamic = Regressor_Gen( [] , n_c_hat , E_armax , [] , t ) ;
                E_armax( t ) = [ yu( t , : ) , -E_armax_dynamic ] * [ 1 ; theta_armax ] ;

                Y = [ Regressor_Gen( n_a_hat , n_b_hat , u , y , t ) E_armax_dynamic ] ;
                y_hat( t ) = Y * theta_armax  ;

    %             E_armax( t ) = y( t ) - y_hat( t ) ;
            end
        J_pre = J ;
        J = sum( ( y - y_hat ).^2 ) ;

        end
        
    Fitting = ( 1 - ( norm( y - y_hat ) / norm( y - mean( y ) ) ) ) * 100 ;
        
    B_hat = theta_armax( n_a + 1 : end - n_c )' ;
    A_hat = [ 1  theta_armax( 1 : n_a )' ] ;
    C_hat = [ 1 theta_armax( end - n_c + 1 : end )' ] ;
    
end

