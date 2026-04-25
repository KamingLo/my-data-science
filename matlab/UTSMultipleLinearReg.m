clc; clear;

% 1. Load Data
data = xlsread('DATA Soal UTS 2026 -TIPE 2.xlsx', 'Regression'); 

[n,p] = size(data);

% Memisahkan variabel x dan y
Y = data(:,5);
x1 = data(:,1:4);
x0 = ones(n,1);

X = [x0 x1];

% 2. Perhitungan Regresi Awal
b = inv(X'*X) * (X'*Y); % Koefisien regresi
Yhat = X*b;             % Nilai prediksi
error = Y - Yhat;       % Sisa (residual)

[nx, px] = size(X);

% --- ANOVA & R2 Model Awal ---
ssReg = b' * (X' * Y) - (n*(mean(Y))^2);
ssRes = ((Y' *Y) - b' * (X' *Y));
ssTot = Y' * Y -(n*(mean(Y))^2);

dfReg = px -1;
dfRes = nx - px;

msReg = ssReg /dfReg;
msRes = ssRes/dfRes;

fRatio = msReg/msRes;
fTabel = finv(0.95, dfReg, dfRes);
R2 = (ssReg/ssTot) * 100;

% --- Visualisasi 1: Plot Model dengan Outlier ---
figure(1);
plot(Y, Yhat, 'ob', 'DisplayName', 'Data Observasi'); 
hold on; grid on;
% Garis diagonal ideal (Y = Yhat)
ref_line = [min(Y), max(Y)];
plot(ref_line, ref_line, 'r-', 'LineWidth', 2, 'DisplayName', 'Garis Ideal');
xlabel('Nilai Asli (Y)');
ylabel('Nilai Prediksi (Y-Hat)');
title(['Model AWAL (Masih Ada Outlier) - R^2: ', num2str(R2, '%.2f'), '%']);
legend('Location', 'northwest');

% Menampilkan status model awal di Command Window
disp('--- ANALISIS MODEL AWAL ---');
if (fRatio > fTabel)
    disp('Model sesuai dengan data observasi');
else 
    disp('Model tidak sesuai');
end
disp(['R-Square Model Awal: ', num2str(R2, '%.2f'), '%']);


% 3. Perhitungan Hat Matrix dan Cook Distance
H = X * inv(X' * X) * X';

% Mengambil diagonal utama Hat Matrix secara manual
for i = 1:n
    for j = 1:n
        if i == j
            Hii(i,1) = H(i,j);
        end
    end
end

% Hitung Cook's Distance
di = ((error.^2) / (px*(msRes))) .* (Hii ./ (1-Hii).^2);

% --- Visualisasi 2: Plot Cook's Distance ---
figure(2);
plot(di, '*', 'Color', [0.85 0.32 0.1]);
hold on; grid on;
di_rata = mean(di);
cutoff = 3 * di_rata;
line([0 n], [cutoff cutoff], 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1.5);
title('Identifikasi Outlier (Cook''s Distance)');
xlabel('Indeks Data');
ylabel('Nilai Cook Distance');
legend('Data', 'Batas Cutoff (3 x Rata-rata)');

% 4. Deteksi dan Pembersihan Outlier
k=0;
outlier = [];
for i = 1:n
    if (di(i) > cutoff)
        k = k + 1;
        outlier(k,1) = i;
    end
end

% Membuat dataset baru tanpa observasi outlier
k=0;
data_bersih = []; 
for i = 1:n
    if (di(i)<=cutoff)
        k=k+1;
        data_bersih(k,:) = data(i,:);
    end
end

disp(' ');
disp(['Jumlah data awal: ', num2str(n)]);
disp(['Outlier yang dibuang: ', num2str(size(outlier, 1))]);
disp(['Sisa data (data bersih): ', num2str(k)]);

% 5. Regresi Baru (Tanpa Outlier)
[nb,pb] = size(data_bersih);
x0_bersih = ones(nb,1);
x1_bersih = data_bersih(:, 1:4);
y1_bersih = data_bersih(:,5);

xModel2 = [x0_bersih x1_bersih];

% Koefisien regresi baru
b1 = (inv(xModel2' * xModel2) * (xModel2' *y1_bersih));
yhat1 = xModel2 * b1;

% ANOVA Model Baru
ssReg1 = b1' *(xModel2' * y1_bersih) - nb*(mean(y1_bersih))^2; 
ssTot1 = y1_bersih' * y1_bersih - nb*(mean(y1_bersih))^2;
R2_bersih = (ssReg1/ssTot1) * 100;

% --- Visualisasi 3: Plot Model SETELAH Outlier Dibuang ---
figure(3);
plot(y1_bersih, yhat1, 'og', 'DisplayName', 'Data Bersih'); 
hold on; grid on;
ref_line_bersih = [min(y1_bersih), max(y1_bersih)];
plot(ref_line_bersih, ref_line_bersih, 'r-', 'LineWidth', 2, 'DisplayName', 'Garis Ideal');
xlabel('Nilai Asli (Y-Bersih)');
ylabel('Nilai Prediksi (Y-Hat Baru)');
title(['Model BARU (Outlier Sudah Dibuang) - R^2: ', num2str(R2_bersih, '%.2f'), '%']);
legend('Location', 'northwest');

disp(' ');
disp('--- ANALISIS MODEL BARU ---');
disp('Koefisien b1 (Intercept & Slope baru):');
disp(b1);
disp(['R-Square Model Baru: ', num2str(R2_bersih, '%.2f'), '%']);