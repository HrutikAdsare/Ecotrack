// lib/screens/sustainable_shopping_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Make sure this import points to your existing BarcodeScannerScreen.
import 'barcode_scanner_screen.dart';

class SustainableShoppingScreen extends StatefulWidget {
  @override
  _SustainableShoppingScreenState createState() =>
      _SustainableShoppingScreenState();
}

class _SustainableShoppingScreenState extends State<SustainableShoppingScreen> {
  // Will hold the entire "product" JSON from OpenFoodFacts
  Map<String, dynamic>? _productData;
  bool _isLoading = false;

  /// Launch the barcode scanner and wait for a result (String).
  Future<void> _scanBarcode() async {
    final barcode = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BarcodeScannerScreen()),
    );

    if (barcode != null && barcode is String && barcode.isNotEmpty) {
      _fetchProductDetails(barcode);
    }
  }

  /// Fetch the product JSON from OpenFoodFacts for the scanned barcode.
  Future<void> _fetchProductDetails(String barcode) async {
    setState(() {
      _isLoading = true;
      _productData = null;
    });

    final response = await http.get(
      Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcode.json'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 1 && data['product'] != null) {
        setState(() {
          _productData = data['product'];
        });
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  /// Builds the entire scrollable “product info” area, mimicking OFF’s sections.
  Widget _buildProductInfo() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (_productData == null) {
      return SizedBox();
    }

    final data = _productData!;

    // 1) Header: Image, name, brand, Nutri-Score, Eco-Score
    Widget headerSection() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data['image_front_url'] != null)
            Center(
              child: Image.network(
                data['image_front_url'],
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
          SizedBox(height: 8),
          Text(
            data['product_name'] ?? 'Unknown Product',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            "Brand: ${data['brands'] ?? 'N/A'}",
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              if (data['nutriscore_grade'] != null) ...[
                Text(
                  "Nutrition: ",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  data['nutriscore_grade'].toString().toUpperCase(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange, // badge color
                  ),
                ),
              ],
            ],
          ),
          if (data['nutriscore_grade'] != null) SizedBox(height: 4),
          Row(
            children: [
              if (data['ecoscore_grade'] != null) ...[
                Text(
                  "Eco-Score: ",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  data['ecoscore_grade'].toString().toUpperCase(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green, // badge color
                  ),
                ),
              ],
            ],
          ),
        ],
      );
    }

    // 2) Nutrition Facts Section (Energy, Fat, Carbs, Sugars, Proteins)
    Widget nutritionSection() {
      final nutriments = data['nutriments'] as Map<String, dynamic>?;
      if (nutriments == null) return SizedBox();

      // Try to pull common fields (kcal, fat, carbs, sugars, proteins)
      final energy =
          nutriments['energy-kcal_100g'] ?? nutriments['energy-kcal_serving'];
      final fat = nutriments['fat_100g'] ?? nutriments['fat_serving'];
      final carbs =
          nutriments['carbohydrates_100g'] ??
          nutriments['carbohydrates_serving'];
      final sugars = nutriments['sugars_100g'] ?? nutriments['sugars_serving'];
      final proteins =
          nutriments['proteins_100g'] ?? nutriments['proteins_serving'];

      return ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 0),
        title: Text(
          "Nutrition Facts",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          if (energy != null)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
              title: Text("Energy (kcal / 100g)"),
              trailing: Text("$energy"),
            ),
          if (fat != null)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
              title: Text("Fat (g / 100g)"),
              trailing: Text("$fat"),
            ),
          if (carbs != null)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
              title: Text("Carbohydrates (g / 100g)"),
              trailing: Text("$carbs"),
            ),
          if (sugars != null)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
              title: Text("Sugars (g / 100g)"),
              trailing: Text("$sugars"),
            ),
          if (proteins != null)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
              title: Text("Proteins (g / 100g)"),
              trailing: Text("$proteins"),
            ),
        ],
      );
    }

    // 3) Ingredients Section
    Widget ingredientsSection() {
      final rawList = data['ingredients'] as List<dynamic>?; // structured list
      final ingredientsText = data['ingredients_text'] as String?;
      if ((rawList == null || rawList.isEmpty) &&
          (ingredientsText == null || ingredientsText.isEmpty)) {
        return SizedBox();
      }

      return ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 0),
        title: Text(
          "Ingredients",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          if (rawList != null && rawList.isNotEmpty)
            ...rawList.map((ing) {
              // Each ing is usually a Map with keys like "text", "percent", etc.
              final name = ing['text'] ?? ing['id'] ?? ing.toString();
              final percent =
                  ing['percent'] != null ? " (${ing['percent']}%)" : "";
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                title: Text("$name$percent"),
              );
            }).toList(),
          if (ingredientsText != null && ingredientsText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(ingredientsText, style: TextStyle(fontSize: 14)),
            ),
        ],
      );
    }

    // 4) Food Processing Section (NOVA Group + other tags)
    Widget processingSection() {
      final processingTags =
          data['ingredients_analysis_tags'] as List<dynamic>?;
      if (processingTags == null || processingTags.isEmpty) return SizedBox();

      // Find NOVA group if present
      String? novaGroup;
      for (var tag in processingTags) {
        if (tag.toString().startsWith("en:nova-group-")) {
          novaGroup =
              tag.toString().replaceFirst("en:nova-group-", "").toUpperCase();
          break;
        }
      }

      return ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 0),
        title: Text(
          "Food Processing",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          if (novaGroup != null)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
              title: Text("NOVA Group"),
              trailing: Text("Ultra-processed ($novaGroup)"),
            ),
          ...processingTags.map((tag) {
            final label = tag.toString().split(':').last; // e.g. "vegetarian"
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
              title: Text(label),
            );
          }).toList(),
        ],
      );
    }

    // 5) Additives Section
    Widget additivesSection() {
      final additives = data['additives_tags'] as List<dynamic>?;
      if (additives == null || additives.isEmpty) return SizedBox();

      return ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 0),
        title: Text("Additives", style: TextStyle(fontWeight: FontWeight.bold)),
        children:
            additives.map((a) {
              // each a might look like "en:e-additive-e160b"
              final clean = a.toString().split('-').last.toUpperCase();
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                title: Text(clean),
              );
            }).toList(),
      );
    }

    // 6) Environment & Packaging Section (Carbon footprint, packaging)
    Widget environmentSection() {
      final eco = data['ecoscore_data'] as Map<String, dynamic>?;
      final agribalyse = eco?['agribalyse'] as Map<String, dynamic>?;

      // Packaging: raw text plus tags
      final packagingRaw = data['packaging'] as String?;
      final packagingTags = data['packaging_tags'] as List<dynamic>?;

      // Carbon footprint from agribalyse
      String? co2Per100g;
      if (agribalyse != null) {
        final co2Total =
            agribalyse['co2_total'] ?? agribalyse['co2_agriculture'];
        if (co2Total != null) {
          co2Per100g = "${co2Total.toString()} g CO₂ per 100 g";
        }
      }

      if (eco == null &&
          (packagingRaw == null || packagingRaw.isEmpty) &&
          (packagingTags == null || packagingTags.isEmpty) &&
          co2Per100g == null) {
        return SizedBox();
      }

      return ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 0),
        title: Text(
          "Environment & Packaging",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          if (agribalyse != null && co2Per100g != null)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
              title: Text("Carbon Footprint"),
              subtitle: Text("≈ $co2Per100g"),
            ),
          if (packagingRaw != null && packagingRaw.isNotEmpty)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
              title: Text("Packaging (raw)"),
              subtitle: Text(packagingRaw),
            ),
          if (packagingTags != null && packagingTags.isNotEmpty)
            ...packagingTags.map((t) {
              final label =
                  t.toString().split(':').last; // e.g. "packaging-paper"
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                title: Text(label),
              );
            }).toList(),
        ],
      );
    }

    // 7) Combine all sections into a single scrollable Column
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          headerSection(),
          SizedBox(height: 16),
          nutritionSection(),
          SizedBox(height: 8),
          ingredientsSection(),
          SizedBox(height: 8),
          processingSection(),
          SizedBox(height: 8),
          additivesSection(),
          SizedBox(height: 8),
          environmentSection(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sustainable Shopping Assistant"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1) Barcode scan button
            ElevatedButton.icon(
              icon: Icon(Icons.qr_code_scanner),
              label: Text("Scan Barcode"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: _scanBarcode,
            ),
            SizedBox(height: 20),

            // 2) Expanded area for product info
            Expanded(child: _buildProductInfo()),
          ],
        ),
      ),
    );
  }
}
