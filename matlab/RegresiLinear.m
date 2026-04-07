clear; clc;
data = xlsread('DataRegLinear.xlsx');

[n,p] = size(data);

Y = data(:,1);
x1 = data(:,2);
x0 = ones(n,1);

X = [x0 x1];

b = (X'*X) \ (X'*Y); % Inverse
disp(X'*X)
disp(X'*Y)

Yhat = X*b;
error = abs(Y -Yhat);
hasil = [Y Yhat error];

[nx, px] = size(X);

plot(1:n, hasil(:,1), 'ob') % hasil(:,1) sama dengan Y
hold on
grid on
plot(1:n, Yhat, '*r')

% ANOVA
ssReg = b' * (X' * Y) - (n*(mean(Y))^2);
ssRes = ((Y' *Y) - b' * (X' *Y));
ssTot = Y' * Y -(n*(mean(Y))^2);

dfReg = px -1;
dfRes = nx - px;

msReg = ssReg /dfReg;
msRes = ssRes/dfRes;

fRatio = msReg/msRes;
fTabel = finv(0.95, dfReg, dfRes);

if (fRatio > fTabel)
    disp('Model sesuai dengan data observasi')
else 
    disp('model tidak sesuai')
end

% R2: koefisien determinasi yang mengukur seberapa bagus performansi dari
% model

R2 = (ssReg/ssTot) * 100;