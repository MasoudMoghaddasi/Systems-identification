clc;clear;close all

load A.mat
load D.mat
load E.mat

Dyn=input('Please Enter Number Of Dynamics:(for example 1 for original data)   ');
iter=input('Please Enter Itteration For ICA:   ');
d=input('Please Enter Reducted Dimention:   ');
X_Train_All={A(1:3000,:),D(1:3000,:),E(1:3000,:)};
X_Test_All={A(3001:end,:),D(3001:end,:),E(3001:end,:)};

%%
ClassNo=size(X_Train_All,2);

for i=1:ClassNo
    [ X_Train_All{i},X_Test_All{i} ] = Dynamic( X_Train_All{i},X_Test_All{i},Dyn );
end

%%
[n p]=size(X_Train_All{1});
[n p]=size(X_Train_All{1});
Z_train=cell(1,ClassNo);
Z_test=cell(1,ClassNo);

%% ICA & Plot
[ W , Cov , U , Mean ] = FastICA( X_Train_All , d , ClassNo , iter ) ;


for i=1:ClassNo
    x_train_mean = X_Train_All{i}' - diag(Mean) * ones( size( X_Train_All{i}' ) ) ;
    x_test_mean = X_Test_All{i}' - diag(Mean) * ones( size( X_Test_All{i}' ) ) ;
    
    x_train = (Cov^(-0.5))*U'*(x_train_mean); 
    x_test = (Cov^(-0.5))*U'*(x_test_mean); 
    
    Z_train{i}=W*x_train;
    Z_test{i}=W*x_test;
    
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
title('Train Features After ICA')
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
title('Train Features After ICA')
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
title('Train Features After ICA')
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
    title('Test Features After ICA')
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
    title('Test Features After ICA')
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
    title('Test Features After ICA')
end

%%
W_opt = Classifier_LS( Z_train , ClassNo );
% W_opt = Classifier_Batch( Z_train , ClassNo , 0.01 , 2000 );


%%
confidence=Confidence( W_opt,Z_test,ClassNo )


%%
% save('result1_a.mat','W_opt','confidence','d')
