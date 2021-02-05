function [ Ztrain,Ztest ] = Dynamic( Xtrain,Xtest,n )
    [a b]= size(Xtrain);
    [c d]= size(Xtest);
    Ztrain=zeros(a-n+1,n*b);
    Ztest=zeros(c-n+1,n*d);
    for i=1:n
        Ztrain(:,b*(i-1)+1:b*i)=Xtrain(i:end-n+i,:);
        Ztest(:,d*(i-1)+1:d*i)=Xtest(i:end-n+i,:);
    end
end

