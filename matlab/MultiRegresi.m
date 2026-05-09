clear; clc;

data = xlsread('PCA.xlsx');
[n,p] = size(data);

men = mean(data);

%mengurangi data dengan mean
%z = data kurang

Z = zeros(n,p);

for i = 1:n
    kurang = data(i,:) - men;
    Z(i,:) = kurang;
end

% menghitung covariance matrix
S = cov(Z);

% standarization data
for i = 1:n
    for j = 1:p
        Zr(i,j) = Z(i,j) / S(j,j); %di tutorial linse tidak ada
    end
end

%ZR adalah hasil dari normalisasi data X (data awal)

%2. Menghitung Cov dari data yang sudah direduksi
Zcov = cov(Zr); % matrix covarian dari variable hasil normalisasi

%3. Menghitung eigen value dan eigen vector dari Zcov
%D adalah eigen value dalam bentuk matriks diagonal
%V adalah eigenvector

[V,D] = eig(Zcov);

%4. Menghitung komponen utama
% hasil library matlab eig(): menghitung eigen vector dan eigen value
% hasil eig terurut dari nilai kecil ke besar untuk eigen value & Vector
% padahal yang diperlukan adalah eig dari besar ke kecil

% perlu diurutkan hasil eig dari besar ke kecil
% proses pengurutan eig besar ke kecil

m = 1;
for i = p:-1:1
    DA_urut(m,m) = D(i,i);
    VA_urut(:,m) = V(:,i);
    m = m + 1;
end

%menghitung komponen utama
for i = 1:p
    eValue(i,1) = DA_urut(i,i);
    % eValue adalah perintah menjadikan eigen value urut
    % berbentuk matriks diagonal menjadi eigen value bentuk vektor
end

Total = sum(eValue); %total varians dalam data asli yang dapat dijelaskan oleh seluruh

%proporsi kumulatif
% -> mengambil daya seberapa persen secara kumulatif yang dianggap perlu
PK = 0;
Komponen = 0; % jumlah komponen utama yang dipertahankan

for j = 1:p
    proporsiValue(j,1) = eValue(j,1)/ Total;
    %proporsi value mengukur seberapa besar kontribusi eigenvalue terhadap
    %varians total data
    if (PK < 0.9) %nilai PK tergantung peneliti. misal value 86% dari variasi
        PK = PK + proporsiValue(j,:);
        Komponen = Komponen + 1;
    end
end

% mengambil eigen vector dari komponen yang terpilih
VA_Komponen = VA_urut(:,1:Komponen);
%VA_Komponen berperan untuk menentukan variabel W

% W = variabel komponen utama / principal component variable
% W adalah hasil reduksi dimensi
W = Zr * VA_Komponen;

clear plot
plot3 (W(:,1), W(:,2), W(:,3), '*')
%plot (W(:,1), W(:,2), '*')
grid on

Zbaru = W * VA_Komponen' ;
m = 1;

%sqrt(S(1,1))
for t=p:-1:1
    Stt(m,m) = (S(t,t));
    m = m + 1;
end

Xbaru = Zbaru * Stt;
%matriksrata = ones(n,p) * men';
Xbaru = Xbaru + men;

%imread = image read (Perintah untuk mengubah gambar menjadi angka)

% 1. input X
% 2. X => Z
% 