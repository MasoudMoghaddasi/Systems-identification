function [ phi ] = Regressor_Gen( n_a , n_b , u , y , t )

    n = length( n_a ) + length( n_b ) ;
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
    
end

