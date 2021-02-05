clc;clear;close all
load A.mat
load D.mat
load E.mat

d=input('Please Enter Reducted Dimention:   ');
k=input('Please Enter Number Of Neighbors:   ');
Dyn=input('Please Enter Number Of Dynamics:(for example 0 for original data)   ') + 1;
X_Train_All={A(1:3000,:),D(1:3000,:),E(1:3000,:)};
X_Test_All={A(3001:end,:),D(3001:end,:),E(3001:end,:)};



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

%% LDA 

if d<=ClassNo-1
    G = LDA( X_Train_All , ClassNo , d );


    %%


    for i=1:ClassNo
        Z_train{i}=G*X_Train_All{i}';
        Z_test{i}=G*X_Test_All{i}';
    end


    %%
    XtrainAll=[];
    Xtest=[];
    ClassVector_train=[];
    ClassNo=size(X_Train_All,2);

    for i=1:ClassNo
        XtrainAll=[XtrainAll ;Z_train{i}'];
        [d ~]=size(Z_train{i}');
        ClassVector_train=[ClassVector_train; i*ones(d,1)];
        Xtest=[Xtest ;Z_test{i}'];
        [f(i) ~]=size(Z_test{i}');
    end
    %%

    Class_Out=KNN_classifier(XtrainAll',Xtest',ClassVector_train,k);
    %%
    for n=1:ClassNo
        C=Class_Out(1:f(n));
        Class_Out(1:f(n))=[];
        for j=1:ClassNo+1
           Confidence(n,j)=size(C(C==j),2)/f(n);
        end
    end
    Confidence
else
    disp('Your requested dimention is not valid')
end