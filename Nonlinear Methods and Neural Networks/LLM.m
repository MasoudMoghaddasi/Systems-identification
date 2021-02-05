clc ;clear all;close all
%% Input & Output
% load 'exchanger.dat'
% x_d=exchanger( : , 2 );
% y_d=exchanger( : , 3 );

load 'ballbeam.dat'
x_d = ballbeam( : , 1 ) ;
y_d = ballbeam( : , 2 ) ;

%%
x_dtr=x_d(1:round(0.7*size(x_d,1)),:);
y_dtr=y_d(1:round(0.7*size(x_d,1)),:);
x_dte=x_d(round(0.7*size(x_d,1))+1:end,:);
y_dte=y_d(round(0.7*size(x_d,1))+1:end,:);

limits_x=[min(x_d,[],1)' max(x_d,[],1)'];

local=zeros(size(limits_x),2);
local(:,:,1)=[limits_x(1:end-1,:);limits_x(end,1) (limits_x(end,1)+limits_x(end,2))/2];
local(:,:,2)=[limits_x(1:end-1,:);(limits_x(end,1)+limits_x(end,2))/2 limits_x(end,2)];
iterate=2;
Rmse=0.01;
[w,local,c,sigma,Rmse]=lolimot(x_dtr,y_dte,local,iterate,Rmse);