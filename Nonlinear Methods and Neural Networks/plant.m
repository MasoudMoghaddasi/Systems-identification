function [ y ] = plant( x1 , x2 , x3 , x4 , x5 , noise )

    y = ( x1 * x2 * x3 * x5 * ( x3 - 1 ) + x4^2 ) / ( 1 + x2^2 + x3^2 ) + noise ;

end
