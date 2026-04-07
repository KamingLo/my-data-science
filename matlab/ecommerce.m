clear; clc; close all;

% ==========================================
% 1. MEMBACA DATA
% ==========================================
% Membaca data dari CSV
opts = detectImportOptions('data_ecommerce.csv');
data = readtable('data_ecommerce.csv', opts);

% Mengambil ukuran data
[n, ~] = size(data);

% ==========================================
% 2. PREPROCESSING: ENCODING TEKS KE ID
% ==========================================
% Mengubah data kategorikal (teks) menjadi ID numerik unik (seperti Group By)
% Menyimpan "kamus" (dictionary) agar bisa digunakan lagi saat Test Case

[dict_vehicle, ~, id_vehicle] = unique(data.Vehicle_Type);
[dict_route, ~, id_route] = unique(data.Route_Type);
[dict_traffic, ~, id_traffic] = unique(data.Traffic_Conditions);

% Menyiapkan variabel independen (X) dan dependen (Y)
x1 = id_vehicle;
x2 = id_route;
x3 = data.Distance_KM;
x4 = data.Package_Weight_KG;
x5 = id_traffic;

x0 = ones(n, 1); % Konstanta / Intercept
X = [x0 x1 x2 x3 x4 x5];
Y = data.Carbon_Emission_kgCO2e;

% ==========================================
% 3. PELATIHAN MODEL (MANUAL MATRIKS)
% ==========================================
% Menghitung koefisien (b) menggunakan inverse matrix
b = (X'*X) \ (X'*Y);

disp('--- Koefisien Model (b) ---');
disp(b);

% Menghitung prediksi dan error
Yhat = X * b;
error_abs = abs(Y - Yhat);

% ==========================================
% 4. STATISTIK & UJI ANOVA (Alpha 0.05)
% ==========================================
[nx, px] = size(X);

% Sum of Squares
ssReg = b' * (X' * Y) - (n*(mean(Y))^2);
ssRes = ((Y' * Y) - b' * (X' * Y));
ssTot = Y' * Y - (n*(mean(Y))^2);

% Degrees of Freedom
dfReg = px - 1;
dfRes = nx - px;

% Mean Squares
msReg = ssReg / dfReg;
msRes = ssRes / dfRes;

% F-Ratio & F-Tabel (Alpha 0.05 berarti confidence 0.95)
fRatio = msReg / msRes;
fTabel = finv(0.95, dfReg, dfRes);

disp('--- Hasil Uji ANOVA ---');
fprintf('F-Ratio: %.4f | F-Tabel (Alpha 0.05): %.4f\n', fRatio, fTabel);
if (fRatio > fTabel)
    disp('Status: Model SESUAI dengan data observasi (Signifikan).')
else 
    disp('Status: Model TIDAK SESUAI.')
end

% Menghitung R-Squared (Akurasi Model)
R2 = (ssReg/ssTot) * 100;
fprintf('Akurasi Model (R-Squared): %.2f%%\n\n', R2);

% ==========================================
% 5. UJI COBA (2 TEST CASE)
% ==========================================
disp('--- Hasil 2 Uji Coba (Test Cases) ---');

% Fungsi internal kecil untuk mencari ID berdasarkan kamus
get_id = @(val, dict) find(strcmp(dict, val));

% Test Case 1: Pengiriman Skala Besar (Potensi Emisi Tinggi)
tc1_vehicle = get_id('Heavy Truck', dict_vehicle);
tc1_route = get_id('Inter-City', dict_route);
tc1_dist = 450.5; % Jarak jauh
tc1_weight = 3000.0; % Berat sangat besar
tc1_traffic = get_id('High', dict_traffic);

X_test1 = [1, tc1_vehicle, tc1_route, tc1_dist, tc1_weight, tc1_traffic];
Y_pred1 = X_test1 * b;

% Test Case 2: Pengiriman Ramah Lingkungan (Potensi Emisi Rendah)
tc2_vehicle = get_id('Cargo Bicycle', dict_vehicle);
tc2_route = get_id('Urban Last Mile', dict_route);
tc2_dist = 5.0; % Jarak dekat
tc2_weight = 8.5; % Paket ringan
tc2_traffic = get_id('Low', dict_traffic);

X_test2 = [1, tc2_vehicle, tc2_route, tc2_dist, tc2_weight, tc2_traffic];
Y_pred2 = X_test2 * b;

% Evaluasi Tindakan
batas_emisi = 100; % Threshold kgCO2e untuk mengambil tindakan
pred_results = [Y_pred1, Y_pred2];
test_names = {'Test 1: Heavy Truck', 'Test 2: Cargo Bike'};

for i = 1:2
    fprintf('%s memprediksi emisi: %.2f kgCO2e.\n', test_names{i}, pred_results(i));
    if pred_results(i) > batas_emisi
        fprintf('   -> TINDAKAN: Emisi sangat tinggi! Pertimbangkan optimasi rute atau konsolidasi muatan.\n');
    else
        fprintf('   -> TINDAKAN: Emisi aman. Lanjutkan pengiriman.\n');
    end
end

% ==========================================
% 6. VISUALISASI DATA (PLOT)
% ==========================================
figure('Name', 'Analisis Regresi Emisi Karbon', 'Position', [100, 100, 1000, 600]);

% Plot 1: Akurasi (Aktual vs Prediksi) + Garis Regresi
subplot(2, 2, 1);
scatter(Y, Yhat, 25, 'b', 'filled', 'MarkerEdgeColor', 'k');
hold on;
% Membuat Garis Regresi (Garis Ideal Aktual = Prediksi)
max_val = max(max(Y), max(Yhat));
min_val = min(min(Y), min(Yhat));
plot([min_val max_val], [min_val max_val], 'r-', 'LineWidth', 2);
title(sprintf('Akurasi (Aktual vs Prediksi)\nR^2 = %.2f%%', R2));
xlabel('Emisi Aktual (kgCO2e)');
ylabel('Emisi Prediksi (kgCO2e)');
legend('Prediksi Model', 'Garis Regresi Ideal', 'Location', 'best');
grid on; hold off;

% Plot 2: Absolute Error
subplot(2, 2, 2);
plot(1:n, error_abs, '-o', 'Color', [0.8500, 0.3250, 0.0980], 'MarkerSize', 4);
title('Sebaran Absolute Error');
xlabel('Data ke-i');
ylabel('Error Absolut');
grid on;

% Plot 3: Hasil Test Case
subplot(2, 2, [3 4]); % Menggabungkan kolom bawah
b_plot = bar(pred_results, 'FaceColor', [0.4660 0.6740 0.1880]);
set(gca, 'XTickLabel', test_names);
title('Hasil Uji Coba: Prediksi Emisi berdasarkan Skenario');
ylabel('Prediksi Emisi (kgCO2e)');
yline(batas_emisi, '--r', 'Batas Peringatan Emisi', 'LineWidth', 2, 'LabelHorizontalAlignment', 'left');
grid on;

% Menambahkan nilai di atas bar chart
xtips = b_plot.XEndPoints;
ytips = b_plot.YEndPoints;
labels = string(round(b_plot.YData, 2));
text(xtips, ytips, labels, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');