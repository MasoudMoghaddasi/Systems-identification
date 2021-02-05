function [ y_hat ] = Simulate( W , b , U )

    N = size( U , 1 ) ;
    layers = length( W ) - 1 ;
    for t = 1 : N
        u = U( t , : )' ;
        phi{ 1 } = tansig( W{ 1 } * u + b{ 1 } ) ;
        for i = 2 : layers
            phi{ i } = tansig( W{ i } * phi{ i - 1 } + b{ i } ) ;
        end
        y_hat( t , : ) = W{ layers + 1 } * phi{ layers } + b{ layers + 1 } ;
    end
    
end

