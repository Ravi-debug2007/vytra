import 'package:flutter/material.dart';

import '../core/domain.dart';
import '../vision/classify.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({required this.anemiaValues, required this.jaundiceValues, super.key});
  final List<double> anemiaValues;
  final List<double> jaundiceValues;

  @override
  Widget build(BuildContext context) {
    final anemia = aggregateAnemia(anemiaValues);
    final jaundice = aggregateJaundice(jaundiceValues);
    final dualHigh = anemia.risk == Risk.high || jaundice.risk == Risk.high;
    return Scaffold(appBar: AppBar(title: const Text('Screening results')), body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (dualHigh) const Card(color: Color(0xFFFFE6E6), child: Padding(padding: EdgeInsets.all(16), child: Text('Immediate referral recommended. Accompany the patient to the PHC today.', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)))),
      _RiskTile(title: 'Anemia risk', risk: anemia.risk, icon: Icons.water_drop_outlined),
      const SizedBox(height: 14),
      _RiskTile(title: 'Jaundice risk', risk: jaundice.risk, icon: Icons.visibility_outlined),
      const SizedBox(height: 20),
      const Text('This screening result is not a medical diagnosis. It is a triage aid for trained health workers only. All results require confirmation by a qualified medical professional. Do not make treatment decisions based on this result alone.', style: TextStyle(fontSize: 12, height: 1.35)),
      const SizedBox(height: 20),
      FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.picture_as_pdf), label: const Padding(padding: EdgeInsets.all(16), child: Text('Generate PDF', style: TextStyle(fontSize: 18)))),
    ]))));
  }
}

class _RiskTile extends StatelessWidget {
  const _RiskTile({required this.title, required this.risk, required this.icon});
  final String title;
  final Risk risk;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final color = switch (risk) { Risk.high => const Color(0xFFB42318), Risk.moderate => const Color(0xFFB54708), Risk.low => const Color(0xFF027A48), Risk.unableToAssess => const Color(0xFF667085) };
    final action = switch (risk) { Risk.high => 'Refer to the PHC promptly.', Risk.moderate => 'Arrange confirmation by a medical professional.', Risk.low => 'Continue routine care and follow local guidance.', Risk.unableToAssess => 'Retake this part when possible.' };
    return Card(child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [Icon(icon, size: 42, color: color), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 17)), Text(riskLabel(risk), style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: color)), Text(action, style: const TextStyle(fontSize: 15))]))])));
  }
}
