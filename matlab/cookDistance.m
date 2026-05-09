clear; clc;

data = xlsread('DataCookDistance.xlsx');
[n,p] = size(data);


x0 = ones(n,1);
x = data(:,1:5);
y = data(:,6);

xModel1 = [x0 x];
b = (xModel1' * xModel1) \ (xModel1' * y);

