import 'package:flutter/material.dart';
import 'waste_classification_screen.dart';
import 'sustainable_shopping_screen.dart';
import 'carbon_footprint_screen.dart';
import '../database/app_database.dart';
import 'user_list_screen.dart';

class HomePage extends StatelessWidget {
  final AppDatabase database;
  HomePage({required this.database});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EcoTrack'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Implement search functionality if needed.
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('User List'),
              onTap: () {
                Navigator.pushNamed(context, "/userList");
              },
            ),
            ListTile(
              leading: Icon(Icons.eco),
              title: Text('Carbon Footprint'),
              onTap: () {
                Navigator.pushNamed(context, "/carbonFootprint");
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                // Add settings navigation if needed.
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {},
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Category Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildCategoryCard(
                    context,
                    'Waste Management',
                    'assets/images/waste_management.png',
                  ),
                  _buildCategoryCard(
                    context,
                    'Carbon Footprint',
                    'assets/images/carbon_footprint.png',
                  ),
                  _buildCategoryCard(
                    context,
                    'Sustainable Shopping',
                    'assets/images/shopping.png',
                  ),
                  _buildCategoryCard(
                    context,
                    'Community Events',
                    'assets/images/community_events.png',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Additional action if needed.
        },
        backgroundColor: Colors.green,
        child: Icon(Icons.camera_alt),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    String imagePath,
  ) {
    return GestureDetector(
      onTap: () {
        if (title == 'Waste Management') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WasteClassificationScreen(),
            ),
          );
        } else if (title == 'Sustainable Shopping') {
          Navigator.pushNamed(context, "/sustainableShopping");
        } else if (title == 'Carbon Footprint') {
          Navigator.pushNamed(context, "/carbonFootprint");
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('$title is coming soon!')));
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, height: 80, width: 80),
            SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
