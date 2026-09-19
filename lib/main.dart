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
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});
  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final estateCtrl = TextEditingController();
  int wives = 0;
  bool husband = false;
  bool father = false;
  bool mother = false;
  int sons = 0;
  int daughters = 0;
  String result = '';

  void calc() {
    double estate = double.tryParse(estateCtrl.text) ?? 0;
    if (estate <= 0) { setState(()=> result = 'اكتب قيمة التركة'); return; }
    
    double remaining = estate;
    Map<String, double> shares = {};
    
    if (mother) {
      double s = (sons>0||daughters>0) ? estate/6 : estate/3;
      shares['الأم'] = s; remaining -= s;
    }
    if (father && (sons>0||daughters>0)) {
      double s = estate/6;
      shares['الأب'] = s; remaining -= s;
    }
    if (wives>0) {
      double s = (sons>0||daughters>0) ? estate/8 : estate/4;
      shares['الزوجات'] = s; remaining -= s;
    }
    if (husband) {
      double s = (sons>0||daughters>0) ? estate/4 : estate/2;
      shares['الزوج'] = s; remaining -= s;
    }
    
    if (daughters>0 && sons==0) {
      double s = daughters==1 ? estate*0.5 : estate*(2/3);
      shares['البنات'] = s; remaining -= s;
    }
    
    int parts = sons*2 + daughters;
    if (parts>0 && sons>0) {
      double pv = remaining/parts;
      if (sons>0) shares['نصيب الابن'] = pv*2;
      if (daughters>0) shares['نصيب البنت'] = pv;
      remaining = 0;
    }
    
    if (remaining>0 && father) {
      shares['الأب (الباقي)'] = (shares['الأب (الباقي)']??0)+remaining;
      remaining=0;
    }

    StringBuffer b = StringBuffer();
    b.writeln('التركة: $estate\n');
    shares.forEach((k,v)=> b.writeln('$k = ${v.toStringAsFixed(2)}'));
    if (remaining>1) b.writeln('الباقي: ${remaining.toStringAsFixed(2)}');
    setState(()=> result=b.toString());
  }

  Widget counter(String t,int v,Function(int) onC)=> Card(child: ListTile(
    title: Text(t),
    trailing: Row(mainAxisSize: MainAxisSize.min,children:[
      IconButton(onPressed:()=> onC(v>0?v-1:0),icon: const Icon(Icons.remove)),
      Text('$v',style: const TextStyle(fontWeight: FontWeight.bold)),
      IconButton(onPressed:()=> onC(v+1),icon: const Icon(Icons.add)),
    ]),
  ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('وَرَثَة'), centerTitle:true, backgroundColor: Colors.teal, foregroundColor: Colors.white),
      body: ListView(padding: const EdgeInsets.all(12), children:[
        TextField(controller: estateCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText:'قيمة التركة', border: OutlineInputBorder())),
        counter('عدد الزوجات',wives,(x)=> setState(()=>wives=x)),
        SwitchListTile(title: const Text('زوج'), value: husband, onChanged:(x)=> setState(()=>husband=x)),
        SwitchListTile(title: const Text('أب'), value: father, onChanged:(x)=> setState(()=>father=x)),
        SwitchListTile(title: const Text('أم'), value: mother, onChanged:(x)=> setState(()=>mother=x)),
        counter('أبناء ذكور',sons,(x)=> setState(()=>sons=x)),
        counter('بنات',daughters,(x)=> setState(()=>daughters=x)),
        const SizedBox(height:12),
        ElevatedButton(style:ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(50)), onPressed: calc, child: const Text('احسب', style: TextStyle(fontSize:18))),
        const SizedBox(height:12),
        if(result.isNotEmpty) Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(10)), child: Text(result, textDirection: TextDirection.rtl, style: const TextStyle(fontSize:16))),
      ]),
    );
  }
}
