function [ W_opt ] = Classifier_LS( Z_train , ClassNo )

    W_opt=cell(ClassNo-1,ClassNo);
    for i=1:ClassNo-1
        for k=i+1:ClassNo
            [~, n]=size(Z_train{i});
            [~, m]=size(Z_train{k});
            b=rand(m+n,1);
            z=[[ones(n,1) Z_train{i}']; -[ones(m,1) Z_train{k}']];
            w=(z'*z)^-1*z'*b; 
            g=w'*z';
            h=size((g(g<=0)),2);
            W_opt{i,k}=struct('w',w,'h',h);
        end
    end
end

