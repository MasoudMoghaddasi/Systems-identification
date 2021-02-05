function [ A_hat , B_hat , C_hat , y_hat , E_armax , Fitting ] = ARMAX_GLS( y , u , n_a , n_b , n_c , n_k )

    N = length( y ) ;
    
    n_b_hat = n_k : n_b ;
    n_a_hat = 1 : n_a ;
    n_c_hat = 1 : n_c ;
    
    y_f = y ;
    u_f = u ;

    J_pre = 1e24 ;
    J = 1e16 ;
    
    n = n_a + n_b - n_k + 1 ;
    
    yu = zeros( N , n + 1 ) ;
    for t = 1 : N
        yu( t , : ) = Regressor_Gen( [ 0 n_a_hat ] , n_b_hat , -u , -y , t ) ;
    end
    
    v = normrnd( 0 , 0.1 , N , 1 ) ;
    counter = 0 ;
    while abs( J - J_pre ) > 1e-5 && counter < 50
        counter = counter + 1 ;
        Z = zeros( N , n ) ;
        for t = 1 : N
            [ Z( t , : ) ] = Regressor_Gen( n_a_hat , n_b_hat , u_f , y_f , t ) ;
        end

        theta_hat = ( Z' * Z )^-1 * Z' * y_f ;    
        
        E_arx = yu * [ 1 ; theta_hat ] ;
        %%
        V = zeros( N , n_c ) ;
        for t = 1 : N
            [ V( t , : ) ] = Regressor_Gen( [] , n_c_hat , v , [] , t ) ;
        end

        C_hat = ( V' * V )^-1 * V' * E_arx ;

        V = zeros( N , n_c + 1 ) ;
        for t = 1 : N
            [ V( t , : ) ] = Regressor_Gen( n_c_hat , 0 , E_arx , v , t ) ;
        end
        v = V * [ C_hat ; 1 ] ;  

        y_hat = zeros( N , 1 ) ;
        y_f = zeros( N , 1 ) ;
        u_f = zeros( N , 1 ) ;
        for t = 1 : N
            Y = Regressor_Gen( n_c_hat , 0 , y , y_f , t ) ;
            y_f( t ) = Y * [ C_hat ; 1 ] ;
            
            U = Regressor_Gen( n_c_hat , 0 , u , u_f , t ) ;
            u_f( t ) = U * [ C_hat ; 1 ] ;
            
            X = Regressor_Gen( n_a_hat , n_b_hat , u , y , t ) ;
            y_hat( t ) = X * theta_hat ;
        end
        J_pre = J ;
        J = sum( ( y - y_hat ).^2 ) ;

    end
    E_armax = zeros( N , 1 ) ;
    for t = 1 : N
        E = Regressor_Gen( n_c_hat , 0 , E_arx , E_armax , t ) ;
        E_armax( t ) = E * [ C_hat ; 1 ] ;   
    end

    y_hat = zeros( N , 1 ) ;
    for t = 1 : N
        E_armax_dynamic = Regressor_Gen( [] , n_c_hat , E_armax , [] , t ) ;
        Y = [ Regressor_Gen( n_a_hat , n_b_hat , u , y , t ) E_armax_dynamic ] ;
        y_hat( t ) = Y * [ theta_hat ; C_hat ]  ;
    end
    
    Fitting = ( 1 - ( norm( y - y_hat ) / norm( y - mean( y ) ) ) ) * 100 ;
    
    A_hat = [ 1 theta_hat( 1 : n_a )' ] ;
    
    B_hat = theta_hat( n_a + 1 : end )' ;
    
    C_hat = [ 1 C_hat' ] ;
end

