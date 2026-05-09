def perceptron_xor_1_epoch():
    # Inisialisasi sesuai soal
    w = [0, 0]  # w1=0, w2=0
    b = 0       # bias=0
    alpha = 0.5   # laju pembelajaran
    theta = 0.2   # nilai ambang (threshold)
    
    # Data Pembelajaran Tabel Kebenaran XOR: [X1, X2, Target(t)]
    data = [
        [1, 1, 1],
        [0, 1, 0],
        [1, 0, 0],
        [0, 0, 0]
    ]
    
    print(f"Inisialisasi: w1={w[0]}, w2={w[1]}, b={b}, alpha={alpha}, theta={theta}\n")
    
    # Looping untuk 1 Epoch
    for i, (x1, x2, t) in enumerate(data):
        print(f"--- Data ke-{i+1} : X1={x1}, X2={x2}, Target(t)={t} ---")
        
        # Langkah 4: Hitung y_in
        y_in = b + (x1 * w[0]) + (x2 * w[1])
        
        # Fungsi Aktivasi
        if y_in > theta:
            y = 1
        elif -theta <= y_in <= theta:
            y = 0
        else:
            y = -1
            
        print(f"y_in = {b} + ({x1} * {w[0]}) + ({x2} * {w[1]}) = {y_in}")
        print(f"Output (y) = {y}")
        
        # Langkah 5: Evaluasi & Update Bobot
        if y != t:
            print(f"y != t ({y} != {t}) -> Update Bobot")
            w[0] = w[0] + (alpha * t * x1)
            w[1] = w[1] + (alpha * t * x2)
            b = b + (alpha * t)
        else:
            print(f"y == t ({y} == {t}) -> Tidak Ada Update Bobot")
            
        print(f"Bobot Saat Ini: w1={w[0]}, w2={w[1]}, b={b}\n")
        
    print("=== Hasil Akhir Setelah 1 Epoch ===")
    print(f"w1 = {w[0]}")
    print(f"w2 = {w[1]}")
    print(f"b  = {b}")

# Menjalankan fungsi
perceptron_xor_1_epoch()