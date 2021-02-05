function [ W , b , phi , MSE_train , MSE_test ] = MLP_BP( U_train , Y_train , U_test , Y_test , Ner_Num , epoch )
    rand( 'state' , 0 ) ;
    layers = length( Ner_Num ) ;
    N = size( U_train , 1 ) ;
    Inputs_Num = size( U_train , 2 ) ;
    W{ 1 } = rand( Ner_Num( 1 ) , Inputs_Num ) - 0.5 ;
    b{ 1 } = rand( Ner_Num( 1 ) , 1 ) - 0.5 ;
    for i = 2 : layers
        W{ i } = rand( Ner_Num( i ) , Ner_Num( i - 1 ) ) - 0.5 ;
        b{ i } = rand( Ner_Num( i ) , 1 ) - 0.5 ;
    end
    W{ layers + 1 } = rand( size( Y_train , 2 ) , Ner_Num( end ) ) - 0.5 ;
    b{ layers + 1 } = rand( size( Y_train , 2 ) , 1 ) - 0.5 ;
    for ep = 1 : epoch
        for t = 1 : N
            u = U_train( t , : )' ;
            phi{ 1 } = tansig( W{ 1 } * u + b{ 1 } ) ;
            for i = 2 : layers
                phi{ i } = tansig( W{ i } * phi{ i - 1 } + b{ i } ) ;
            end
            y_hat_train( t , : ) = W{ layers + 1 } * phi{ layers } + b{ layers + 1 } ;
            e( t ) = Y_train( t , : ) - y_hat_train( t , : ) ;

            for i = 1 : layers
                d_y_hat_train{ i } = diag( 1 - phi{ i } .* phi{ i } ) * W{ i + 1 }' ;
            end
            for i = 1 : layers + 1
                d_J{ i } = 1 ;
                for j = i : layers
                    d_J{ i } = d_J{ i } * d_y_hat_train{ j } ;
                end
                if i == 1
                    d_J_W{ i } = - e( t ) * d_J{ i } * u' ;
                else
                    d_J_W{ i } = - e( t ) * d_J{ i } * phi{ i - 1 }' ;
                end
                d_J_b{ i } = - e( t ) * d_J{ i } ;

                W{ i } = W{ i } - 0.04 * d_J_W{ i } ;
                b{ i } = b{ i } - 0.04 * d_J_b{ i } ;
            end
        end
        for t = 1 : N
            u = U_train( t , : )' ;
            phi{ 1 } = tansig( W{ 1 } * u + b{ 1 } ) ;
            for i = 2 : layers
                phi{ i } = tansig( W{ i } * phi{ i - 1 } + b{ i } ) ;
            end
            y_hat_train( t , : ) = W{ layers + 1 } * phi{ layers } + b{ layers + 1 } ;
            e( t ) = Y_train( t , : ) - y_hat_train( t , : ) ;
        end
        MSE_train( ep ) = mse( e ) ;
    
        for t = 1 : size( Y_test , 1 ) 
            u = U_test( t , : )' ;
            phi{ 1 } = tansig( W{ 1 } * u + b{ 1 } ) ;
            for i = 2 : layers
                phi{ i } = tansig( W{ i } * phi{ i - 1 } + b{ i } ) ;
            end
            y_hat_test( t , : ) = W{ layers + 1 } * phi{ layers } + b{ layers + 1 } ;
            e( t ) = Y_test( t , : ) - y_hat_test( t , : ) ;
        end
        MSE_test( ep ) = mse( e ) ;
    end
end

