import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() => runApp(WarathaApp());
class WarathaApp extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(title:'ورثة',debugShowCheckedModeBanner:false,theme:ThemeData(fontFamily:'Cairo',primaryColor:Color(0xFF1B5E20)),home:HomePage());
  }
}
class HomePage extends StatefulWidget{
  @override
  _HomePageState createState()=>_HomePageState();
}
class _HomePageState extends State<HomePage>{
  final moneyCtrl=TextEditingController(text:'100000');
  final goldCtrl=TextEditingController(text:'50');
  final flatCtrl=TextEditingController(text:'120');
  int wives=1,sons=2,daughters=1;
  Map<String,dynamic> result={};
  void calculate(){
    double money=double.tryParse(moneyCtrl.text)??0;
    double gold=double.tryParse(goldCtrl.text)??0;
    double flat=double.tryParse(flatCtrl.text)??0;
    double wifeShare=(sons+daughters)>0?1/8:1/4;
    double wifeMoney=money*wifeShare;
    double wifeGold=gold*wifeShare;
    double wifeFlat=flat*wifeShare;
    double remM=money-wifeMoney,remG=gold-wifeGold,remF=flat-wifeFlat;
    int parts=sons*2+daughters;
    setState((){
      result={
        'wifeMoney':wifeMoney,'wifeGold':wifeGold,'wifeFlat':wifeFlat,
        'sonMoney':parts>0?remM*2/parts:0,'sonGold':parts>0?remG*2/parts:0,'sonFlat':parts>0?remF*2/parts:0,
        'daughterMoney':parts>0?remM*1/parts:0,'daughterGold':parts>0?remG*1/parts:0,'daughterFlat':parts>0?remF*1/parts:0,
      };
    });
  }
  Future<void> makePdf() async{
    final pdf=pw.Document();
    pdf.addPage(pw.Page(build:(c)=>pw.Column(children:[pw.Text('ورثة - قسمة الميراث',style:pw.TextStyle(fontSize:24)),pw.SizedBox(height:20),pw.Text('الزوجة: ${result['wifeMoney']} جنيه + ${result['wifeGold']} جرام + ${result['wifeFlat']} م²'),pw.Text('الابن: ${result['sonMoney']} + ${result['sonGold']} + ${result['sonFlat']}'),pw.Text('البنت: ${result['daughterMoney']} + ${result['daughterGold']} + ${result['daughterFlat']}'),pw.SizedBox(height:30),pw.Text('للفتوى: 107 دار الإفتاء',style:pw.TextStyle(fontSize:10)) ])));
    await Printing.layoutPdf(onLayout:(f)=>pdf.save());
  }
  Widget counter(String t,int v,Function(int) on){
    return Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Row(children:[IconButton(icon:Icon(Icons.add_circle,color:Color(0xFFD4AF37)),onPressed:()=>on(v+1)),Text('$v',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),IconButton(icon:Icon(Icons.remove_circle,color:Color(0xFF1B5E20)),onPressed:()=>on(v>0?v-1:0))]),Text(t,style:TextStyle(fontSize:16))]);
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(appBar:AppBar(title:Text('ورثة - حاسبة الميراث'),backgroundColor:Color(0xFF1B5E20),foregroundColor:Colors.white),body:SingleChildScrollView(padding:EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[Card(child:Padding(padding:EdgeInsets.all(12),child:Column(children:[Text('التركة',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold,color:Color(0xFF1B5E20))),TextField(controller:moneyCtrl,keyboardType:TextInputType.number,decoration:InputDecoration(labelText:'المبلغ (جنيه)',prefixIcon:Icon(Icons.money))),TextField(controller:goldCtrl,keyboardType:TextInputType.number,decoration:InputDecoration(labelText:'الذهب (جرام)',prefixIcon:Icon(Icons.star))),TextField(controller:flatCtrl,keyboardType:TextInputType.number,decoration:InputDecoration(labelText:'الشقة (م²)',prefixIcon:Icon(Icons.home))) ]))),Card(child:Padding(padding:EdgeInsets.all(12),child:Column(children:[Text('الورثة',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold,color:Color(0xFF1B5E20))),counter('زوجة',wives,(v)=>setState(()=>wives=v)),counter('أبناء',sons,(v)=>setState(()=>sons=v)),counter('بنات',daughters,(v)=>setState(()=>daughters=v)) ]))),SizedBox(height:15),ElevatedButton(style:ElevatedButton.styleFrom(backgroundColor:Color(0xFFD4AF37),padding:EdgeInsets.symmetric(vertical:15)),onPressed:calculate,child:Text('احسب الميراث',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold,color:Color(0xFF1B5E20)))),if(result.isNotEmpty) Card(color:Color(0xFFE8F5E9),child:Padding(padding:EdgeInsets.all(16),child:Column(children:[Text('النتيجة',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),SizedBox(height:10),Text('الزوجة: ${result['wifeMoney']?.toStringAsFixed(0)} ج + ${result['wifeGold']?.toStringAsFixed(1)} جم + ${result['wifeFlat']?.toStringAsFixed(1)} م²'),Divider(),Text('كل ابن: ${result['sonMoney']?.toStringAsFixed(0)} ج + ${result['sonGold']?.toStringAsFixed(1)} جم + ${result['sonFlat']?.toStringAsFixed(1)} م²'),Text('كل بنت: ${result['daughterMoney']?.toStringAsFixed(0)} ج + ${result['daughterGold']?.toStringAsFixed(1)} جم + ${result['daughterFlat']?.toStringAsFixed(1)} م²'),SizedBox(height:15),ElevatedButton.icon(onPressed:makePdf,icon:Icon(Icons.picture_as_pdf),label:Text('حفظ PDF'),style:ElevatedButton.styleFrom(backgroundColor:Color(0xFF1B5E20),foregroundColor:Colors.white))]))),Center(child:Text('يُوصِيكُمُ اللَّهُ فِي أَوْلَادِكُمْ - النساء 11',style:TextStyle(color:Color(0xFF1B5E20)))) ]))));
  }
}
