import 'package:flutter/material.dart';
import 'src/vision/cielab.dart';

void main() {
  runApp(const VytraApp());
}

class VytraApp extends StatefulWidget {
  const VytraApp({super.key});

  @override
  State<VytraApp> createState() => _VytraAppState();
}

class _VytraAppState extends State<VytraApp> {
  Locale _locale = const Locale('en');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VYTRA',
      locale: _locale,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F9F5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0E2A1C),
          primary: const Color(0xFF0E2A1C),
          secondary: const Color(0xFF6CA532),
        ),
        fontFamily: 'NotoSans',
      ),
      home: LanguageScreen(
        onSelected: (locale) => setState(() => _locale = locale),
      ),
    );
  }
}

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({required this.onSelected, super.key});
  final ValueChanged<Locale> onSelected;

  @override
  Widget build(BuildContext context) {
    return _Shell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          const _BrandHeader(),
          const SizedBox(height: 48),
          const Text('Choose language', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('భాషను ఎంచుకోండి', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 28),
          _ChoiceButton(label: 'English', onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(onLocaleChanged: onSelected)))),
          const SizedBox(height: 16),
          _ChoiceButton(label: 'తెలుగు', onPressed: () { onSelected(const Locale('te')); Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(onLocaleChanged: onSelected))); }),
          const Spacer(),
          const _FooterDisclaimer(),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.onLocaleChanged, super.key});
  final ValueChanged<Locale> onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    return _Shell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _BrandHeader(),
          const SizedBox(height: 40),
          const Text('See Health. Detect Early.', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          const Text('A screening aid for trained health workers.', style: TextStyle(fontSize: 18)),
          const Spacer(),
          FilledButton.icon(
            icon: const Icon(Icons.add_circle_outline, size: 30),
            label: const Padding(padding: EdgeInsets.symmetric(vertical: 17), child: Text('New screening', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConsentScreen())),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            icon: const Icon(Icons.language),
            label: const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('Language / భాష', style: TextStyle(fontSize: 17))),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LanguageScreen(onSelected: onLocaleChanged))),
          ),
          const Spacer(),
          const _FooterDisclaimer(),
        ],
      ),
    );
  }
}

class ConsentScreen extends StatelessWidget {
  const ConsentScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return _Shell(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const _StepLabel(step: '1 of 7', title: 'Consent'),
        const SizedBox(height: 24),
        const Text('Please explain this screening to the person and ask for consent.', style: TextStyle(fontSize: 21, height: 1.35)),
        const SizedBox(height: 20),
        const Expanded(child: SingleChildScrollView(child: Text('VYTRA is a screening aid for trained health workers. It looks at the colour of the inner lower eyelid and the white of the eye. It does not diagnose illness. Results require confirmation by a qualified medical professional.', style: TextStyle(fontSize: 18, height: 1.5)))),
        FilledButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MetadataScreen())), child: const Padding(padding: EdgeInsets.all(16), child: Text('Agree and continue', style: TextStyle(fontSize: 18)))),
        const SizedBox(height: 10),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Decline', style: TextStyle(fontSize: 17))),
        const SizedBox(height: 10),
        const _FooterDisclaimer(),
      ]),
    );
  }
}

class MetadataScreen extends StatefulWidget { const MetadataScreen({super.key}); @override State<MetadataScreen> createState() => _MetadataScreenState(); }
class _MetadataScreenState extends State<MetadataScreen> {
  int? fitzpatrick; String? method; String? lighting;
  @override Widget build(BuildContext context) => _Shell(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    const _StepLabel(step: '2 of 7', title: 'Session details'), const SizedBox(height: 18),
    const Text('Select the details for this screening.', style: TextStyle(fontSize: 20)), const SizedBox(height: 18),
    const Text('Skin tone scale', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
    Wrap(spacing: 8, children: List.generate(6, (i) => ChoiceChip(label: Text('${i + 1}'), selected: fitzpatrick == i + 1, onSelected: (_) => setState(() => fitzpatrick = i + 1)))),
    const SizedBox(height: 18), const Text('Assessment method', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
    DropdownButton<String>(isExpanded: true, value: method, hint: const Text('Choose one'), items: const [DropdownMenuItem(value: 'SELF_REPORTED', child: Text('Self-reported')), DropdownMenuItem(value: 'WORKER_ASSESSED', child: Text('Worker-assessed'))], onChanged: (v) => setState(() => method = v)),
    const SizedBox(height: 12), const Text('Lighting', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
    DropdownButton<String>(isExpanded: true, value: lighting, hint: const Text('Choose one'), items: const [DropdownMenuItem(value: 'INDOOR_NATURAL', child: Text('Indoor — natural light')), DropdownMenuItem(value: 'INDOOR_ARTIFICIAL', child: Text('Indoor — artificial light')), DropdownMenuItem(value: 'OUTDOOR_SHADE', child: Text('Outdoor — shade')), DropdownMenuItem(value: 'OUTDOOR_DIRECT', child: Text('Outdoor — direct light'))], onChanged: (v) => setState(() => lighting = v)),
    const Spacer(), FilledButton(onPressed: fitzpatrick != null && method != null && lighting != null ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WhiteReferenceScreen())) : null, child: const Padding(padding: EdgeInsets.all(16), child: Text('Continue', style: TextStyle(fontSize: 18)))), const SizedBox(height: 16), const _FooterDisclaimer(),
  ]));
}

class WhiteReferenceScreen extends StatelessWidget { const WhiteReferenceScreen({super.key}); @override Widget build(BuildContext context) => _Shell(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [const _StepLabel(step: '3 of 7', title: 'White reference'), const SizedBox(height: 24), const Icon(Icons.crop_square, size: 120, color: Color(0xFF6CA532)), const SizedBox(height: 20), const Text('Place the rear camera 15–20 cm above a matte white A4 sheet and fill the frame.', style: TextStyle(fontSize: 20, height: 1.4)), const Spacer(), FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.camera_alt), label: const Padding(padding: EdgeInsets.all(16), child: Text('Capture white reference', style: TextStyle(fontSize: 18)))), const SizedBox(height: 16), const _FooterDisclaimer()])); }

class _Shell extends StatelessWidget { const _Shell({required this.child}); final Widget child; @override Widget build(BuildContext context) => Scaffold(body: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(24, 20, 24, 18), child: child))); }
class _BrandHeader extends StatelessWidget { const _BrandHeader(); @override Widget build(BuildContext context) => const Row(children: [Icon(Icons.visibility_outlined, size: 42, color: Color(0xFF6CA532)), SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('VYTRA', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 1.4)), Text('See Health. Detect Early.', style: TextStyle(fontSize: 13))])]); }
class _ChoiceButton extends StatelessWidget { const _ChoiceButton({required this.label, required this.onPressed}); final String label; final VoidCallback onPressed; @override Widget build(BuildContext context) => OutlinedButton(onPressed: onPressed, child: Padding(padding: const EdgeInsets.all(17), child: Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)))); }
class _StepLabel extends StatelessWidget { const _StepLabel({required this.step, required this.title}); final String step, title; @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(step.toUpperCase(), style: const TextStyle(color: Color(0xFF6CA532), fontWeight: FontWeight.w800, letterSpacing: 1.2)), const SizedBox(height: 5), Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800))]); }
class _FooterDisclaimer extends StatelessWidget { const _FooterDisclaimer(); @override Widget build(BuildContext context) => const Text('This screening result is not a medical diagnosis. It is a triage aid for trained health workers only. All results require confirmation by a qualified medical professional. Do not make treatment decisions based on this result alone.', style: TextStyle(fontSize: 12, height: 1.3)); }

// Keeps the canonical vision module referenced in the first scaffold slice.
// The production capture flow must call this from a compute isolate.
final _cielabReference = CielabConverter();
