<<<<<<< HEAD
import torch

print(f"Versi PyTorch: {torch.__version__}")
if torch.cuda.is_available():
    device = 0 # Menggunakan GPU pertama
    print(f"GPU Terdeteksi: {torch.cuda.get_device_name(0)}")
else:
    device = 'cpu'
    print("GPU TIDAK terdeteksi, menggunakan CPU.")
=======
import psutil
import time

def check_temperatures():
    # Mengambil data sensor suhu
    temps = psutil.sensors_temperatures()
    
    if not temps:
        print("Sensus tidak terdeteksi. Pastikan driver lm-sensors sudah terpasang.")
        return

    print(f"{'Sensor':<20} | {'Current':<10} | {'High':<10} | {'Critical':<10}")
    print("-" * 60)

    for name, entries in temps.items():
        for entry in entries:
            label = entry.label or name
            current = f"{entry.current}°C"
            high = f"{entry.high}°C" if entry.high else "N/A"
            critical = f"{entry.critical}°C" if entry.critical else "N/A"
            
            # Highlight jika suhu mendekati kritis
            alert = " [!] PANAS" if entry.critical and entry.current >= (entry.critical - 5) else ""
            
            print(f"{label:<20} | {current:<10} | {high:<10} | {critical:<10}{alert}")

if __name__ == "__main__":
    try:
        while True:
            # Membersihkan layar terminal (opsional)
            print("\033c", end="") 
            print("=== MONITORING SUHU HARDWARE ===")
            check_temperatures()
            print("\nTekan Ctrl+C untuk berhenti...")
            time.sleep(2)
    except KeyboardInterrupt:
        print("\nMonitoring dihentikan.")
>>>>>>> 9f8dfe8cf76aa60aa9c3be99d71618f9ead6c1e5
