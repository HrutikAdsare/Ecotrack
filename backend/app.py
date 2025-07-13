from flask import Flask, request, jsonify
from ultralytics import YOLO
from PIL import Image
from flask_cors import CORS
import io

app = Flask(__name__)
CORS(app)

# Load your trained YOLOv8 model
model = YOLO("runs/detect/train3/weights/best.pt")  # Update path if needed

# Endpoint for waste detection
@app.route('/detect', methods=['POST'])
def detect():
    if 'image' not in request.files:
        return jsonify({'error': 'No image file uploaded'}), 400

    try:
        image_file = request.files['image']
        image = Image.open(image_file.stream).convert("RGB")

        # Run detection
        results = model(image)
        boxes = results[0].boxes
        predictions = []

        for box in boxes:
            x1, y1, x2, y2 = map(float, box.xyxy[0].tolist())
            width, height = x2 - x1, y2 - y1

            predictions.append({
                'class': model.names[int(box.cls[0])],
                'confidence': float(box.conf[0]),
                'box': {
                    'x': round(x1, 2),
                    'y': round(y1, 2),
                    'width': round(width, 2),
                    'height': round(height, 2)
                }
            })

        return jsonify({'predictions': predictions})

    except Exception as e:
        return jsonify({'error': str(e)}), 500


if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000, debug=True)
