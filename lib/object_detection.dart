import 'dart:typed_data';
import 'package:camera/camera.dart';
import "package:flutter/material.dart";
import 'package:tflite/tflite.dart';
import "package:the_blackout/constants.dart";
import "package:the_blackout/main.dart";
import "package:flutter_tts/flutter_tts.dart";
import 'package:speech_to_text/speech_to_text.dart';

FlutterTts flutterTts = FlutterTts();

class ObjectDetectionScreen extends StatefulWidget {
  @override
  _ObjectDetectionScreenState createState() => _ObjectDetectionScreenState();
}

class _ObjectDetectionScreenState extends State<ObjectDetectionScreen> {

  bool isWorking = false;
  String? detectedObject;
  var imageFrame;
  CameraController cameraController = CameraController(cameras[0], ResolutionPreset.medium);

  Future<void> loadModel() async{
    String? res;
    try{
      res = await Tflite.loadModel(
          model: modelName,
          labels: classLabels,
          numThreads: 1, // defaults to 1
          isAsset: true, // defaults to true, set to false to load resources outside assets
          useGpuDelegate: false // defaults to false, set to true to use GPU delegate
      );
      debugPrint("******Model successfully loaded*******");
    }catch(e) {
      debugPrint("$e");
    }

  }

  Future<void> initializeCamera() async{
    try {
      cameraController.initialize().then((value){
        if(!mounted) return;
        setState((){});
        cameraController.startImageStream(
                (imageFromStream) async{
              if(!isWorking) {
                isWorking = true;
                imageFrame = imageFromStream;
                try {
                  runModelOnStreamFrames();
                }catch(e) {
                  debugPrint("$e");
                }

              }
              isWorking = false;
            });
      });
      debugPrint("CameraController successfully initialized");
    }catch(e) {
      debugPrint("$e");
    }
  }

  Future<void> runModelOnStreamFrames() async {
    if(imageFrame != null) {
      late List<Uint8List> bytesList = [];
      for(var plane in imageFrame.planes) {
        bytesList.add(plane.bytes);
      }
      List? recognitions = await Tflite.runModelOnFrame(
          bytesList: bytesList,//imageFrame.planes.map((plane) {return plane.bytes as Uint8List;}).toList(),// required
          imageHeight: imageFrame.height,
          imageWidth: imageFrame.width,
          imageMean: 127.5,   // defaults to 127.5
          imageStd: 127.5,    // defaults to 127.5
          rotation: 90,       // defaults to 90, Android only
          numResults: 3,      // defaults to 5
          threshold: 0.2,     // defaults to 0.1
          asynch: true        // defaults to true
      );

      if(recognitions == null || recognitions!.isEmpty) return;
      debugPrint("keys: ${recognitions[0].keys.join(",")}");
      setState((){
        detectedObject = recognitions[0]["label"];
      });

      await speak(detectedObject ?? "");
      // for(var result in recognitions!) {
      //   setState(() {
      //     detection = result["label"];
      //   });
      //   debugPrint("Detected class: ${result["detectedClass"]}, Confidence in class: ${result["confidenceInClass"]}");
      // }

    }
  }

  String getArticle(String text){
    //Get the first character of the text
    String firstChar = text.split("").first;
    List vowels = ["a", "e", "i", "o", "u"];
    if(vowels.contains(firstChar.toLowerCase())) {
      return "an";
    }
    return "a";
  }

  Future<void> speak(String object) async{
    String text = "There is ${getArticle(object)} ${object} ahead of you";
    await flutterTts.speak(text);
    // await flutterTts.stop();
  }

  // Future<void> initializeCamera() async{
  //   try {
  //     cameraController.initialize().then((value){
  //       if(!mounted) return;
  //       setState((){});
  //       cameraController.startImageStream(
  //               (imageFromStream) async{
  //             if(!isWorking) {
  //               isWorking = true;
  //               imageFrame = imageFromStream;
  //               await runModelOnStreamFrames();
  //             }
  //             isWorking = false;
  //           });
  //     });
  //     debugPrint("CameraController successfully initialized");
  //   }catch(e) {
  //     debugPrint("$e");
  //   }
  // }
  //
  // Future<void> runModelOnStreamFrames() async {
  //     if(imageFrame != null) {
  //       late List<Uint8List> bytesList = [];
  //       for(var plane in imageFrame.planes) {
  //         bytesList.add(plane.bytes);
  //       }
  //       List? recognitions = await Tflite.runModelOnFrame(
  //           bytesList: bytesList,//imageFrame.planes.map((plane) {return plane.bytes as Uint8List;}).toList(),// required
  //           imageHeight: imageFrame.height,
  //           imageWidth: imageFrame.width,
  //           imageMean: 127.5,   // defaults to 127.5
  //           imageStd: 127.5,    // defaults to 127.5
  //           rotation: 90,       // defaults to 90, Android only
  //           numResults: 3,      // defaults to 5
  //           threshold: 0.5,     // defaults to 0.1
  //           asynch: true        // defaults to true
  //       );
  //
  //       if(recognitions == null || recognitions.isEmpty) return;
  //       debugPrint("keys: ${recognitions[0].keys.join(",")}");
  //
  //       ///Get the name of the detected object
  //       SetState((){
  //
  //       });
  //
  //       detectedObject = recognitions[0]["label"];
  //
  //       ///Make a sentence using the detected object
  //       speak(detectedObject ?? "");
  //
  //       // for(var result in recognitions!) {
  //       //   setState(() {
  //       //     detectedObject = result["label"];
  //       //   });
  //       //   debugPrint("Detected class: ${result["detectedClass"]}, Confidence in class: ${result["confidenceInClass"]}");
  //       // }
  //     }
  // }

  @override
  void initState(){
    super.initState();
    loadModel()
        .then((value){
          debugPrint("Model loaded");
          initializeCamera();
    });
  }

  @override
  void dispose() {
    super.dispose();
    cameraController.stopImageStream();
    Tflite.close();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${detectedObject ?? "Detecting..." } "),
      ),
        body: CameraPreview(cameraController),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.camera, color: Colors.white),
        onPressed: () async{
            await runModelOnStreamFrames();
        },
      ),
    );
  }
}
