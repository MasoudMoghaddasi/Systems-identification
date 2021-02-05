function [ Y ] = Output_Gen( A , B , C , n_a , n_b , n_c , u , y , t , White_Noise )
    
    n = length( n_a ) + length( n_b ) + length( n_c ) ;
    phi  = zeros ( 1 , n ) ;
    f = 0 ;

    for j = n_a
        f = f + 1 ;
        if t - j > 0
           phi( 1 , f ) = - y( t - j ) ;
        end
    end
    
    for k = n_b
        f = f + 1 ;
        if t - k > 0
            phi( 1 , f ) = u( t - k ) ;
        end
    end
    
    for h = n_c
        f = f + 1 ;
        if t - h > 0
            phi( 1 , f ) = White_Noise( t - h ) ;
        end
    end
    
    Y = phi * [ A( 2 : end )' ; B' ; C' ] ;

end

