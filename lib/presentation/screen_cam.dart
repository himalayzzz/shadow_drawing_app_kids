import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:wakelock_plus/wakelock_plus.dart';

class ScreenCam extends StatefulWidget {
  const ScreenCam({super.key});

  @override
  State<ScreenCam> createState() => _ScreenCamState();
}

class _ScreenCamState extends State<ScreenCam> {
  List<CameraDescription> cameras = [];
  CameraController? cameraController;
  double _opacity = 0.5;
  double _scale = 1.0;

  late String imagePath;
  late bool isAsset;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _setupCameraController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    imagePath = args['path'];
    isAsset = args['isAsset'];

    if (!isAsset) {
      setState(() => isProcessing = true);
      removeBackground(imagePath).then((File? result) {
        if (result != null) {
          setState(() {
            imagePath = result.path;
          });
        }
        setState(() => isProcessing = false);
      });
    }
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    cameraController?.dispose();
    super.dispose();
  }

  Future<void> _setupCameraController() async {
    final List<CameraDescription> _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      cameraController = CameraController(
        _cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await cameraController!.initialize();
      if (mounted) setState(() {});
    }
  }

  Future<File?> removeBackground(String imagePath) async {
    const apiKey = 'BMTgGTDd4sC8CJNajeJSZvxk'; // Replace with your actual API key

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.remove.bg/v1.0/removebg'),
    );

    request.headers['X-Api-Key'] = apiKey;
    request.files.add(
      await http.MultipartFile.fromPath('image_file', imagePath),
    );
    request.fields['size'] = 'auto';

    final response = await request.send();

    if (response.statusCode == 200) {
      final bytes = await response.stream.toBytes();
      final dir = await getTemporaryDirectory();
      final file = File(
        p.join(dir.path, 'no_bg_${DateTime.now().millisecondsSinceEpoch}.png'),
      );
      await file.writeAsBytes(bytes);
      return file;
    } else {
      debugPrint('Remove.bg failed: ${response.statusCode}');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Overlay Camera",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: cameraController == null || !cameraController!.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height,
                  width: MediaQuery.sizeOf(context).width,
                  child: CameraPreview(cameraController!),
                ),

                if (!isProcessing)
                  Center(
                    child: Opacity(
                      opacity: _opacity,
                      child: Transform.scale(
                        scale: _scale,
                        child: isAsset
                            ? Image.asset(
                                imagePath,
                                fit: BoxFit.contain,
                              )
                            : Image.file(
                                File(imagePath),
                                fit: BoxFit.contain,
                              ),
                      ),
                    ),
                  ),

                if (isProcessing)
                  const Center(child: CircularProgressIndicator()),

                if (!isProcessing)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      children: [
                        Slider(
                          value: _opacity,
                          min: 0.0,
                          max: 1.0,
                          onChanged: (val) {
                            setState(() => _opacity = val);
                          },
                        ),
                        const Text("Adjust Image Opacity", style: TextStyle(color: Colors.white)),

                        Slider(
                          value: _scale,
                          min: 0.2,
                          max: 3.0,
                          divisions: 28,
                          label: "${_scale.toStringAsFixed(1)}x",
                          onChanged: (val) {
                            setState(() => _scale = val);
                          },
                        ),
                        const Text("Resize Image", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
              ],
            ),
      backgroundColor: Colors.black,
    );
  }
}
