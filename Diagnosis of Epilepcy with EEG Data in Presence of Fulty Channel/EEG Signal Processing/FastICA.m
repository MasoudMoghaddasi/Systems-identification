function [ W , Cov , U , Mean ] = FastICA( X_Train_All , d , ClassNo , iter )

    X=[];
    for i=1:ClassNo
        X=[X X_Train_All{i}'];
    end


    % X : (m x n) , n:number of data , m:number of sensors
    % s : (d x n) , n:number of data , d:number of sensors

    % Whitening
    [m,n] = size(X);
    Mean = mean(X');
    X_center = X - diag(Mean)*ones(m,n);
    [U,Cov,V] = svd(X,'econ');
    Z = (Cov^(-0.5))*U'*(X_center);

    % find W
    W_old = 0.001*randn(d,m);
    W = ((tanh(W_old*Z))*Z') - (diag((1-((tanh(W_old*Z)).^2))*ones(n,1))*W_old);
    W = ((W*W')^(-0.5))*W;
    for i=1:iter  
        W_old = W;
        W = ((tanh(W_old*Z))*Z') - (diag((1-((tanh(W_old*Z)).^2))*ones(n,1))*W_old);
        W = ((W*W')^(-0.5))*W;
        for j=1:d
            dot(j,i) = W(j,:)*W(j,:)';
        end
    end    


end

