function [ A , B , C , D , A_p , B_p , A_c , B_c , y ] = Plant1( u , N , Ts , white_noise , C , D )
    
    %% Digitizing of Plant
    Gp = tf( 10 , [ 1 10 ] ) ;
    Gc = tf( 1 ,[ 1 0 ]  ) ;

    Gp_d = c2d( Gp , Ts , 'zoh' ) ;
    [ B_p , A_p ] = tfdata( Gp_d , 'v' ) ;

    Gc_d = c2d( Gc , Ts , 'zoh' ) ;
    z = tf( 'z' , Ts ) ;
    Gc_D = z * Gc_d ;

    [ B_c , A_c ] = tfdata( Gc_D , 'v' ) ;

    G = feedback( Gc_D * Gp_d , 1 ) ;
    [ B , A ] = tfdata( G , 'v' ) ;

    %%
    AD = conv( A , D ) ;
    BD = conv( B , D ) ;
    D = AD ;
    C = conv( conv( A_p , A_c ) , C ) ;

    n_b =  ( ~ BD( 1 ) * 1 ) : length( BD ) - 1  ;
    n_a = 1 : length( AD ) - 1 ;
    n_c = 0 : length( C ) - 1 ;

    if ~BD( 1 )
        BD( 1 ) = [] ;
    end
    if ~B( 1 )
        B( 1 ) = [] ;
    end

    %% Real Output
    y = zeros( N , 1 ) ;
    for t = 1 : N
        y( t ) = Output_Gen( AD , BD , C , n_a , n_b , n_c , u , y , t , white_noise ) ;
    end

end

