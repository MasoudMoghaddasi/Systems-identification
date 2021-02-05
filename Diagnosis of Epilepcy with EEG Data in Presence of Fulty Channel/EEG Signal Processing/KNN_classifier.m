function Class_Out=KNN_classifier(XtrainAll,Xtest,ClassVector_train,k)
    [~,N1]=size(XtrainAll);
    [~,N]=size(Xtest);
    c=max(ClassVector_train); 
    for i=1:N
        dist=sum((Xtest(:,i)*ones(1,N1)-XtrainAll).^ 2,1);
        [~,nearest]=sort(dist);
        refe=zeros(1,c);
        for j=1:k
            class=ClassVector_train(nearest(j));
            refe(class)=refe(class)+1;
        end
        [MAX,Class_Out(i)]=max(refe);
        refe(Class_Out(i))=[];
        if refe~=MAX;
        else
            Class_Out(i)=c+1;
        end
    end
end

    