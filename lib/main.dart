import 'package:flutter/material.dart';

void main() => runApp(const WarathaApp());

class WarathaApp extends StatelessWidget {
  const WarathaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ورثة',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final estateController = TextEditingController();
  bool hasHusband = false;
  bool hasWife = false;
  int sons = 0;
  int daughters = 0;
  String result = '';

  void calculate() {
    double estate = double.tryParse(estateController.text) ?? 0;
    if (estate <= 0) {
      setState(() => result = 'اكتب قيمة التركة');
      return;
    }
    double remaining = estate;
    String res = '';
    
    if (hasHusband) {
      double share = estate * 0.25;
      res += 'الزوج: ربع = $share\n';
      remaining -= share;
    }
    if (hasWife) {
      double share = estate * 0.125;
      res += 'الزوجة: ثمن = $share\n';
      remaining -= share;
    }
    
    int totalParts = sons * 2 + daughters;
    if (totalParts > 0) {
      double partValue = remaining / totalParts;
      if (sons > 0) res += 'لكل ابن: ${partValue * 2}\n';
      if (daughters > 0) res += 'لكل بنت: $partValue\n';
      res += '\nالباقي تم توزيعه تعصيبا';
    } else {
      res += 'الباقي: $remaining يوزع على باقي الورثة';
    }
    
    setState(() => result = res);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ورثة - حاسبة المواريث'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: estateController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'قيمة التركة', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          CheckboxListTile(title: const Text('زوج موجود'), value: hasHusband, onChanged: (v) => setState(() => hasHusband = v!)),
          CheckboxListTile(title: const Text('زوجة موجودة'), value: hasWife, onChanged: (v) => setState(() => hasWife = v!)),
          ListTile(title: const Text('عدد الأبناء الذكور'), trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(onPressed: () => setState(() => sons = sons > 0 ? sons - 1 : 0), icon: const Icon(Icons.remove)),
            Text('$sons'),
            IconButton(onPressed: () => setState(() => sons++), icon: const Icon(Icons.add)),
          ])),
          ListTile(title: const Text('عدد البنات'), trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(onPressed: () => setState(() => daughters = daughters > 0 ? daughters - 1 : 0), icon: const Icon(Icons.remove)),
            Text('$daughters'),
            IconButton(onPressed: () => setState(() => daughters++), icon: const Icon(Icons.add)),
          ])),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: calculate, child: const Text('احسب الميراث')),
          const SizedBox(height: 20),
          if (result.isNotEmpty)
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(12)), child: Text(result, style: const TextStyle(fontSize: 18))),
        ],
      ),
    );
  }
}
