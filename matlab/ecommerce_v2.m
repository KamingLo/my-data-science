clear; clc;

opts = detectImportOptions('data_ecommerce.csv');
data = readtable('data_ecommerce.csv', opts);
[n, ~] = size(data);

[dict_vehicle, ~, id_vehicle] = unique(data.Vehicle_Type);
[dict_traffic, ~, id_traffic] = unique(data.Traffic_Conditions);

x1 = id_vehicle;
x2 = data.Distance_KM;
x3 = data.Package_Weight_KG;
x4 = id_traffic;

x0 = ones(n, 1);
X = [x0 x1 x2 x3 x4];
Y = data.Carbon_Emission_kgCO2e;

b = (X'*X) \ (X'*Y); 

disp('--- Koefisien Model Versi 2 (b) ---');
disp(b);

Yhat = X * b;
error_abs = abs(Y - Yhat);

[nx, px] = size(X);

ssReg = b' * (X' * Y) - (n*(mean(Y))^2);
ssRes = ((Y' * Y) - b' * (X' * Y));
ssTot = Y' * Y - (n*(mean(Y))^2);

dfReg = px - 1;
dfRes = nx - px;

msReg = ssReg / dfReg;
msRes = ssRes / dfRes;

fRatio = msReg / msRes;
fTabel = finv(0.95, dfReg, dfRes);

disp('--- Hasil Uji ANOVA Versi 2 ---');
fprintf('F-Ratio: %.4f | F-Tabel: %.4f\n', fRatio, fTabel);
if (fRatio > fTabel)
    disp('Status: Model SESUAI dengan data observasi.')
else 
    disp('Status: Model TIDAK SESUAI.')
end

R2 = (ssReg/ssTot) * 100;
fprintf('Akurasi Model Versi 2 (R-Squared): %.2f%%\n\n', R2);

disp('--- Hasil 2 Uji Coba Skenario ---');
get_id = @(val, dict) find(strcmp(dict, val));

% Test Case 1: Heavy Truck
tc1_vehicle = get_id('Heavy Truck', dict_vehicle);
tc1_dist = 450.5; 
tc1_weight = 3000.0; 
tc1_traffic = get_id('High', dict_traffic);

X_test1 = [1, tc1_vehicle, tc1_dist, tc1_weight, tc1_traffic];
Y_pred1 = X_test1 * b;

tc2_vehicle = get_id('Cargo Bicycle', dict_vehicle);
tc2_dist = 5.0; 
tc2_weight = 8.5; 
tc2_traffic = get_id('Low', dict_traffic);

X_test2 = [1, tc2_vehicle, tc2_dist, tc2_weight, tc2_traffic];
Y_pred2 = X_test2 * b;

batas_emisi = 100; 
pred_results = [Y_pred1, Y_pred2];
test_names = {'Test 1: Heavy Truck', 'Test 2: Cargo Bike'};

for i = 1:2
    fprintf('%s memprediksi emisi: %.2f kgCO2e.\n', test_names{i}, pred_results(i));
    if pred_results(i) > batas_emisi
        fprintf('   -> TINDAKAN: Emisi tinggi! Optimasi muatan/armada diperlukan.\n');
    else
        fprintf('   -> TINDAKAN: Emisi aman.\n');
    end
end

figure('Name', 'Analisis Regresi Versi 2 (4 Variabel)', 'Position', [100, 100, 1000, 600]);

subplot(2, 2, 1);
scatter(Y, Yhat, 25, 'b', 'filled', 'MarkerEdgeColor', 'k');
hold on;
max_val = max(max(Y), max(Yhat));
min_val = min(min(Y), min(Yhat));
plot([min_val max_val], [min_val max_val], 'r-', 'LineWidth', 2);
title(sprintf('Akurasi Versi 2\nR^2 = %.2f%%', R2));
xlabel('Emisi Aktual (kgCO2e)');
ylabel('Emisi Prediksi (kgCO2e)');
legend('Prediksi Model', 'Garis Regresi Ideal', 'Location', 'best');
grid on; hold off;

subplot(2, 2, 2);
plot(1:n, error_abs, '-o', 'Color', [0.8500, 0.3250, 0.0980], 'MarkerSize', 4);
title('Sebaran Absolute Error (Versi 2)');
xlabel('Data ke-i');
ylabel('Error Absolut');
grid on;

subplot(2, 2, [3 4]); 
b_plot = bar(pred_results, 'FaceColor', [0.4660 0.6740 0.1880]);
set(gca, 'XTickLabel', test_names);
title('Hasil Uji Coba: Skenario 4 Variabel');
ylabel('Prediksi Emisi (kgCO2e)');
yline(batas_emisi, '--r', 'Batas Peringatan Emisi', 'LineWidth', 2, 'LabelHorizontalAlignment', 'left');
grid on;

xtips = b_plot.XEndPoints;
ytips = b_plot.YEndPoints;
labels = string(round(b_plot.YData, 2));
text(xtips, ytips, labels, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');