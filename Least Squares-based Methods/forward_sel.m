function [ reg , E ] = forward_sel( x_train , y_train , x_test , y_test , reg_all , reg_sel , n )
    
    for i = 1 : length( reg_sel )
        reg_all( reg_all == reg_sel( i ) ) = [] ;
    end
    if n > length( reg_all )
        n = length( reg_all ) ;  
    end
    k = reg_all ;
    reg = reg_sel ;
    for j = 1 : n
        m = length( k ) ;
        clear e
        for i = 1 : m
                X_Tr_sel =  x_train( : , sort( [ reg k( i ) ] )  ) ;
                X_Te_sel =  x_test( : , sort( [ reg k( i ) ] )  ) ;
                theta = ( X_Tr_sel' * X_Tr_sel )^-1 * X_Tr_sel' * y_train ;
                y_hat = X_Te_sel * theta ;
                e( i ) = norm( y_hat - y_test )^2 ;
        end
        [ E(j) h ] = min( e ) ;
        reg( end + 1 ) = k( h ) ;
        k( h ) = [] ;         
    end
    
%     for i = 2 : n
% %         if abs( E( i ) - E( i - 1 ) ) / E( 1 ) > 0 || E( i ) - E( i - 1 ) > 0
%         if 1
%             Reg = reg( 1 : i - 1 );
%             break
%         end
%     end
    
end