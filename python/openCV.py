<<<<<<< HEAD
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
=======
import cv2
import os
from ultralytics import YOLO
import argparse

# Fix untuk environment Linux/Wayland & RTSP TCP
os.environ["QT_QPA_PLATFORM"] = "xcb"
os.environ["OPENCV_FFMPEG_CAPTURE_OPTIONS"] = "rtsp_transport;tcp"

def main():
    parser = argparse.ArgumentParser(description="YOLOv8 Detection with Camera or CCTV")
    parser.add_argument("--source", choices=["camera", "cctv"], required=True, help="Pilih sumber: camera atau cctv")
    args = parser.parse_args()

    # 1. Load Model (Akan mendownload otomatis saat pertama kali dijalankan)
    model = YOLO("yolov8n.pt") 

    # 2. Setup Koneksi berdasarkan source
    if args.source == "camera":
        cap = cv2.VideoCapture(0)  # Kamera laptop
    elif args.source == "cctv":
        rtsp_url = "rtsp://admin:123456@192.168.1.3:554/chID=5&streamType=sub"
        cap = cv2.VideoCapture(rtsp_url, cv2.CAP_FFMPEG)
        cap.set(cv2.CAP_PROP_BUFFERSIZE, 1)

    if not cap.isOpened():
        print("Gagal koneksi ke sumber video.")
        return

    print("Model loaded & Video Connected. Jalankan deteksi...")

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        # 3. Jalankan Inferensi
        # stream=True bikin penggunaan memori lebih hemat
        results = model.predict(frame, conf=0.4, stream=False, verbose=False)

        # 4. Gambar hasil deteksi ke frame (Bounding Boxes, Labels)
        annotated_frame = results[0].plot()

        # Tampilkan hasil
        cv2.imshow("YOLOv8 Detection", annotated_frame)

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    main()
