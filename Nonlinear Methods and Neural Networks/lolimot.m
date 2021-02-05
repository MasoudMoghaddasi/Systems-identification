function [w,local,c,sigma,Rmse]=lolimot(X,Y,local,iterate,Rmse)

[nd fea]=size(X);
for iteratation=1:iterate
    [w,E,worst_sub,c,sigma]=CWEW(local,X,Y);
    if sqrt(E/(nd))<Rmse
        break
    end
    
    bad=local(:,:,worst_sub);
    local(:,:,worst_sub)=[];

    es=[];
    for i=1:fea
        tem7=bad;
        tem7(i,:)=[bad(i,1) (bad(i,1)+bad(i,2))*0.5]; 
        tem8=bad;
        tem8(i,:)=[(bad(i,1)+bad(i,2))*0.5 bad(i,2)];
        tem9=cat(3,tem7,tem8);
        tem10=cat(3,local,tem9);
        [w,E,worst_sub,c,sigma]=CWEW(tem10,X,Y);
        es=[es,E];
    end

    [vv ii]=sort(es);
    best_dim=ii(1);
    tem7=bad;
    tem7(best_dim,:)=[bad(best_dim,1) (bad(best_dim,1)+bad(best_dim,2))*0.5]; 
    tem8=bad;
    tem8(best_dim,:)=[(bad(best_dim,1)+bad(best_dim,2))*0.5 bad(best_dim,2)];
    tem9=cat(3,tem7,tem8);
    local=cat(3,local,tem9);

    


end
[w,E,worst_sub,c,sigma]=CWEW(local,X,Y);

Rmse=sqrt(E/nd);

end