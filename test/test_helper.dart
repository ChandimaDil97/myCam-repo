import 'package:my_cam/main.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

Future<Widget> createCameraAppWithFirstCamera() async {
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  return FutureBuilder<CameraDescription>(
    future: Future.value(firstCamera),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return CameraApp(camera: snapshot.data!);
      } else if (snapshot.hasError) {
        return Text('Error loading camera');
      } else {
        return CircularProgressIndicator();
      }
    },
  );
}

// this file was added
