function [ reg , reg_elim , E ] = backward_elim( x_train , y_train , x_test , y_test , reg_all , n )

    if n > length( reg_all )
        n = length( reg_all ) ;  
    end     
    reg = [] ;
    reg_All = reg_all ;
    for j = 1 : n
        k = reg_All ;
        m = length( k ) ;
        clear e
        for i = 1 : m
            k( i ) = [] ;
            X_Tr_sel =  x_train( : , sort( k )  ) ;
            X_Te_sel =  x_test( : , sort( k )  ) ;
            theta = ( X_Tr_sel' * X_Tr_sel )^-1 * X_Tr_sel' * y_train ;
            y_hat = X_Te_sel * theta ;
            e( i ) = norm( y_hat - y_test )^2 ;
            k = reg_All ;
        end
        [ E(j) h ] = min( e ) ;
        reg_elim( j ) = reg_All( h ) ;
        reg_All( h ) = [] ;         
    end
    reg = reg_All ;
%     for i = 2 : n
%         if abs( E( i ) - E( i - 1 ) ) / E( 1 ) < 5e-4 || E( i ) - E( i - 1 ) > 0
%             Reg = reg( 1 : i - 1 );
%             break
%         end
%     end
    
end