MLP with Toolbox 2
clc;clear;close all

%% Input & Output
%% Creating Data
u = 0*normrnd( 0 , 1 , 2500 , 1 ) ;
Noise = normrnd( 0 , 0.001 , 2500 , 1 ) ;
N = length( u ) ;
y = zeros( N , 1 ) ;
for t = 1 : N
    if t - 2 <= 0
        y_2 = 0 ;
    else
        y_2 = y( t - 2 ) ;
    end
    if t - 1 <= 0 
        y_1 = 0 ;
        u_1 = 0 ;
    else
        y_1 = y( t - 1 ) ;
        u_1 = u( t - 1 ) ;
    end
    y( t , 1 ) = plant( y( t ) , y_1 , y_2 , u( t ) , u_1 , Noise( t ) ) ;
end

%%
Nern_Num_Lim = input( 'Please Enter Minimum And Maximum Number Of Neurons:[min max]   ' ) ;
Nern_Step = input( 'Please Enter Step For Encreasing Neurons:   ' ) ;
Epochs = input( 'Please Enter Number Of Epochs:   ' ) ;
% n_y = input( 'Please Enter Output Dynamics:(for example : [ 0 1 2 ])   ' ) ;
% n_u = input( 'Please Enter Input1 Dynamics:(for example : [ 0 1 ])   ' ) ;

n_y = [ 0 1 2 ] ;
n_u = [ 0 1 ] ;

n = length( n_y ) + length( n_u ) ;
phi  = zeros ( N , n ) ;
for t = 1 : N   
    f = 0 ;
    for k = n_y
        f = f + 1 ;
        if t - k > 0
            phi( t , f ) = y( t - k ) ;
        end
    end
    
    for k = n_u
        f = f + 1 ;
        if t - k > 0
            phi( t , f ) = u( t - k ) ;
        end
    end

end

%%
sel = 1 : N ;
X_Test = phi( sort( sel( ceil( 0.85 * N ) + 1 : end ) ) , : ) ;
phi( sel( ceil( 0.85 * N ) + 1 : end ) , : ) = [] ;
X_Train = phi ;

Y = y ;
Y_Test = Y( sort( sel( ceil( 0.85 * N ) + 1 : end ) ) ) ;
Y( sel( ceil( 0.85 * N ) + 1 : end ) ) = [] ;
Y_Train = Y ;

%%
N_train = size( X_Train , 1 );

sel = randperm( N_train ) ;
X_Train_Test = X_Train( sort( sel( 1 : floor( 0.2 * N_train ) ) ) , : ) ;
X_Train( sort( sel( 1 : floor( 0.2 * N_train ) ) ) , : ) = [ ] ;
X_Train_Train = X_Train ;

Y_Train_Test = Y_Train( sort( sel( 1 : floor( 0.2 * N_train ) ) ) ) ;
Y_Train( sort( sel( 1 : floor( 0.2 * N_train ) ) ) ) = [ ] ;
Y_Train_Train = Y_Train ;

%%

Min = min( X_Train_Train );
h = max( X_Train_Train ) - min( X_Train_Train );
n_train = size( X_Train_Train , 1 ) ;
n_test = size( X_Test , 1 ) ;
%%
X_train_Normal = ( ( X_Train_Train - ones( n_train , 1 ) * Min )./( ones( n_train , 1 ) * h ) ) * 2 - 1 ;
X_test_Normal=((X_Train_Test-ones(size(X_Train_Test,1),1)*Min)./(ones(size(X_Train_Test,1),1)*h))*2-1;
X_test_all_Normal=( ( X_Test - ones( n_test , 1 ) * Min )./( ones( n_test , 1 ) * h ) ) * 2 - 1 ;

%% 


%%
count = 0 ;
for KN = Nern_Num_Lim( 1 ) : Nern_Step : Nern_Num_Lim( 2 )  
    count = count + 1 ;  
    net = newff( X_train_Normal' , Y_Train_Train' , [ 5 KN ] , { 'tansig' 'tansig' 'purelin' } );   
    net = init( net ) ;
    net.trainFcn = 'trainlm' ;
    net.trainParam.epochs = 1 ;  
    SSE_TR = [ ] ;
    SSE_TE = [ ] ;
    for i = 1 : Epochs
        [ net , tr ] = train( net , X_train_Normal' , Y_Train_Train' ) ;
        SSE_TR_a = sum( ( Y_Train_Train' - sim( net , X_train_Normal' ) ).^2 ) ;
        SSE_TE_a = sum( (Y_Train_Test'-sim(net,X_test_Normal')).^2 );
        SSE_TR = [ SSE_TR SSE_TR_a ];
        SSE_TE = [ SSE_TE SSE_TE_a ] ;
        Rshfle = randperm( n_train ) ;
        X_train_Normal = X_train_Normal( Rshfle , : ) ;
        Y_Train_Train = Y_Train_Train( Rshfle , : ) ;   
    end
    Out_TR = sim( net , X_train_Normal' ) ;
    E_TR = Out_TR - Y_Train_Train' ;
    MSE_TR( count ) = mse( E_TR ) ; 
    Out_TE = sim( net , X_test_Normal' ) ;
    E_TE = Out_TE - Y_Train_Test' ;
    MSE_TE( count ) = mse( E_TE ) ;
end


%% Y_hat
y_hat_test = sim( net , X_test_all_Normal' ) ;

%%

fig=1;
figure(fig)
plot((Nern_Num_Lim(1):Nern_Step:Nern_Num_Lim(2)),MSE_TE(1,:,end),'r')
hold on
plot((Nern_Num_Lim(1):Nern_Step:Nern_Num_Lim(2)),MSE_TR(1,:,end))
set(findall(figure(fig),'type','line'),'linewidth',1)
grid on
xlabel('Neuron')
ylabel('MSE')
title('MSE Per Neuron')
legend ('Test','Train')
fig=fig+1;

figure(fig)
plot(1:Epochs,SSE_TE/n_test,'r')
hold on
plot(1:Epochs,SSE_TR/n_train)
set(findall(figure(fig),'type','line'),'linewidth',1)
grid on
xlabel('Epochs')
ylabel('MSE')
title('MSE Per Epochs For Optimal Number Of Neuron')
legend ('Test','Train')
fig=fig+1;


Out_TR = sim(net,X_train_Normal');
Out_TE = sim(net,X_test_Normal');

figure(fig)
plot(Y_Train_Train)
hold on
plot(Out_TR,'r--')
set(findall(figure(fig),'type','line'),'linewidth',1)
grid on
title('y & y_h_a_t For Train')
legend ('y','y_h_a_t')
fig=fig+1;


figure(fig)
plot(Y_Train_Test)
hold on
plot(Out_TE,'r--')
set(findall(figure(fig),'type','line'),'linewidth',1)
grid on
title('y & y_h_a_t For Test')
legend ('y','y_h_a_t')

figure

crosscorr( y_hat_test'-Y_Test , y_hat_test'-Y_Test )

Fitting = ( 1 - ( norm( Y_Test - y_hat_test' ) / norm( Y_Test - mean( Y_Test ) ) ) ) * 100