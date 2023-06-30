import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(CameraApp(camera: firstCamera));
}

class CameraApp extends StatefulWidget {
  final CameraDescription camera;

  const CameraApp({Key? key, required this.camera}) : super(key: key);

  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late CameraLensDirection _currentCameraLensDirection;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.max,
    );

    _currentCameraLensDirection = widget.camera.lensDirection;
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  ////toggle between front & back cameras
  void _toggleCamera() async {
    final cameras = await availableCameras();
    CameraDescription newCamera;

    if (_currentCameraLensDirection == CameraLensDirection.front) {
      // Switch to the back camera
      newCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );
    } else {
      // Switch to the front camera
      newCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );
    }

    await _controller.dispose();
    setState(() {
      _controller = CameraController(
        newCamera,
        ResolutionPreset.max,
      );
      _currentCameraLensDirection = newCamera.lensDirection;
      _initializeControllerFuture = _controller.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
        body: Stack(
          fit: StackFit.expand, // Fill the entire space
          children: [
            FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
            Positioned(
              top: 24,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black.withOpacity(0.25),
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(Icons.flash_off),
                      color: Colors.white,
                      onPressed: () {
                        // Handle flash off button press
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.camera),
                      color: Colors.white,
                      onPressed: () {
                        // Handle camera button press
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.image),
                      color: Colors.white,
                      onPressed: () {
                        // Handle image button press
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.flip_camera_ios),
                      color: Colors.white,
                      onPressed: () {
                        _toggleCamera(); // Call _toggleCamera function
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: Align(
          alignment: Alignment.bottomCenter,
          child: FloatingActionButton(
            child: const Icon(Icons.camera),
            onPressed: () async {
              try {
                await _initializeControllerFuture;
                final Directory? extDir = await getExternalStorageDirectory();
                final String dirPath = '${extDir?.path}/Camera';
                await Directory(dirPath).create(recursive: true);
                final String filePath = join(dirPath, '${DateTime.now()}.png');
                await _controller.takePicture(filePath);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PreviewScreen(imagePath: filePath),
                  ),
                );
              } catch (e) {
                print(e);
              }
            },
          ),
        ),
      ),
    );
  }
}

class PreviewScreen extends StatelessWidget {
  final String imagePath;

  const PreviewScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview')),
      body: Center(
        child: Image.file(File(imagePath)),
      ),
    );
  }
}
