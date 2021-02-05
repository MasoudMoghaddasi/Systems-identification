function [ F_hat , B_hat , D_hat , C_hat , y_hat , E_BJ , Fitting ] = BJ_GD( y , u , n_f , n_b , n_d , n_c , n_k )

 
    

    N = length( y ) ;

    n_b_hat = n_k : n_b ;
    n_f_hat = 1 : n_f ;
    n_c_hat = 0 : n_c ;
    n_d_hat = 0 : n_d ;

    n = n_f + n_b - n_k + 1 ;
    X = zeros( N , n ) ;
    for t = 1 : N
        X( t , : ) = Regressor_Gen( n_f_hat , n_b_hat , u , y , t ) ;
    end
    theta_hat = ( X' * X )^-1 * X' * y ;
    
    F_hat = [ 1 theta_hat( 1 : n_f )' ] 
        F_hat = F ;
    B_hat = theta_hat( n_f + 1 : end )' 
    B_hat = B ;
    
    C_hat = [ 1 rand( 1 , 1 : n_c ) ] 
    
    D_hat = [ 1 rand( 1 , 1 : n_d ) ] 
    
    
    alfa = 0.00001 ;
    beta = 0.1 ;
    
    F_hat_2 = [ 1 theta_hat( 1 : n_f )' ] ;
    F_hat_1 = [ 1 theta_hat( 1 : n_f )' ] ;
    B_hat_2 = theta_hat( n_f + 1 : end )' ;
    B_hat_1 = theta_hat( n_f + 1 : end )' ;
    C_hat_2 = [ 1 rand( 1 , 1 : n_c ) ] ;
    C_hat_1 = [ 1 rand( 1 , 1 : n_c ) ] ;
    D_hat_2 = [ 1 rand( 1 , 1 : n_d ) ] ;
    D_hat_1 = [ 1 rand( 1 , 1 : n_d ) ] ;
    for t = 1 : N
        
        FC = conv( F_hat , C_hat ) ;
        L_FC = length( FC ) ;
        n_fc_hat = 1 : L_FC - 1 ;
        BD = conv( B_hat , D_hat ) ;
        L_BD = length( BD ) ;
        n_bd_hat = n_k : L_BD + n_k - 1 ;
        FD = conv( F_hat , D_hat ) ;
        L_FD = length( FD ) ;
        FC_FD = [ zeros( 1 , L_FD - L_FC ) FC ] - [ zeros( 1 , L_FC - L_FD ) FD ] ;
        L_FC_FD = length( FC_FD ) ;
        n_fc_fd_hat = 0 : L_FC_FD - 1 ;
        
        y_hat = zeros( N , 1 ) ;
        y_hat_f = zeros( N , n_f ) ;
        y_hat_b = zeros( N , n_b + 1 - n_k ) ;
        y_hat_c = zeros( N , n_c + 1 ) ;
        y_hat_d = zeros( N , n_d ) ;
        
        for k = 1 : t
            y_hat( k ) = Updater( FC , BD , FC_FD , n_fc_hat , n_bd_hat , n_fc_fd_hat , -y_hat , u , y , k ) ;
         
            for i = n_f_hat
                y_hat_f( k , i ) = Updater( FC , D_hat , C_hat , n_fc_hat , i + n_d_hat , i + n_c_hat , -y_hat_f( : , i ) , -y , -y_hat , k ) ;
            end
    
            for i = n_b_hat
                y_hat_b( k , i + 1 - n_k ) = Updater( FC , D_hat , [] , n_fc_hat , i + n_d_hat , [] , -y_hat_b( : , i + 1 - n_k ) , u , [] , k ) ;
            end
            
            for i = n_c_hat( 2 : end )
                y_hat_c( k , i ) = Updater( C , 1 , 1 , n_c_hat( 2 : end ) , i , i , -y_hat_c( : , i ) , y , -y_hat , k ) ;
            end
            
            for i = n_d_hat( 2 : end )
                y_hat_d( k , i ) = Updater( FC , B_hat , F_hat , n_fc_hat , i + n_b_hat , i + [ 0 n_f_hat ] , -y_hat_d( : , i ) , u , -y , k ) ;
            end
        end
        
        for i = n_f_hat
            F_hat( i + 1 ) = F_hat_1( i + 1 ) - alfa * y_hat_f( t , i ) + beta * ( F_hat_2( i + 1 ) - F_hat_1( i + 1 ) ) ;
        end
    
        for i = n_b_hat - n_k
            B_hat( i + 1 ) = B_hat_1( i + 1 ) - alfa * y_hat_b( t , i + 1 ) + beta * ( B_hat_2( i + 1 ) - B_hat_1( i + 1 ) ) ;
        end
    
        for i = n_c_hat( 2 : end )
            C_hat( i + 1 ) = C_hat_1( i + 1 ) - alfa * y_hat_c( t , i + 1 ) + beta * ( C_hat_2( i + 1 ) - C_hat_1( i + 1 ) ) ;
        end
    
        for i = n_d_hat( 2 : end )
            D_hat( i + 1 ) = D_hat_1( i + 1 ) - alfa * y_hat_d( t , i ) + beta * ( D_hat_2( i + 1 ) - D_hat_1( i + 1 ) ) ;
        end
        F_hat_2 = F_hat_1 ;
        B_hat_2 = B_hat_1 ;
        C_hat_2 = C_hat_1 ;
        D_hat_2 = D_hat_1 ;
        
        F_hat_1 = F_hat ;
        B_hat_1 = B_hat ;
        C_hat_1 = C_hat ;
        D_hat_1 = D_hat ;
        
    end
    data = iddata( y , u ) ;
    m = bj( data , [ n_b n_c n_d n_f n_k ] ) ;

    %% 
    F_hat = m.f ;
    B_hat = m.b ;

    C_hat = m.c ;
    D_hat = m.d ;
    FC = conv( F_hat , C_hat ) ;
    L_FC = length( FC ) ;
    n_fc_hat = 1 : L_FC - 1 ;
    BD = conv( B_hat , D_hat ) ;
    L_BD = length( BD ) ;
    n_bd_hat = n_k : L_BD + n_k - 1 ;
    FD = conv( F_hat , D_hat ) ;
    L_FD = length( FD ) ;
    FC_FD = [ zeros( 1 , L_FD - L_FC ) FC ] - [ zeros( 1 , L_FC - L_FD ) FD ] ;
    L_FC_FD = length( FC_FD ) ;
    n_fc_fd_hat = 0 : L_FC_FD - 1 ;

    y_hat = zeros( N , 1 ) ;

    for k = 1 : N
        y_hat( k ) = Updater( FC , BD , FC_FD , n_fc_hat , n_bd_hat , n_fc_fd_hat , -y_hat , u , y , k ) ;
    end
    E_BJ = y - y_hat ;
    Fitting = ( 1 - ( norm( y - y_hat ) / norm( y - mean( y ) ) ) ) * 100 ;

end