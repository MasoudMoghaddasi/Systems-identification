function [ A , B , y ] = Plant2( u , N , Ts , white_noise , C , D )
    
    %% Digitizing of Plant
    Gp = tf( [ 2 2 ] , [ 1 2 3 ] ) ;

    G = c2d( Gp , Ts , 'zoh' ) ;

    [ B , A ] = tfdata( G , 'v' ) ;

    %%
    AD = conv( A , D ) ;
    BD = conv( B , D ) ;

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

