import 'package:flutter/material.dart' show Widget, BuildContext, RepaintBoundary;
import 'package:flutter/src/widgets/framework.dart';
import 'screen_recording_controller.dart' show ScreenRecorderController;

class FlutterScreenCapture extends StatefulWidget {
  final Widget child;
  final ScreenRecorderController controller;

  const FlutterScreenCapture({
    super.key,
    required this.child,
    required this.controller,
  });

  @override
  State<FlutterScreenCapture> createState() => _FlutterScreenCaptureState();
}

class _FlutterScreenCaptureState extends State<FlutterScreenCapture> {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: widget.controller.repaintBoundaryKey,
      child: widget.child,
    );
  }
}