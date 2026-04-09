import 'dart:async';
import 'dart:ui' as ui;
import 'dart:developer' as developer;
import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:share_plus/share_plus.dart';

typedef SetStateCallback = void Function();
typedef ProcessingStatusCallback = void Function(bool isProcessing);

class ScreenRecorderController {
  int _frameCount = 0;
  bool _isRecording = false;
  Timer? _recordingTimer;

  String? _pipe;        // Path returned by ffmpeg-kit
  IOSink? _pipeSink;    // Writable sink for frames

  ReturnCode? returnCode;

  final GlobalKey repaintBoundaryKey = GlobalKey();
  final void Function(int)? updateFrameCount;

  bool get isRecording => _isRecording;
  final String videoExportPath;
  final int fps;
  final bool shareVideo;
  final String shareMessage;
  final bool showLogs;

  int _width = 0;
  int _height = 0;

  ScreenRecorderController({
    required this.videoExportPath,
    this.fps = 10,
    this.shareVideo = false,
    this.shareMessage = '',
    this.updateFrameCount,
    this.showLogs = false,
  });

  share()async{
    await Share.shareXFiles(
      [XFile(videoExportPath)],
      text: shareMessage,
    );
  }
  /// Start recording: sets up ffmpeg pipe and begins pushing frames.
  Future<void> startRecording({SetStateCallback? setState}) async {
    if (_isRecording) return;

    _isRecording = true;
    _frameCount = 0;
    if (setState != null) setState();

    // Wait until first frame is fully painted
    await WidgetsBinding.instance.endOfFrame;

    final boundary = repaintBoundaryKey.currentContext?.findRenderObject();
    if (boundary is! RenderRepaintBoundary) {
      developer.log('❌ No RenderRepaintBoundary found');
      return;
    }

    final image = await boundary.toImage(pixelRatio: 2.0);
    _width = image.width;
    _height = image.height;

    // Create ffmpeg pipe
    _pipe = await FFmpegKitConfig.registerNewFFmpegPipe();
    _pipeSink = File(_pipe!).openWrite();

    // ffmpeg command
    final command = [
      '-y',
      '-f', 'rawvideo',
      '-pix_fmt', 'rgba',
      '-s', '${_width}x$_height',
      '-r', fps.toString(),
      '-i', _pipe!,
      '-c:v', 'libx264',
      '-pix_fmt', 'yuv420p',
      videoExportPath,
    ].join(' ');

    // Run ffmpeg in background
    FFmpegKit.executeAsync(command, (session) async {
      returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        developer.log("✅ Video created at $videoExportPath");
      } else {
        developer.log("❌ FFmpeg failed with code: $returnCode");
      }
    });

    // Capture frames periodically
    final interval = Duration(milliseconds: 1000 ~/ fps);
    _recordingTimer = Timer.periodic(interval, (_) => _captureFrame());

    developer.log("🎥 Recording started with size: $_width x $_height");
  }

  /// Stop recording: closes ffmpeg pipe and finalizes the video.
  Future<void> stopRecording({
    SetStateCallback? setState,
    ProcessingStatusCallback? isProcessing,
  }) async {
    if (!_isRecording) return;

    _isRecording = false;
    if (setState != null) setState();
    isProcessing?.call(true);

    _recordingTimer?.cancel();

    await _pipeSink?.flush();
    await _pipeSink?.close();

    _pipe = null;
    _pipeSink = null;

    _frameCount = 0;
    isProcessing?.call(false);

    developer.log("🎬 Recording stopped");
  }

  /// Cancel without saving
  Future<void> cancelRecording({SetStateCallback? setState}) async {
    if (!_isRecording) return;

    _isRecording = false;
    _recordingTimer?.cancel();

    await _pipeSink?.close();
    _pipe = null;
    _pipeSink = null;

    _frameCount = 0;
    if (setState != null) setState();

    developer.log("🛑 Recording canceled");
  }

  /// Internal: capture a single frame and push to ffmpeg pipe
  Future<void> _captureFrame() async {
    if (!_isRecording || _pipeSink == null) return;

    try {
      final boundary = repaintBoundaryKey.currentContext?.findRenderObject();
      if (boundary is! RenderRepaintBoundary) return;

      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (byteData == null) return;
      if(_pipeSink != null){
        _pipeSink!.add(byteData.buffer.asUint8List());
        _frameCount++;
      }
      if (updateFrameCount != null) updateFrameCount!(_frameCount);
      if (showLogs) developer.log("✅ Frame $_frameCount pushed");
    } catch (e) {
      developer.log("⚠️ Error capturing frame: $e");
    }
  }
}
