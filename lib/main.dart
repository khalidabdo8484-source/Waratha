import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';

void main() => runApp(const WarathaApp());

class WarathaApp extends StatelessWidget {
  const WarathaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'وَرَثَة',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF0E6F5C)),
      home: const CalcPage(),
    );
  }
}

class CalcPage extends StatefulWidget {
  const CalcPage({super.key});
  @override State<CalcPage> createState() => _CalcPageState();
}

class _CalcPageState extends State<CalcPage> {
  final estateC = TextEditingController();
  final debtC = TextEditingController(text: '0');
  final wasiyaC = TextEditingController(text: '0');
  int wives = 0; bool husband = false; bool father = false; bool mother = false;
  int sons = 0; int daughters = 0;
  String result = '';
  Map<String, double> shares = {};
  double netEstate = 0; double debt = 0; double wasiya = 0;

  void calc() {
    double e = double.tryParse(estateC.text) ?? 0;
    debt = double.tryParse(debtC.text) ?? 0;
    wasiya = double.tryParse(wasiyaC.text) ?? 0;
    if (e <= 0) { setState(() => result = 'اكتب قيمة التركة'); return; }
    if (wasiya > e / 3) { setState(() => result = 'الوصية لا تزيد عن الثلث (${(e/3).toStringAsFixed(2)})'); return; }
    double afterDebt = e - debt;
    if (afterDebt < 0) afterDebt = 0;
    double afterWasiya = afterDebt - wasiya;
    if (afterWasiya < 0) afterWasiya = 0;
    netEstate = afterWasiya;
    double rem = netEstate;
    Map<String, double> sh = {};
    if (mother) { double s = (sons > 0 || daughters > 0) ? netEstate / 6 : netEstate / 3; sh['الأم'] = s; rem -= s; }
    if (father && (sons > 0 || daughters > 0)) { double s = netEstate / 6; sh['الأب (فرض)'] = s; rem -= s; }
    if (wives > 0) { double s = (sons > 0 || daughters > 0) ? netEstate / 8 : netEstate / 4; sh['الزوجات ($wives)'] = s; rem -= s; }
    if (husband) { double s = (sons > 0 || daughters > 0) ? netEstate / 4 : netEstate / 2; sh['الزوج'] = s; rem -= s; }
    if (daughters > 0 && sons == 0) { double s = daughters == 1 ? netEstate * 0.5 : netEstate * (2 / 3); sh['البنات ($daughters)'] = s; rem -= s; }
    int parts = sons * 2 + daughters;
    if (parts > 0 && sons > 0) {
      double pv = rem / parts;
      if (sons > 0) sh['الأبناء ($sons)'] = pv * 2 * sons;
      if (daughters > 0) sh['البنات ($daughters)'] = pv * daughters;
      rem = 0;
    }
    if (rem > 0 && father) { sh['الأب (تعصيب)'] = (sh['الأب (تعصيب)'] ?? 0) + rem; rem = 0; }
    if (rem > 0) sh['الباقي'] = rem;
    StringBuffer b = StringBuffer();
    b.writeln('التركة: $e - الديون: $debt - الوصية: $wasiya');
    b.writeln('الصافي: ${netEstate.toStringAsFixed(2)}\n');
    sh.forEach((k, v) => b.writeln('$k = ${v.toStringAsFixed(2)}'));
    setState(() { result = b.toString(); shares = sh; });
  }

  Future<void> makePdf() async {
    if (shares.isEmpty) return;
    final doc = pw.Document();
    doc.addPage(pw.Page(build: (c) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Center(child: pw.Text('وَرَثَة - تقرير الميراث', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold))),
      pw.SizedBox(height: 8),
      pw.Text('الاجمالي: ${estateC.text}  الديون: $debt  الوصية: $wasiya  الصافي: $netEstate'),
      pw.Divider(),
      ...shares.entries.map((e) => pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text(e.value.toStringAsFixed(2)), pw.Text(e.key)])),
    ])));
    await Printing.sharePdf(bytes: await doc.save(), filename: 'waratha.pdf');
  }

  List<PieChartSectionData> pieData() {
    if (shares.isEmpty) return [];
    final cols = [const Color(0xFF0E6F5C), const Color(0xFFD4AF37), Colors.orange, Colors.blue, Colors.purple, Colors.teal, Colors.brown];
    int i = 0;
    return shares.entries.map((e) {
      final col = cols[i % cols.length]; i++;
      return PieChartSectionData(value: e.value, title: '${e.key}\n${e.value.toStringAsFixed(0)}', color: col, radius: 65, titleStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold));
    }).toList();
  }

  Widget counter(String t, int v, Function(int) on) => Card(child: ListTile(title: Text(t), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(onPressed: () => setState(() => on(v > 0 ? v - 1 : 0)), icon: const Icon(Icons.remove)), Text('$
