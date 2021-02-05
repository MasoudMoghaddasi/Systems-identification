function [ G , E ] = LDA( X_Train_All , ClassNo , d )
    
    x=[];
    [~, m]=size(X_Train_All{1});
    Sw=zeros(m,m);
    n=zeros(1,ClassNo);
    for i=1:ClassNo
        x=[x; X_Train_All{i}];
        [n(i) ~]=size(X_Train_All{i});
        X=X_Train_All{i}-ones(n(i),1)*mean(X_Train_All{i});
        S=(X'*X);
        Sw=Sw+S;
    end
    

    X=x-ones(sum(n),1)*mean(x);
    St=(X'*X);
    
    Sb=St-Sw;
    
    [V D]=eig(Sw^-1*Sb);
    [~, b]=sort(diag(D));
    G=V(:,b(end:-1:end-d+1))';
    
    E=norm(G*Sb*G','fro')/norm(G*Sw*G','fro');


end