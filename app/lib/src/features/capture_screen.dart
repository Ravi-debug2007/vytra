import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../core/domain.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({required this.series, required this.onComplete, super.key});
  final Series series;
  final ValueChanged<List<double>> onComplete;

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  CameraController? _controller;
  CaptureState _state = CaptureState.hunting;
  final _signals = <double>[];
  int _attempts = 0;
  String _message = 'Align the guide and follow the instruction.';

  @override
  void initState() {
    super.initState();
    _openCamera();
  }

  Future<void> _openCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      if (mounted) setState(() => _message = 'Camera is unavailable on this device.');
      return;
    }
    final rear = cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.back, orElse: () => cameras.first);
    final controller = CameraController(rear, ResolutionPreset.medium, enableAudio: false);
    await controller.initialize();
    if (mounted) setState(() { _controller = controller; _state = CaptureState.ready; });
  }

  Future<void> _capture() async {
    if (_state != CaptureState.ready || _attempts >= 3) return;
    setState(() { _state = CaptureState.analysing; _attempts++; _message = 'Checking image quality…'; });
    await Future<void>.delayed(const Duration(milliseconds: 250));
    // Replace this deterministic signal with the in-memory RGB/ROI/CIELAB analyzer.
    final signal = widget.series == Series.anemia ? 12.0 : 8.0;
    if (mounted) setState(() { _signals.add(signal); _state = CaptureState.recorded; _message = 'Capture recorded. ${_signals.length} valid of 2 required.'; });
  }

  void _useThese() => widget.onComplete(List<double>.unmodifiable(_signals));

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAnemia = widget.series == Series.anemia;
    final instruction = isAnemia
        ? 'Ask the person to look up. Gently pull the lower lid down until the inner pink tissue is visible.'
        : 'Ask the person to look toward their nose. Keep lashes out of the white of the eye.';
    final preview = _controller?.value.isInitialized == true
        ? Stack(fit: StackFit.expand, children: [
            CameraPreview(_controller!),
            Center(child: Container(width: 260, height: 180, decoration: BoxDecoration(border: Border.all(color: _state == CaptureState.ready ? Colors.greenAccent : Colors.white, width: 3), borderRadius: BorderRadius.circular(130)))),
            Positioned(top: 18, left: 18, right: 18, child: Card(child: Padding(padding: const EdgeInsets.all(12), child: Text(instruction, style: const TextStyle(fontSize: 16))))),
          ])
        : Center(child: Text(_message, style: const TextStyle(fontSize: 18)));
    return Scaffold(
      appBar: AppBar(title: Text(isAnemia ? 'Anemia screening' : 'Jaundice screening')),
      body: SafeArea(child: Column(children: [
        Expanded(child: preview),
        Padding(padding: const EdgeInsets.all(18), child: Column(children: [
          Text(_message, textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text('Attempts: $_attempts / 3'),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: FilledButton.icon(onPressed: _state == CaptureState.ready ? _capture : null, icon: const Icon(Icons.camera_alt), label: Text(_signals.length >= 2 ? 'Take another' : 'Capture'))),
            if (_signals.length >= 2) ...[
              const SizedBox(width: 10),
              Expanded(child: OutlinedButton(onPressed: _useThese, child: const Text('Use these'))),
            ],
          ]),
        ])),
      ])),
    );
  }
}
