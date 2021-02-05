function [w,E,worst_sub,c,sigma]=CWEW(local,X,Y)


tem2=size(X);
n_data=tem2(1,1);
tem1=size(local);
fea=tem1(1,1);
nllm=tem1(1,3);
cllm=zeros(fea,nllm);
sigllm=zeros(fea,nllm);
k=1/3;
o=0.001;  %alfa for regularization%
for j=1:nllm
    for i=1:fea
        cllm(i,j)=(local(i,1,j)+local(i,2,j))*0.5;
        sigllm(i,j)=(-local(i,1,j)+local(i,2,j))*k;
    end
end
c=cllm;
sigma=sigllm;

w=[];
fi=[];
for j=1:nllm
   tem3=(X-ones(n_data,1)*(cllm(:,j)'))./(ones(n_data,1)*(sigllm(:,j)'));
   tem3=exp(-0.5.*(tem3.^2));
   tem3=prod(tem3,2);
   %tem3=sum(tem3')';
   fi=[fi,tem3];
end

tem4=sum(fi')';
fi=fi./(tem4*ones(1,nllm));

reg=[ones(n_data,1) X];    
for j=1:nllm
    tem5=inv(reg'*diag(fi(:,j))*reg+o*eye(fea+1))*reg'*diag(fi(:,j))*Y;
    w=[w tem5];
end

y_es_llm=(reg*w).*fi;
Y_es=sum(y_es_llm')';

e=Y-Y_es;
E=e'*e;
se=e.^2;
I=(se*ones(1,nllm)).*(fi);
I=sum(I);
[allm bllm]=sort(I);

worst_sub=bllm(end);

end