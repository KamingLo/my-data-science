import multiprocessing
import psutil
import time
import os
import math

# Fungsi utama untuk beban kerja
def stress_task(output_queue):
    count = 0
    start_time = time.time()
    # Menjalankan loop selama 15 detik untuk konsistensi benchmark
    while time.time() - start_time < 300:
        # Operasi matematika berat
        math.sqrt(12345.6789) ** 2.5
        count += 1
    # Kirim jumlah operasi yang berhasil diselesaikan ke queue
    output_queue.put(count)

def run_benchmark():
    cpu_cores = multiprocessing.cpu_count()
    queue = multiprocessing.Queue()
    processes = []

    print(f"--- MEMULAI BENCHMARK (15 Detik) ---")
    print(f"Menggunakan {cpu_cores} Cores CPU...")
    
    # Pantau suhu awal
    start_temp = "N/A"
    temps = psutil.sensors_temperatures()
    if temps:
        for name, entries in temps.items():
            start_temp = f"{entries[0].current}°C"
    
    print(f"Suhu Awal: {start_temp}")
    print("Sedang menghitung skor... Harap jangan gunakan komputer.")

    # Jalankan proses di tiap core
    for _ in range(cpu_cores):
        p = multiprocessing.Process(target=stress_task, args=(queue,))
        p.start()
        processes.append(p)

    # Tunggu semua proses selesai
    total_operations = 0
    for p in processes:
        total_operations += queue.get()
        p.join()

    # Pantau suhu akhir
    end_temp = "N/A"
    temps = psutil.sensors_temperatures()
    if temps:
        for name, entries in temps.items():
            end_temp = f"{entries[0].current}°C"

    # Kalkulasi Skor
    # Kita bagi 1.000.000 agar angka tidak terlalu panjang (Mega-Ops)
    final_score = int(total_operations / 10000)

    print("\n" + "="*30)
    print("       HASIL BENCHMARK")
    print("="*30)
    print(f"Total Operasi : {total_operations:,}")
    print(f"Suhu Akhir    : {end_temp}")
    print(f"SKOR AKHIR    : {final_score} PTS")
    print("="*30)
    
    # Interpretasi sederhana
    if final_score > 5000:
        print("Kategori: Monster Performa 🚀")
    elif final_score > 2500:
        print("Kategori: Sangat Kencang ⚡")
    else:
        print("Kategori: Standar / Hemat Daya 🔋")

if __name__ == "__main__":
    run_benchmark()
