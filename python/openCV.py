import cv2
import os
from ultralytics import YOLO

# Fix untuk environment Linux/Wayland & RTSP TCP
os.environ["QT_QPA_PLATFORM"] = "xcb"
os.environ["OPENCV_FFMPEG_CAPTURE_OPTIONS"] = "rtsp_transport;tcp"

def main():
    # 1. Load Model (Akan mendownload otomatis saat pertama kali dijalankan)
    model = YOLO("yolov8n.pt") 

    # 2. Setup Koneksi RTSP
    rtsp_url = "rtsp://admin:123456@192.168.1.3:554/chID=5&streamType=sub"
    cap = cv2.VideoCapture(rtsp_url, cv2.CAP_FFMPEG)
    cap.set(cv2.CAP_PROP_BUFFERSIZE, 1)

    if not cap.isOpened():
        print("Gagal koneksi ke DVR.")
        return

    print("Model loaded & RTSP Connected. Jalankan deteksi...")

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
        cv2.imshow("YOLOv8 RTSP Detection", annotated_frame)

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    main()