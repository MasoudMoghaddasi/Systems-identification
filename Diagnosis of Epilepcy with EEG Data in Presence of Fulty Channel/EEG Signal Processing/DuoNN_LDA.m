clc;clear; close all;


Dyn=input('Please Enter Number Of Dynamics:(for example 0 for original data)   ') + 1;
load A.mat
load D.mat
load E.mat


X_Test_All={A(1:1500,:),D(1:1500,:),E(1:1500,:)};
X_Train_All={A(1501:end,:),D(1501:end,:),E(1501:end,:)};

%%
ClassNo=size(X_Train_All,2);
%%
for i=1:ClassNo
    [ X_Train_All{i},X_Test_All{i} ] = Dynamic( X_Train_All{i},X_Test_All{i},Dyn );
end

%%
[n p]=size(X_Train_All{1});
G=cell(1,ClassNo-1);
Z_train=cell(1,ClassNo);
Z_test=cell(1,ClassNo);

%% LDA & Plot
for j=1:ClassNo-1
    [ G{j} , e(j) ] = LDA( X_Train_All , ClassNo , j );
end

%%
dD=1:ClassNo-1;
fig=stem(dD,e,'fill','--');
axis([0 ClassNo 0 max(e)*1.1])
set(fig,'MarkerFaceColor','red')
title('Fisher Criteria Vs. Dimention')
xlabel('Fishet Criteria')
ylabel('Error')
d=input('Please Enter Reducted Dimention ( Less Than Class No. ):   ');
%%

for i=1:ClassNo
    Z_train{i}=G{d}*X_Train_All{i}';
    Z_test{i}=G{d}*X_Test_All{i}';
end

%%
if d==3
    figure
    plot3(Z_train{1}(1,:),Z_train{1}(2,:),Z_train{1}(3,:),'*')
    hold on
    plot3(Z_train{2}(1,:),Z_train{2}(2,:),Z_train{2}(3,:),'r+')
    hold on
    plot3(Z_train{3}(1,:),Z_train{3}(2,:),Z_train{3}(3,:),'go')
    hold off
    grid on
legend('First Class','Second Class','Third Class');
title('Train Features After LDA')
elseif d==2
    figure
    plot(Z_train{1}(1,:),Z_train{1}(2,:),'*')
    hold on
    plot(Z_train{2}(1,:),Z_train{2}(2,:),'r+')
    hold on
    plot(Z_train{3}(1,:),Z_train{3}(2,:),'go')
    hold off
    grid on
legend('First Class','Second Class','Third Class');
title('Train Features After LDA')
elseif d==1
    figure
    plot(Z_train{1}(1,:),'*')
    hold on
    plot(Z_train{2}(1,:),'r+')
    hold on
    plot(Z_train{3}(1,:),'go')
    hold off
    grid on
legend('First Class','Second Class','Third Class');
title('Train Features After LDA')
end

if d==3
    figure
    plot3(Z_test{1}(1,:),Z_test{1}(2,:),Z_test{1}(3,:),'*')
    hold on
    plot3(Z_test{2}(1,:),Z_test{2}(2,:),Z_test{2}(3,:),'r+')
    hold on
    plot3(Z_test{3}(1,:),Z_test{3}(2,:),Z_test{3}(3,:),'go')
    hold off
    grid on
    legend('First Class','Second Class','Third Class');
    title('Test Features After LDA')
elseif d==2
    figure
    plot(Z_test{1}(1,:),Z_test{1}(2,:),'*')
    hold on
    plot(Z_test{2}(1,:),Z_test{2}(2,:),'r+')
    hold on
    plot(Z_test{3}(1,:),Z_test{3}(2,:),'go')
    hold off
    grid on
    legend('First Class','Second Class','Third Class');
    title('Test Features After LDA')
elseif d==1
    figure
    plot(Z_test{1}(1,:),'*')
    hold on
    plot(Z_test{2}(1,:),'r+')
    hold on
    plot(Z_test{3}(1,:),'go')
    hold off
    grid on
    legend('First Class','Second Class','Third Class');
    title('Test Features After LDA')
end

%%

x_test = [] ;
x_train = [] ;
for i=1:ClassNo
    x_train=[x_train; Z_train{i}'];
    x_test=[x_test; Z_test{i}'];
    [n_train(i) ~]=size(Z_train{i}');
    [n_test(i) ~]=size(Z_test{i}');
end

Min=min(x_train);
h=max(x_train)-min(x_train);
clear X_train X_test 
%%
X_train=((x_train-ones(size(x_train,1),1)*Min)./(ones(size(x_train,1),1)*h))*2-1;
X_test=((x_test-ones(size(x_test,1),1)*Min)./(ones(size(x_test,1),1)*h))*2-1;

T=[];
for i=1:ClassNo
    temp=0.3*rand(n_train(i),ClassNo);
    temp(:,i)=0.7+0.3*rand(n_train(i),1);
    T=[T ;temp];
end

%%  
[ ~ , in ] = size(X_train) ; 
    
l = 3 ;
alfa = 0.1;
eta = 0.3;
X_b = 1 ;

%% Hidden Layer
W_D = rand(in,l)*0.3 ;
W_Dhb = rand(1,l)*0.3 ;
W_V = rand(in,l)*0.3 ;
W_Vhm = rand(1,l)*0.3 ;

%% Output Layer
W = rand(l,ClassNo)*0.3 ;
W_jb = rand(1,ClassNo)*0.3 ;
W_jm = rand(1,ClassNo)*0.3 ;

%%
W_D_t_1 = zeros(in,l) ;
W_Dhb_t_1 = zeros(1,l) ;
W_V_t_1 = zeros(in,l) ;
W_Vhm_t_1 = zeros(1,l) ;
W_t_1 = zeros(l,ClassNo) ;
W_jb_t_1 = zeros(1,ClassNo) ;
W_jm_t_1 = zeros(1,ClassNo) ;

%%   Pn=S^2*XI
Y_nPAT = 1/in * sum( X_train , 2 );
pn=sum(n_train);
for t=1:25
    if t==1
        k=0;
        mu=1;
    else
        k=K(t-1);
        mu=Mu(t-1);
    end
    
    for p=1:pn
        XI= X_train(p,:) ;
        YI= XI ;

        TP_DhL= YI * W_D ;
        TP_Dhb = X_b * W_Dhb ;
        X_HD = TP_DhL + TP_Dhb ;

        Y_AcP = 1/p * sum( Y_nPAT(1:p,:) ) ;
        TP_VhG = Y_AcP * ones(1,in) * W_V ;
        TP_Vm = Y_AcP * W_Vhm ;   
        X_HV = TP_VhG + TP_Vm ;

        Y_H = 1./(1 + exp( - X_HD - X_HV ));
        TP_jc = Y_H * W ;

        TP_jb = X_b * W_jb ;
        TP_jm = Y_AcP * W_jm ;

        XJ = TP_jc + TP_jb + TP_jm ;

        YJ = 1./( 1 + exp( - XJ ) ) ;

        e(p) = sum( ( T(p,:) - YJ ) .^2 ) ;

        Y_AvPAT = 1/pn * sum( Y_nPAT ) ;

        W_D_t = W_D ;
        W_Dhb_t = W_Dhb ;
        W_V_t = W_V ;
        W_Vhm_t = W_Vhm ;
        W_t = W ;
        W_jb_t = W_jb ;
        W_jm_t = W_jm ;

        delta = YJ .* ( ones(size(YJ)) - YJ ) .* ( T(p,:) - YJ ) ;
        
        W = W + eta *  Y_H' * delta + alfa * ( W - W_t_1 );

        W_jb = W_jb + eta  * delta + alfa * ( W_jb - W_jb_t_1 );

        W_jm = W_jm + mu *  Y_AvPAT * delta + k * ( W_jm - W_jm_t_1 );

        delta_h = Y_H .* ( ones(size(Y_H)) - Y_H ) .* (  delta * W' ) ;

        W_D = W_D + eta *  YI' * delta_h + alfa * ( W_D - W_D_t_1 );

        W_Dhb = W_Dhb + eta * delta_h + alfa * ( W_Dhb - W_Dhb_t_1 );

        W_V = W_V + mu *  ( Y_AvPAT + YI )' * delta_h + k * ( W_V - W_V_t_1 );

        W_Vhm = W_Vhm + mu *  Y_AvPAT * delta_h + k * ( W_Vhm - W_Vhm_t_1 );

        W_D_t_1 = W_D_t ;
        W_Dhb_t_1 = W_Dhb_t ;
        W_V_t_1 = W_V_t ;
        W_Vhm_t_1 = W_Vhm_t ;
        W_t_1 = W_t ;
        W_jb_t_1 = W_jb_t ;
        W_jm_t_1 = W_jm_t ;
        
    end
        
    E(t) = sum( e )/ ( pn * ClassNo )  ;

    Mu(t) = Y_AvPAT + E(t) ;
    if t==1
        Mu0=Mu;
    end
    K(t) = Mu0 - Mu(t) ;
    
end


%%
figure
plot(Mu)
hold all
plot(K)
hold off
grid on
legend('Anxiety Coefficient','Confidence Coefficient');
title('Anxiety & Confidence Coefficients VS. Iteration')
xlabel('Iteraion')
ylabel('Anxiety & Confidence Coefficients')

%% Test Part
Y_nPAT = 1/in * sum( X_test , 2 );
pn=sum(n_test);
for p=1:pn
    XI= X_test(p,:) ;
    YI= XI ;

    TP_DhL= YI * W_D ;
    TP_Dhb = X_b * W_Dhb ;
    X_HD = TP_DhL + TP_Dhb ;

    Y_AcP = 1/p * sum( Y_nPAT(1:p,:) ) ;
    TP_VhG = Y_AcP * ones(1,in) * W_V ;
    TP_Vm = Y_AcP * W_Vhm ;   
    X_HV = TP_VhG + TP_Vm ;

    Y_H = 1./(1 + exp( - X_HD - X_HV ));
    TP_jc = Y_H * W ;

    TP_jb = X_b * W_jb ;
    TP_jm = Y_AcP * W_jm ;

    XJ = TP_jc + TP_jb + TP_jm ;

    YJ(p,:) = 1./( 1 + exp( - XJ ) ) ;
    tem=YJ(p,:);
    Class(p)=ClassNo+1;
    f=1;
    rc=0;
    while ( rc==0 && f <= ClassNo)
        if tem(f)>=0.7
            tem(f)=[];
            rc=1;
            if tem<=0.3
                Class(p)=f;
            end
        end
        f=f+1;
    end
end
figure
plot(YJ)
grid on
title('Test Output VS. Sample')
xlabel('Sample')
ylabel('Test Output')

for n=1:ClassNo
    C=Class(1:n_test(n));
    Class(1:n_test(n))=[];
    for j=1:ClassNo+1
       Confidence(n,j)=size(C(C==j),2)/n_test(n);
    end
end
Confidence