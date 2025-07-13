import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

class WasteClassificationScreen extends StatefulWidget {
  @override
  _WasteClassificationScreenState createState() =>
      _WasteClassificationScreenState();
}

class _WasteClassificationScreenState extends State<WasteClassificationScreen> {
  File? _image;
  List<dynamic> _results = [];
  bool _isLoading = false;

  double? _imageWidth;
  double? _imageHeight;

  final GlobalKey _imageContainerKey = GlobalKey();

  final String flaskApiUrl = "http://192.168.137.21:5000/detect";

  final Map<String, Color> labelColors = {
    "plastic": Colors.red,
    "glass": Colors.green,
    "metal": Colors.blue,
    "paper": Colors.orange,
    "cardboard": Colors.purple,
    "organic": Colors.brown,
    "e-waste": Colors.teal,
    "medical": Colors.pink,
    "other": Colors.grey,
  };

  Future<void> _captureImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final bytes = await file.readAsBytes();
      final decodedImage = await decodeImageFromList(bytes);

      setState(() {
        _image = file;
        _results.clear();
        _isLoading = true;
        _imageWidth = decodedImage.width.toDouble();
        _imageHeight = decodedImage.height.toDouble();
      });

      await _detectObjects(file.path);
    }
  }

  Future<void> _detectObjects(String path) async {
    try {
      final uri = Uri.parse(flaskApiUrl);
      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('image', path));
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonData = json.decode(responseData);
        setState(() {
          _results = jsonData['predictions'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print('Failed to detect objects: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error: $e');
    }
  }

  List<Widget> _buildBoundingBoxes(BoxConstraints constraints) {
    if (_imageWidth == null || _imageHeight == null) return [];

    final scaleX = constraints.maxWidth / _imageWidth!;
    final scaleY = constraints.maxHeight / _imageHeight!;

    return _results.map((res) {
      final label = res['class'];
      final confidence = res['confidence'];
      final box = res['box'];
      final color = labelColors[label.toLowerCase()] ?? Colors.cyan;

      return Positioned(
        left: box['x'] * scaleX,
        top: box['y'] * scaleY,
        width: box['width'] * scaleX,
        height: box['height'] * scaleY,
        child: Container(
          decoration: BoxDecoration(border: Border.all(color: color, width: 2)),
          child: Align(
            alignment: Alignment.topLeft,
            child: Container(
              color: color.withOpacity(0.85),
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                "$label (${(confidence * 100).toStringAsFixed(1)}%)",
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          _results.map((res) {
            final label = res['class'];
            final color = labelColors[label.toLowerCase()] ?? Colors.cyan;
            return Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  color: color,
                  margin: EdgeInsets.only(right: 6),
                ),
                Text("$label", style: TextStyle(fontSize: 14)),
              ],
            );
          }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Waste Classification"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _captureImage,
              child: Text("Capture Waste Image"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
            SizedBox(height: 12),
            if (_isLoading) CircularProgressIndicator(),
            if (_image != null && !_isLoading)
              Expanded(
                child: LayoutBuilder(
                  key: _imageContainerKey,
                  builder: (context, constraints) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(_image!, fit: BoxFit.contain),
                        ..._buildBoundingBoxes(constraints),
                      ],
                    );
                  },
                ),
              ),
            if (_results.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: _buildLegend(),
              ),
          ],
        ),
      ),
    );
  }
}
