clear; clc;

data = xlsread('DataCookDistance.xlsx');

[n,p] = size(data);

x0 = ones(n,1);
x = data(:,1:5);
y = data(:,6);

xModel1 = [x0 x];

b = (xModel1' * xModel1) \ (xModel1' * y);

yhat = xModel1 * b;
error = y - yhat;

hasil = [y yhat error];


ssReg = b' * (xModel1' * y) - n*(mean(y))^2;
ssRes = ((y' * y) - (b' * (xModel1' * y)));
ssTot = y' * y - n*(mean(y))^2;

[nx, px] = size(xModel1);

dfReg = px -1;
dfRes = nx - px;

msReg = ssReg / dfReg;
msRes = ssRes / dfRes;

fHitung = msReg / msRes;
fTabel = finv(0.95, dfReg, dfRes);

R2 = (ssReg/ssTot) * 100;

H = xModel1 * ((xModel1' * xModel1) \ xModel1');

Hii = zeros(n, 1);
for i = 1:n
    for j = 1:n
        if i == j
            Hii(i, 1) = H(i, j);
        end
    end
end

di = ((error.^2)/(px*msRes)).*(Hii./(1-Hii).^2);
Eii = error.^2;
hasil2 = [Eii Hii di];

plot(di, '*');

di_rata = mean(di);
cutoff= 3*di_rata;
k=0;

observasi = ones(n, 1);
for i = 1:n
    if di(i) > cutoff
        k = k + 1;
        observasi(k,1)=i;
    end
end
observasi;

k=0;
data_bersih = zeros(n, p);
for i = 1:n
    if (di(i)<=cutoff)
        k=k+1;
        data_bersih(k,:) = data(i,:);
    end
end
 
[nb,pb] = size(data_bersih);
 
%memisahkan variabel x dan y
x0 = ones(nb,1);
x1= data_bersih(:, 1:5);
y1=data_bersih(:,6);
 
xModel2 = [x0 x1];
 
%b1 = koefisien regresi tanpa melibatkan outlier
b1 = (xModel2' * xModel2) \ (xModel2' *y1);
 
%model1 = 10.5618+ 0.074x1 - 0.0254x2 + 0.0569x3 - 0.2137x4 + 0.8497x5
 
yhat1 = xModel2 * b1;
error1 = y1 - yhat1;
 
hasil3 = [y1 yhat1 error1];
 
%ANOVA Table - Regression
ssReg1 = b1' *(xModel2' * y1) - nb*(mean(y1))^2;%sum of square of regression
ssRes1 = ((y1' * y1)- (b1' *(xModel2' * y1))); 
%ssRes = (y' * y) - ssReg
ssTot1 = y1' * y1 - nb*(mean(y1))^2;
 
[nx1,px1] = size(xModel2);
 
dfReg1 = px1;
msReg1 = ssReg1/dfReg1;
 
dfRes1 = nx1;
msRes1 = ssRes1/dfRes1;
 
fHitung1 = msReg1/msRes1;
fTabel1 = finv(0.95, dfReg1, dfRes1);
 
R2_bersih = ssReg1/ssTot1*100;