function [ Conf ] = Confidence( W_opt,Z_test,ClassNo )
    Conf=zeros(ClassNo,ClassNo+1);
    q=zeros(1,ClassNo);
    y=zeros(ClassNo-1,ClassNo);
    for n=1:ClassNo
        z_test=Z_test{n};
        [~, q(n)]=size(z_test);
        for j=1:q(n)
            z=[1;z_test(:,j)];
            for i=1:ClassNo-1
                for k=i+1:ClassNo
                    if (W_opt{i,k}.w'*z)>0
                        y(i,k)=i;
                    else
                        y(i,k)=k;
                    end
                end
            end
            Class=ClassNo+1;
            m=0;
            for c=1:ClassNo
                if size(y,1)==1
                    [~, u]=size(y(y==c));
                else
                    [u ~]=size(y(y==c));
                end
                if u>m
                    Class=c;
                    m=u;
                else if (u==m && u~=0)
                        Class=ClassNo+1;
                    end
                end
            end
            Conf(n,Class)=Conf(n,Class)+1;
        end
        Conf(n,:)=Conf(n,:)/q(n);
    end
end

