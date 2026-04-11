import torch
import cv2
from ultralytics import YOLO

# --- TEST KONEKSI GPU ---
print(f"Versi PyTorch: {torch.__version__}")
if torch.cuda.is_available():
    device = 0 # Menggunakan GPU pertama
    print(f"GPU Terdeteksi: {torch.cuda.get_device_name(0)}")
else:
    device = 'cpu'
    print("GPU TIDAK terdeteksi, menggunakan CPU.")

# --- LOAD MODEL KE DEVICE ---
# .to(device) memastikan model masuk ke memori GPU (VRAM)
model = YOLO('yolov8n.pt').to(device)

rtsp_url = "rtsp://admin:123456@192.168.1.3:554/chID=1&streamType=sub"
cap = cv2.VideoCapture(rtsp_url, cv2.CAP_FFMPEG)

# Optimasi untuk RTSP agar tidak lag
cap.set(cv2.CAP_PROP_BUFFERSIZE, 1)

while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        continue

    # --- INFERENSI DENGAN GPU ---
    # device=device: memberitahu YOLO untuk proses di GPU
    # half=True: (Khusus GPU) Menggunakan presisi FP16 agar lebih ngebut & hemat VRAM
    results = model(frame, stream=True, device=device, half=(device == 0))

    for r in results:
        annotated_frame = r.plot()
        cv2.imshow("MSI GF63 - YOLO GPU Test", annotated_frame)

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()