clear; clc;

% --- Inisialisasi Paket (WAJIB di Octave) ---
pkg load io
pkg load statistics

% Membaca data
% Pastikan file PCA.xlsx berada di folder yang sama dengan skrip ini
try
    data = xlsread('PCA.xlsx');
catch
    error('File PCA.xlsx tidak ditemukan atau paket "io" belum terinstal dengan benar.');
end

[n,p] = size(data);
men = mean(data);

% Mengurangi data dengan mean (Center the data)
% Tips: Di Octave/Matlab, Anda bisa langsung: Z = data - men;
Z = zeros(n,p);
for i = 1:n
    kurang = data(i,:) - men;
    Z(i,:) = kurang;
end

% Menghitung covariance matrix
S = cov(Z);

% Standarization data
% Catatan: PCA standar biasanya membagi dengan Standar Deviasi (sqrt dari varians)
% Jika ingin mengikuti rumus Z-score standar: Zr(i,j) = Z(i,j) / sqrt(S(j,j))
Zr = zeros(n,p);
for i = 1:n
    for j = 1:p
        Zr(i,j) = Z(i,j) / S(j,j); 
    end
end

% 2. Menghitung Cov dari data yang sudah direduksi
Zcov = cov(Zr); 

% 3. Menghitung eigen value dan eigen vector
[V,D] = eig(Zcov);

% 4. Mengurutkan eigen dari besar ke kecil
[d, ind] = sort(diag(D), 'descend');
DA_urut = diag(d);
VA_urut = V(:, ind);

eValue = diag(DA_urut);
Total = sum(eValue);

% Proporsi kumulatif
PK = 0;
Komponen = 0; 

proporsiValue = eValue / Total;
for j = 1:p
    if (PK < 0.9) 
        PK = PK + proporsiValue(j);
        Komponen = Komponen + 1;
    end
end

% Ambil eigen vector komponen terpilih
VA_Komponen = VA_urut(:, 1:Komponen);
W = Zr * VA_Komponen;

% Visualisasi
figure(1);
if Komponen >= 3
    plot3(W(:,1), W(:,2), W(:,3), '*');
    xlabel('PC 1'); ylabel('PC 2'); zlabel('PC 3');
else
    plot(W(:,1), W(:,2), '*');
    xlabel('PC 1'); ylabel('PC 2');
end
title('Hasil Reduksi Dimensi PCA');
grid on;

% Menahan jendela plot agar tidak langsung tertutup di VS Code
fprintf('Proses selesai. Tekan sembarang tombol di command window untuk menutup plot.\n');
waitforbuttonpress();