# 🌱 EcoTrack

**EcoTrack** is a Flutter-based mobile application that empowers users to live more sustainably. From calculating carbon footprints to identifying waste types using machine learning, EcoTrack provides tools for eco-conscious decisions in everyday life.

## 🌍 Features

- ♻️ **Carbon Footprint Calculator**

  - Supports multiple categories like Car, Electricity, Fuel Combustion, and Shipping.

- 🛒 **Sustainable Shopping**

  - Barcode scanning to check eco-friendly product alternatives.

- 💑 **Waste Classification**

  - Uses a YOLOv8 TFLite model to classify waste into appropriate categories.

- 🔐 **User Authentication**

  - Local login system using SQLite for secure and fast access.

---

## 🧠 Tech Stack

| Area             | Tech                                         |
| ---------------- | -------------------------------------------- |
| Frontend         | Flutter, Dart                                |
| ML Model         | YOLOv8 (converted to TFLite)                 |
| Database         | SQLite                                       |
| Barcode Scanning | `google_ml_kit` or `flutter_barcode_scanner` |
| Image Handling   | `image_picker`, `camera`                     |

---

## 📁 Folder Structure

```
EcoTrack/
├── assets/
│   └── ... (icons, sample images)
├── backend/ 👈 You may also Download this from Hugging Face
│   ├── runs/
│   ├── detect/
│   ├── train3/
│   └── weights/
├── lib/
│   ├── screens/
│   ├── database/
│   └── main.dart
├── pubspec.yaml
└── README.md
```

---

## 🚀 Getting Started

1. **Clone the Repository**

```bash
git clone https://github.com/your-username/EcoTrack.git
cd EcoTrack
```

2. **Download ML Backend**

Download the `backend/` folder (YOLOv8 TFLite model and weights) from [Hugging Face](https://huggingface.co/) or use the included files if already present in the repo.

3. **Install Dependencies**

```bash
flutter pub get
```

4. **Run the App**

```bash
flutter run
```

---

## 📷 YOLOv8 Model Integration

- The waste classifier model (`best_float32.tflite`) is used for real-time or static image predictions.
- You can find the model and required assets inside the `backend/` directory.

---

## 👨‍💻 Developer

Built with ❤️ by [Hrutik Adsare](https://huggingface.co/Hrutik-Adsare)

