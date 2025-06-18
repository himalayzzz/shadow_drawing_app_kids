import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

class ScreenPicker extends StatelessWidget {
  const ScreenPicker({super.key});

  final List<String> assetImages = const [
    'assets/d1.avif',
    'assets/d2.webp',
    'assets/d3.webp',
    
  ];

  void _goToCamScreen(BuildContext context, String path, bool isAsset) {
    Navigator.pushNamed(
      context,
      '/cam',
      arguments: {'path': path, 'isAsset': isAsset},
    );
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      _goToCamScreen(context, file.path, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            SystemNavigator.pop();
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: const Text(
          'Choose Image',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: assetImages.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () =>
                      _goToCamScreen(context, assetImages[index], true),
                  child: Image.asset(assetImages[index], fit: BoxFit.cover),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(35.0),
            child: ElevatedButton.icon(
              onPressed: () => _pickFromGallery(context),
              icon: const Icon(Icons.photo_library),
              label: const Text("Pick From Gallery"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}