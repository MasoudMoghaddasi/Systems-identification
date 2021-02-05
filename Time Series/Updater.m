function [ Y ] = Updater( A , B , C , n_a , n_b , n_c , y1 , y2 , y3 , t )
    
    n = length( n_a ) + length( n_b ) + length( n_c ) ;
    phi  = zeros ( 1 , n ) ;
    f = 0 ;

    for j = n_a
        f = f + 1 ;
        if t - j > 0
           phi( 1 , f ) = y1( t - j ) ;
        end
    end
    
    for k = n_b
        f = f + 1 ;
        if t - k > 0
            phi( 1 , f ) = y2( t - k ) ;
        end
    end
    
    for h = n_c
        f = f + 1 ;
        if t - h > 0
            phi( 1 , f ) = y3( t - h ) ;
        end
    end
    
    Y = 1/A( 1 ) * phi * [ A( 2 : end )' ; B' ; C' ] ;

end

