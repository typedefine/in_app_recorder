import 'package:flutter/material.dart';
import 'package:in_app_recorder/flutter_screen_capture.dart' show FlutterScreenCapture;
import 'package:in_app_recorder/screen_recording_controller.dart' show ScreenRecorderController, ProcessingStatusCallback;
import 'package:path_provider/path_provider.dart' show getTemporaryDirectory;
import 'package:uuid/uuid.dart' show Uuid;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: RecorderExample());
  }
}

class RecorderExample extends StatefulWidget {


  RecorderExample({super.key});

  @override
  State<RecorderExample> createState() => _RecorderExampleState();
}

class _RecorderExampleState extends State<RecorderExample> {
  bool isPathLoaded = false;
  String videoExportPath = '';
  late ScreenRecorderController recorderController;
  int frameCount = 0;


  loadVideoExportPathAndInitController()async{
    final tempDirectory = await getTemporaryDirectory();
    videoExportPath = '${tempDirectory.path}/${Uuid().v4()}.mp4';
    recorderController = ScreenRecorderController(videoExportPath: videoExportPath, fps:  8, shareMessage: "Hey this is the recorded video",
        shareVideo: true, updateFrameCount: (count){
      setState(() {
          frameCount = count;
        });});
    setState(() {
      isPathLoaded = true;
    });
  }
  @override
  void initState() {
    loadVideoExportPathAndInitController();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Screen Recorder Demo')),
      body: isPathLoaded ?
      FlutterScreenCapture(
        controller: recorderController,
        child: Container(
          decoration: recorderController.isRecording ? BoxDecoration(border: Border.all(color: Colors.red, width: 4), color: Colors.green,) : null,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    "Recording Test! ${frameCount} frames recorded",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      recorderController.startRecording(setState: () =>  setState(() {}));
                    },
                    child: const Text("Start"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await recorderController.stopRecording(setState: () => setState(() {}));
                    },
                    child: const Text("Stop & Share"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ) : Center(child: CircularProgressIndicator()),
    );
  }
}
