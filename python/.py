import torch

print(f"Versi PyTorch: {torch.__version__}")
if torch.cuda.is_available():
    device = 0 # Menggunakan GPU pertama
    print(f"GPU Terdeteksi: {torch.cuda.get_device_name(0)}")
else:
    device = 'cpu'
    print("GPU TIDAK terdeteksi, menggunakan CPU.")
