function [ A , B , C , D , A_p , B_p , A_c , B_c , y ] = Plant1_delay( u , N , Ts , white_noise , C , D )
    
    %% Digitizing of Plant
    Gp = tf( 10 , [ 1 10 ] , 'iodelay' , 0.01 ) ;
    Gc = tf( 1 ,[ 1 0 ]  ) ;

    Gp_d = c2d( Gp , Ts , 'zoh' ) ;
    [ B_p , A_p ] = tfdata( Gp_d , 'v' ) ;

    Gc_d = c2d( Gc , Ts , 'zoh' ) ;
    z = tf( 'z' , Ts ) ;
    Gc_D = z * Gc_d ;

    [ B_c , A_c ] = tfdata( Gc_D , 'v' ) ;

    G = minreal( feedback( Gc_D * Gp_d , 1 ) ) ;
    [ B , A ] = tfdata( G , 'v' ) ;

    %%
    AD = conv( A , D ) ;
    BD = conv( B , D ) ;
    D = AD ;
    C = conv( conv( A_p , A_c ) , C ) ;

    n_b =  0 : length( BD ) - 1  ;
    n_a = 1 : length( AD ) - 1 ;
    n_c = 0 : length( C ) - 1 ;
  

    %% Real Output
    y = zeros( N , 1 ) ;
    for t = 1 : N
        y( t ) = Output_Gen( AD , BD , C , n_a , n_b , n_c , u , y , t , white_noise ) ;
    end

end

