import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:the_blackout/constants.dart';
import 'package:the_blackout/object_detection.dart';

FlutterTts flutterTts = FlutterTts();

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
    Future(()async{
      await flutterTts.setLanguage("en-US");
      await flutterTts.setPitch(1.0);
      await speak();
    });
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  Future<void> speak({String text = "Hello, Welcome to our virtual reality application"}) async{
    await flutterTts.speak(text);
    //await flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("The Blackout"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextButton(
              child: Container(
                  padding: kButtonTextPadding,
                  child: const Text("Navigate", style: kButtonTextStyle),
                  decoration: kButtonDecoration.copyWith(color: kblue),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ObjectDetectionScreen()));
              },
            ),
            SizedBox(
              height: 20
            ),
            TextButton(
              child: Container(
                padding: kButtonTextPadding,
                  child: const Text("Save locations", style: kButtonTextStyle),
                  decoration: kButtonDecoration.copyWith(color: kblue) ,
                  ),
              onPressed: () {
                speak();
                //todo: Goto Location map screen
              },
            )
          ]
        ),
      )
    );
  }
}
