function [ F_hat , B_hat , y_hat , E_OE , Fitting ] = OE_RLS( y , u , n_f , n_b , n_k )

    N = length( y ) ;
    
    n_b_hat = n_k : n_b ;
    n_f_hat = 1 : n_f ;
    
    y_f = y ;
    u_f = u ;

    J_pre = 1e24 ;
    J = 1e16 ;
    
    n = n_f + n_b - n_k + 1 ;
    
    yu = zeros( N , n + 1 ) ;
    for t = 1 : N
        yu( t , : ) = Regressor_Gen( [ 0 n_f_hat ] , n_b_hat , -u , -y , t ) ;
    end
    
    counter = 0 ;
    while abs( J - J_pre ) > 1e-6 && counter < 100
        counter = counter + 1 ;
        Z = zeros( N , n ) ;
        for t = 1 : N
            [ Z( t , : ) ] = Regressor_Gen( n_f_hat , n_b_hat , u_f , y_f , t ) ;
        end

        theta_hat = ( Z' * Z )^-1 * Z' * y_f ;    
        
        F_hat = theta_hat( 1 : n_f ) ;

        y_hat = zeros( N , 1 ) ;
        y_f = zeros( N , 1 ) ;
        u_f = zeros( N , 1 ) ;
        for t = 1 : N
            Y = Regressor_Gen( n_f_hat , 0 , y , y_f , t ) ;
            y_f( t ) = Y * [ F_hat ; 1 ] ;
            
            U = Regressor_Gen( n_f_hat , 0 , u , u_f , t ) ;
            u_f( t ) = U * [ F_hat ; 1 ] ;
            
            X = Regressor_Gen( n_f_hat , n_b_hat , u , y_hat , t ) ;
            y_hat( t ) = X * theta_hat ;
        end
        J_pre = J ;
        J = sum( ( y - y_hat ).^2 ) ;

    end
    E_arx = yu * [ 1 ; theta_hat ] ;
    E_OE = zeros( N , 1 ) ;
    for t = 1 : N
        E = Regressor_Gen( n_f_hat , 0 , E_arx , E_OE , t ) ;
        E_OE( t ) = E * [ F_hat ; 1 ] ;   
    end

    F_hat = [ 1 theta_hat( 1 : n_f )' ] ;
    
    B_hat = theta_hat( n_f + 1 : end )' ;

    Fitting = ( 1 - ( norm( y - y_hat ) / norm( y - mean( y ) ) ) ) * 100 ;
    
end

