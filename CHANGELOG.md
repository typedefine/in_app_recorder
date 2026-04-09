## 0.0.9
[]: # 
[]: # void main() {
[]: #   runApp(MyApp());
[]: # }
[]: # 
[]: # class MyApp extends StatelessWidget {
[]: #   @override
[]: #   Widget build(BuildContext context) {
[]: #     return MaterialApp(
[]: #       home: Scaffold(
[]: #         appBar: AppBar(title: Text('In-App Recorder Example')),
[]: #         body: Center(
[]: #           child: ElevatedButton(
[]: #             onPressed: () async {
[]: #               await InAppRecorder.startRecording();
[]: #             },
[]: #             child: Text('Start Recording'),
[]: #           ),
[]: #         ),
[]: #       ),
[]: #     );
[]: #   }
[]: # }
[]: # ```
[]: # # 
[]: # ## 📜 License
[]: # 
[]: # This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. 

* Fixed screen recording limit issue.
