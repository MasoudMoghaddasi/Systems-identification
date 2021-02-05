function [ V , R , REG_sel , Theta , ERR ] = OLS( X , Y , ns )

    [ ~ , n ] = size( X ) ;
    V = zeros( size( X , 1 ) , ns ) ;
    In_sel = 1 : n ;
    r = zeros( ns ) ;
    R = zeros( ns ) ;
    h = zeros( 1 , ns ) ;
    for k = 1 : ns
        Err = zeros( 1 , n ) ;
        
        for i = In_sel
            Su = zeros( size( X , 1 ) , ns ) ;
            for j = 1 : k - 1
                r( j , k ) = ( V( : , j )' * X( : , i ) ) / ( V( : , j )' * V( : , j ) ) ;
                Su( : , j ) = r( j , k ) * V( : , j ) ;
            end

            v = X( : , i ) - sum( Su , 2 ) ;
            theta = ( v' * Y ) / ( v' * v ) ;
            Err( i ) = ( theta^2 * ( v' * v )  ) / ( Y' * Y ) ;

            if ( i == 1 )
                V( : , k ) = v ;
                h( k ) = i ;
                R( : , k ) = r( : , k ) ;
                Theta( k , 1 ) = theta ;
                ERR( k ) = Err( i ) ;
            elseif i > 1
                if Err( i ) > Err( i - 1 )
                    V( : , k ) = v ;
                    h( k ) = i ;
                    R( : , k ) = r( : , k ) ;
                    Theta( k , 1 ) = theta ;
                    ERR( k ) = Err( i ) ;
                end
            end

        end 
        
        In_sel( In_sel == h( k ) ) = [] ;
    end
    R = eye( ns ) + R  ;
%     [ SORT k ] = sort( diag( V'*V ) , 'descend' );
    REG_sel = h;%( k ) ;
end

