function [ theta_t , P_t ] = RLS( theta_t_1 , P_t_1 , phi_t , y_t , Landa , Q )
  
    n = length ( phi_t );
    K_t = P_t_1 * phi_t * ( Landa + phi_t' * P_t_1 * phi_t )^-1;
    P_t = 1/Landa * ( eye(n) - K_t * phi_t' ) * P_t_1 + Q ;
    theta_t = theta_t_1 + K_t * ( y_t - phi_t' * theta_t_1 );

end