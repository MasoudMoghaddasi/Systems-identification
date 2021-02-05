function [ G , E ] = PCA( X_Train_All , d ,ClassNo )

    x=[];
    n=zeros(1,ClassNo);
    for i=1:ClassNo
        x=[x; X_Train_All{i}];
        [n(i) ~]=size(X_Train_All{i});
    end
    X=x-ones(sum(n),1)*mean(x);
    S=(X'*X)/sum(n);
    [V D]=eig(S);
    [~, b]=sort(diag(D));
    G=V(:,b(end:-1:end-d+1))';
    Z=G*x';
    E=norm(x'-G'*Z,'fro')^2;

end

