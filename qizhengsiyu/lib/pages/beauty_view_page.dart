import 'dart:math';
import 'dart:ui' as ui;
import 'package:common/painter/text_circle_ring_painter.dart';
import 'package:common/painter/circle_ring_printer.dart';
import 'package:el_tooltip/el_tooltip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:qizhengsiyu/enums/enum_qi_zheng.dart';
import 'package:qizhengsiyu/enums/enum_stars.dart';
import 'package:qizhengsiyu/models/eleven_stars_info.dart';
import 'package:qizhengsiyu/pages/ui_star_model.dart';
import 'package:qizhengsiyu/qi_zheng_si_yu_constant_resources.dart';
import 'package:qizhengsiyu/pages/qi_zheng_si_yu_viewmodel.dart';
import 'package:tuple/tuple.dart';


import '../enums/enum_twelve_gong.dart';
import '../models/panel_stars_info.dart';
import '../models/stars_angle.dart';
import '../models/observer_position.dart';
import '../painter/star_body_ring_painter.dart';
import '../painter/star_xiu_ring_painter.dart';
import '../painter/twelve_zhi_gong_circle_ring_printer.dart';
import '../qi_zheng_si_yu_ui_constant_resources.dart';

class QiZhengSiYuPanSizeDataModel {
  // default:

  // late final double centerSize = 172;
  // late final double diZhi12GongSize = 120;
  // late final double zodiac12GongSize = 41;
  // late final double starSeq12GongSize = 360;
  // late final double destiny12GongSize = 67;
  // late final double lifeStarRingSize = 16 * 8; // 564
  // late final double starXiu28RingSize = 96; // 660

  late final double centerSize;
  late final double diZhi12GongSize;
  late final double zodiac12GongSize;
  late final double starSeq12GongSize;
  late final double destiny12GongSize;
  late final double lifeStarRingSize; // 564
  late final double starXiu28RingSize; // 660
  late bool showFateLifeStarRing;


  late double diZhi12GongInner;
  late double diZhi12GongOuter;

  late double zodiac12GongSizeInner;
  late double zodiac12GongSizeOuter;

  late double starSeq12GongSizeInner;
  late double starSeq12GongSizeOuter;

  late double destiny12GongSizeInner;
  late double destiny12GongSizeOuter;

  // double starXiu28RingSizeOuter = 520 + 96; // 616
  // double starXiu28RingSizeInner = 520 + 96 - 80; // 616 - 80 = 536


  // double fateLifeStarOuterSize = 520 + 96 - 80;
  // double fateLifeStarTrackSize = 520 + 96 - 80 - 16*3;
  // double fateLifeStarInnerSize = 436;

  late double innerLifeStarRingOuterSize; //564
  late double innerLifeStarRingTrackSize;
  late double innerLifeStarRingInnerSize;


  late double starXiu28RingSizeOuter; // 660
  late double starXiu28RingSizeInner; // 616 - 80 = 536

  late double outerLifeStarRingInnerSize; // starXiu28RingSizeOuter
  late double outerLifeStarRingTrackSize;
  late double outerLifeStarRingOuterSize;


  QiZhengSiYuPanSizeDataModel({
    required this.centerSize,
    required this.diZhi12GongSize,
    required this.zodiac12GongSize,
    required this.starSeq12GongSize,
    required this.destiny12GongSize,
    required this.lifeStarRingSize,
    required this.starXiu28RingSize,
    required this.showFateLifeStarRing,

  }){
    diZhi12GongInner = centerSize;
    diZhi12GongOuter = centerSize+diZhi12GongSize;

    zodiac12GongSizeInner = diZhi12GongOuter;
    zodiac12GongSizeOuter = diZhi12GongOuter+zodiac12GongSize;

    starSeq12GongSizeInner = zodiac12GongSizeOuter;
    starSeq12GongSizeOuter = zodiac12GongSizeOuter+starSeq12GongSize;

    destiny12GongSizeInner = starSeq12GongSizeOuter;
    destiny12GongSizeOuter = starSeq12GongSizeOuter+destiny12GongSize;

    innerLifeStarRingInnerSize = destiny12GongSizeOuter;
    innerLifeStarRingTrackSize = innerLifeStarRingInnerSize + lifeStarRingSize * .5;
    innerLifeStarRingOuterSize = innerLifeStarRingInnerSize+lifeStarRingSize;

    starXiu28RingSizeInner = innerLifeStarRingOuterSize;
    starXiu28RingSizeOuter = starXiu28RingSizeInner+starXiu28RingSize;


    outerLifeStarRingInnerSize = starXiu28RingSizeOuter; // starXiu28RingSizeOuter
    outerLifeStarRingTrackSize = starXiu28RingSizeOuter+lifeStarRingSize * .5;
    outerLifeStarRingOuterSize = starXiu28RingSizeOuter+lifeStarRingSize;
  }
}
class BeautyViewPage extends StatefulWidget {
  const BeautyViewPage({super.key});

  @override
  State<BeautyViewPage> createState() => _BeautyViewPageState();
}

class _BeautyViewPageState extends State<BeautyViewPage> with TickerProviderStateMixin {

  static const List<String> destinyList = <String>["命宫", "财帛", "兄弟", "田宅", "男女", "奴仆", "夫妻", "疾厄", "迁移", "官禄", "福德", "相貌",];
  final GlobalKey key1 = GlobalKey();
  final GlobalKey key2 = GlobalKey();


  late AnimationController _jupiterController;  // 木星
  late AnimationController _saturnController;  // 土星
  late AnimationController _venusController;  // 金星
  late AnimationController _mercuryController; // 水星
  late AnimationController _marsController; // 火星

  late AnimationController _sunController; // 太阳
  late AnimationController _moonController; // 月亮

  late AnimationController _luoHouJiDuController; // 罗睺 计都
  late AnimationController _yueBeiController; // 月孛
  late AnimationController _ziQiController; // 紫炁

  double yuStarSize = 16;
  double zhengStarSize = 26;
  double yinYangStarSize = 32;

  double marsSkyCoordLon = 75.58091941;
  double venusSkyCoordLon = 359.88416846;
  double mercurySkyCoordLon = 312.79800634;
  double jupiterSkyCoordLon = 9.67729768;
  double saturnSkyCoordLon = 327.87317251;
  double sunSkyCoordLon = 331.24872792;
  double moonSkyCoordLon = 334.13505029;

  late QiZhengSiYuPanSizeDataModel panelSizeDataModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // 0°02′02‘’ 一天
    _jupiterController = AnimationController(vsync: this,duration: Duration(seconds: 1062))..addStatusListener((status) {
      if (status == AnimationStatus.completed){
        _jupiterController.repeat();
      }
    });

    // 土星 0°00′59'' 一天
    _saturnController = AnimationController(vsync: this,duration: Duration(seconds: 2197))..addStatusListener((status) {
      if (status == AnimationStatus.completed){
        _saturnController.repeat();
      }
    });

    // 金星 1°33′ 一天
    _venusController = AnimationController(vsync: this,duration: Duration(seconds: 1393))..addStatusListener((status) {
      if (status == AnimationStatus.completed){
        _venusController.repeat();
      }
    });

    // 水星 4°5′ 一天
    _mercuryController = AnimationController(vsync: this,duration: Duration(seconds: 88))..addStatusListener((status) {
      if (status == AnimationStatus.completed){
        _mercuryController.repeat();
      }
    });

    // 火星 0°32′ 一天
    _marsController = AnimationController(vsync: this,duration: Duration(seconds: 675))..addStatusListener((status) {
      if (status == AnimationStatus.completed){
        _marsController.repeat();
      }
    });

    _sunController = AnimationController(vsync: this,duration: Duration(seconds: 360))..addStatusListener((status) {
      if (status == AnimationStatus.completed){
        _sunController.repeat();
      }
    });
    // 月亮 13°10′35" 一天
    _moonController = AnimationController(vsync: this,duration: Duration(seconds: 27))..addStatusListener((status) {
      if (status == AnimationStatus.completed){
        _moonController.repeat();
      }
    });

    _luoHouJiDuController = AnimationController(vsync: this,duration: Duration(seconds: 12))..addStatusListener((status) {
      if (status == AnimationStatus.completed){
        _luoHouJiDuController.repeat();
      }
    });
    _yueBeiController = AnimationController(vsync: this,duration: Duration(seconds: 18))..addStatusListener((status) {
      if (status == AnimationStatus.completed){
        _yueBeiController.repeat();
      }
    });
    _ziQiController = AnimationController(vsync: this,duration: Duration(seconds: 14))..addStatusListener((status) {
      if (status == AnimationStatus.completed){
        _ziQiController.repeat();
      }
    });

    panelSizeDataModel = QiZhengSiYuPanSizeDataModel(
        centerSize : 172,
        diZhi12GongSize : 120,
        zodiac12GongSize : 41,
        starSeq12GongSize : 36,
        destiny12GongSize : 67+32 + 32,
        lifeStarRingSize : 16 * 8, // 564
        starXiu28RingSize : 96, // 660
        showFateLifeStarRing: true
    );


  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _jupiterController.dispose();
    _saturnController.dispose();
    _venusController.dispose();
    _mercuryController.dispose();
    _marsController.dispose();

    _sunController.dispose();
    _moonController.dispose();

    _luoHouJiDuController.dispose();
    _yueBeiController.dispose();
    _ziQiController.dispose();
    showTaiJiDianButtonNotifier.dispose();
    _destiny12GongListNotifier.dispose();
    _selectedTaiJiDestiny12GongListNotifier.dispose();

  }
  bool isFirst = true;

  // double centerSize = 172;
  // double diZhi12GongInner= 172;
  // double diZhi12GongOuter = 292;
  // double zodiac12GongSizeInner = 292;
  // double zodiac12GongSizeOuter = 333;
  //
  // double starSeq12GongSizeInner = 333;
  // double starSeq12GongSizeOuter = 369;
  //
  // double destiny12GongOuterSizeInner = 369;
  // double destiny12GongOuterSizeOuter = 436;

  // double starXiu28RingSizeOuter = 520 + 96; // 616
  // double starXiu28RingSizeInner = 520 + 96 - 80; // 616 - 80 = 536


  // double fateLifeStarOuterSize = 520 + 96 - 80;
  // double fateLifeStarTrackSize = 520 + 96 - 80 - 16*3;
  // double fateLifeStarInnerSize = 436;

  // double fateLifeStarOuterSize = 436 + 16*8; //564
  // double fateLifeStarTrackSize = 436 + 16*4;
  // double fateLifeStarInnerSize = 436;
  //
  // double starXiu28RingSizeOuter = 564 + 96; // 660
  // double starXiu28RingSizeInner = 564; // 616 - 80 = 536
  //
  // double basicLifeStarRingInnerSize = 660; // starXiu28RingSizeOuter
  // double basicLifeStarBodyTrackSize = 660 + 16*4;
  // double basicLifeStarRingOuterSize = 660 + 16*8;

  ValueNotifier<bool> showTaiJiDianButtonNotifier = ValueNotifier(true);

  double get centerSize => panelSizeDataModel.centerSize;
  double get diZhi12GongInner=> panelSizeDataModel.diZhi12GongInner;
  double get diZhi12GongOuter => panelSizeDataModel.diZhi12GongOuter;
  double get zodiac12GongSizeInner => panelSizeDataModel.zodiac12GongSizeInner;
  double get zodiac12GongSizeOuter => panelSizeDataModel.zodiac12GongSizeOuter;
  double get starSeq12GongSizeInner => panelSizeDataModel.starSeq12GongSizeInner;
  double get starSeq12GongSizeOuter => panelSizeDataModel.starSeq12GongSizeOuter;
  double get destiny12GongSizeInner => panelSizeDataModel.destiny12GongSizeInner;
  double get destiny12GongSizeOuter => panelSizeDataModel.destiny12GongSizeOuter;
  double get fateLifeStarOuterSize => panelSizeDataModel.innerLifeStarRingOuterSize; //564
  double get fateLifeStarTrackSize => panelSizeDataModel.innerLifeStarRingTrackSize;
  double get fateLifeStarInnerSize => panelSizeDataModel.innerLifeStarRingInnerSize;
  double get starXiu28RingSizeOuter => panelSizeDataModel.starXiu28RingSizeOuter; // 660
  double get starXiu28RingSizeInner => panelSizeDataModel.starXiu28RingSizeInner; // 616 - 80 = 536
  double get basicLifeStarRingInnerSize => panelSizeDataModel.outerLifeStarRingInnerSize; // starXiu28RingSizeOuter
  double get basicLifeStarBodyTrackSize => panelSizeDataModel.outerLifeStarRingTrackSize;
  double get basicLifeStarRingOuterSize => panelSizeDataModel.outerLifeStarRingOuterSize;

  /// _destiny12GongListNotifier list#index 对应地支方位 0-子 1-亥 ...
  ValueNotifier<List<String>> _destiny12GongListNotifier = ValueNotifier(["命宫", "财帛", "兄弟", "田宅", "男女", "奴仆", "夫妻", "疾厄", "迁移", "官禄", "福德", "相貌",]);
  /// _selectedTaiJiDestiny12GongListNotifier list#index 对应地支方位 0-子 1-亥
  ValueNotifier<List<String>?> _selectedTaiJiDestiny12GongListNotifier = ValueNotifier(null);
  TextStyle destinyTextStyle = GoogleFonts.maShanZheng(
      color: Colors.black87,
      fontSize: 24,
      fontWeight: FontWeight.normal,
      shadows: [
        BoxShadow(
          color: Colors.black45.withOpacity(.2),
          spreadRadius: 1,
          blurRadius: 1,
          offset: Offset(1, 1), // changes position of shadow
        )
      ]
  );


  @override
  Widget build(BuildContext context) {

    // late final double centerSize = 172;
    // late final double diZhi12GongSize = 120;
    // late final double zodiac12GongSize = 41;
    // late final double starSeq12GongSize = 360;
    // late final double destiny12GongSize = 67;
    // late final double lifeStarRingSize = 16 * 8; // 564
    // late final double starXiu28RingSize = 96; // 660




    // double height = MediaQuery.of(context).size.height;
    // double width  = MediaQuery.of(context).size.width;
    // double minSize = height > width ? width : height;




    // 星体半径 16
    double starBodyRadius = 16;
    // 本命盘星轨内环
    double starInnRangeMiddleSize = 520+96;
    // 本命盘星轨外环
    double basicLifeStarCenterCircleSize = starInnRangeMiddleSize+starBodyRadius*2+12;

    // double fateLifeStarCenterCircleSize= starInnRangeMiddleSize+starBodyRadius*2+12;

     // 星轨外环，当前 80 为 星宿ring的 width*2
    Provider.of<QiZhengSiYuViewModel>(context).calculateBasicStarsSafetyAngle(starBodyRadius,starInnRangeMiddleSize,basicLifeStarCenterCircleSize);
    Provider.of<QiZhengSiYuViewModel>(context).calculateFateStarsSafetyAngle(starBodyRadius,destiny12GongSizeOuter,fateLifeStarOuterSize);



    if (isFirst){
      Future.delayed(Duration(seconds: 3),(){
        isFirst = false;
        calculatePanel();
      });
    }
    // StarsAngle starsAngle = calculateSevenZhengAngle(observerPostion);


    // FiveStarWalkingInfo value = StarWalkingInfoUtils.calculateStarWalkingInfo(EnumSevenZheng.Golden,observerPosition,StarsAngle.moirasFiveStartsMapper);
    // print("value ${value.toString()}");
    // 使用 dart:math 库中的函数进行转换
    // return Scaffold(
    //   body: Container(
    //     width: 1000,
    //       height: 1000,
    //       alignment: Alignment.center,
    //       child: CircleIndicatorWidget()),
    // );
    return Scaffold(
      body: Container(
          width: 1000,
          height: 1000,
          alignment: Alignment.center,
          child: Column(
            children: [
              SizedBox(height: 20,),
              Consumer<QiZhengSiYuViewModel>(
                  builder: (context, viewModel, child) {
                    if (viewModel.basicLifeStarsAngle == null){
                      return child!;
                    }
                    return panel(
                      viewModel.uiBasicLifeStars,
                        viewModel.uiFateLifeStars,
                        viewModel.basicLifeStarsAngle!,
                        // viewModel.fateLifeStarsAngle,
                        null,
                        starBodyRadius,
                        starInnRangeMiddleSize,
                        fateLifeStarOuterSize,
                        basicLifeStarCenterCircleSize
                    );
                  },
                  child:SizedBox(
                    height: 160,
                  )
              ),
            ]
          )
      ),
    );
  }

  void calculatePanel(){
    // 设定观察者的经纬度和高度（例如：上海）
    double latitude = 31.2304; // 纬度
    double longitude = 121.4737; // 经度
    double altitude = 0; // 高度（米）
    var observerPosition = ObserverPosition(
        latitude: latitude,
        longitude: longitude,
        altitude: altitude,
        fateLifeDateTime: DateTime(2024, 10, 13, 16, 45),
        birthday: DateTime(1982, 10,25, 02, 30),
        timezone: 'Asia/Shanghai'

    );
    Provider.of<QiZhengSiYuViewModel>(context,listen: false).calculate(observerPosition);
  }


  Widget center(){
    return Container(
        width: centerSize,
        height: centerSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(.1),
          borderRadius: BorderRadius.circular(centerSize),
          border: Border.all(color: Colors.black,width: 1),
        ),
        child:Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children:[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("立命",style: TextStyle(fontSize: 12,height: 1.2),),
                    // SizedBox(width: 4,),
                    Text("昴日鸡",style: TextStyle(fontSize: 14,height: 1.2),),
                    Text("六度",style: TextStyle(fontSize: 12,height: 1.2),),
                  ],
                )

              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children:[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("运",style: TextStyle(fontSize: 10),),
                    Text("癸",style: TextStyle(fontSize: 16)),
                    Text("卯",style: TextStyle(fontSize: 16)),
                  ],
                ),
                SizedBox(width: 6,),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("流",style: TextStyle(fontSize: 10)),
                    Text("辛",style: TextStyle(fontSize: 16)),
                    Text("丑",style: TextStyle(fontSize: 16)),
                  ],
                ),
                SizedBox(width: 6,),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("年",style: TextStyle(fontSize: 10),),
                    Text("癸",style: TextStyle(fontSize: 16)),
                    Text("卯",style: TextStyle(fontSize: 16)),
                  ],
                ),
                SizedBox(width: 6,),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("月",style: TextStyle(fontSize: 10)),
                    Text("辛",style: TextStyle(fontSize: 16)),
                    Text("丑",style: TextStyle(fontSize: 16)),
                  ],
                ),
                SizedBox(width: 6,),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("日",style: TextStyle(fontSize: 10),),
                    Text("癸",style: TextStyle(fontSize: 16)),
                    Text("卯",style: TextStyle(fontSize: 16)),
                  ],
                ),
                SizedBox(width: 6,),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("时",style: TextStyle(fontSize: 10)),
                    Text("辛",style: TextStyle(fontSize: 16)),
                    Text("丑",style: TextStyle(fontSize: 16)),
                  ],
                )
              ],
            ),
            Column(
              children:[
                Text("ok3"),
                Text("ok3")
              ],
            ),
          ],
        )
    );
  }
  Widget panel(
      List<UIStarModel> uiBasicStarList,
      List<UIStarModel> uiFateStarList,
      StarsAngle basicLifeStarsAngle,
      StarsAngle? fateLifeStarsAngle,
      double starBodyRadius,
      double starInnRangeMiddleSize,
      double fateLifeStarTrackOuterSize,
      double basicLifeStarCenterCircleSize
      ){
    // 黄道十二宫 从白羊开始
    // List<String> zodiacEnglishList = <String>["Ari白羊♈︎", "Tau金牛♉︎", "Gem双子♊︎", "Can巨蟹♋︎", "Leo狮子♌︎", "Vir处女♍︎", "Lib天秤♎︎︎", "Sco天蝎♏︎", "Sag射手♐︎", "Cap摩羯♑︎", "Agu水瓶♒︎", "Pis双鱼♓︎",];
    // List<String> zodiacList = <String>["白羊♈︎", "金牛♉︎", "双子♊︎", "巨蟹♋︎", "狮子♌︎", "处女♍︎", "天秤♎︎︎", "天蝎♏︎", "射手♐︎", "摩羯♑︎", "水瓶♒︎", "双鱼♓︎",];
    List<String> zodiacList = <String>["白羊", "金牛", "双子", "巨蟹", "狮子", "处女", "天秤", "天蝎", "射手", "摩羯", "水瓶", "双鱼",];
    // TextStyle zodiacTextStyle = TextStyle(color: Colors.grey, fontSize: 12,fontFamily: 'KaiTi',fontWeight: FontWeight.w300,height: 1.2);
    TextStyle zodiacTextStyle = GoogleFonts.longCang(
        color: Color.fromRGBO(66,76,80, 1),
        fontSize: 14,
        fontWeight: FontWeight.normal,
        height: 1.0);
    List<Text> zodiacTextList = zodiacList.map((e) => Text(e,style: zodiacTextStyle,)).toList();

    // 十二星次 从大梁开始
    List<String> starSeqList = <String>["降娄", "大梁", "实沈", "鹑首", "鹑火", "鹑尾", "寿星", "大火", "析木", "星纪", "玄枵", "娵訾",];
    // TextStyle starTextStyle = TextStyle(color: Colors.grey, fontSize: 12,fontFamily: 'KaiTi',fontWeight: FontWeight.w300,height: 1.2);
    TextStyle starTextStyle = GoogleFonts.zhiMangXing(
        color: Color.fromRGBO(80,97,109, 1),
        fontSize: 12  ,
        fontWeight: FontWeight.normal,
        height: 1.0);
    List<Text> starSeqTextList = starSeqList.map((e) => Text(e,style: starTextStyle,)).toList();
    // 命理十二宫 从命宫开始
    // List<String> destinyList = <String>["命宫①", "财帛②", "兄弟③", "田宅④", "男女⑤", "奴仆⑥", "夫妻⑦", "疾厄⑧", "迁移⑨", "官禄⑩", "福德⑪", "相貌⑫",];
    // TextStyle destinyTextStyle = TextStyle(color: Colors.black, fontSize: 20,fontFamily: 'KaiTi',fontWeight: FontWeight.w400);


    List<Text> destinySeqTextList = destinyList.map((e) => Text(e,
      style: destinyTextStyle.copyWith(
          decoration: e==destinyList[0]?TextDecoration.underline:TextDecoration.none,
          fontWeight: e==destinyList[0]?FontWeight.w600:FontWeight.w500),)).toList();

    // Offset goldenPosition = calculatePointOnCircle(basicLifeStarCenterCircleSize,basiceLifeStarsAngle.golden * (pi / 180));
    // Offset sunPosition = calculatePointOnCircle(basicLifeStarCenterCircleSize,basiceLifeStarsAngle.sun * (pi / 180));
    // bool goldenSunIs = isOverlapping(goldenPosition,sunPosition,32);
    // corretedAngle(goldenPosition,sunPosition,basiceLifeStarsAngle.golden * (pi / 180),basiceLifeStarsAngle.sun * (pi / 180),32);
    // if (basiceLifeStarsAngle.golden - 5){
    //   print
    // }


    // uiBasicStarList.forEach((s)=>print(s));

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          alignment: Alignment.center,
          height: diZhi12GongOuter,
          width: diZhi12GongOuter,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(.1),
            borderRadius: BorderRadius.circular(diZhi12GongOuter),
            // border: Border.all(color: Colors.black,width: 1),
          ),
          child: Transform.rotate(
            angle: 105 * pi / 180,
            origin: Offset.zero,
            child:CustomPaint(
                size: Size(diZhi12GongOuter,diZhi12GongOuter),
                painter:TwelveZhiGongCircleRingPrinter(
                  innerRadius: 86,
                  outerRadius: 148,
                  twelveGongList:[
                    EnumTwelveGong.Xu,
                    EnumTwelveGong.Hai,
                    EnumTwelveGong.Zi,
                    EnumTwelveGong.Chou,
                    EnumTwelveGong.Yin,
                    EnumTwelveGong.Mao,
                    EnumTwelveGong.Chen,
                    EnumTwelveGong.Si,
                    EnumTwelveGong.Wu,
                    EnumTwelveGong.Wei,
                    EnumTwelveGong.Shen,
                    EnumTwelveGong.You,
                  ],
                  starColorMapper: QiZhengSiYuUIConstantResources.zhengColorMap,
                  isAntiClockwise: false,
                  innerPadding: 3,
                  isReverseText: false,
                  isHorizontalText: false,
                  textStyle: GoogleFonts.maShanZheng(
                    height: 1.2,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                )
            ),
          ),
        ),
        // 黄道十二宫
        drawRingWithTextList(zodiac12GongSizeOuter, 18, zodiacTextList),
        // 星次十二宫
        drawRingWithTextList(starSeq12GongSizeOuter, 18, starSeqTextList),
        // 命理十二宫
        draw12GongRing(destiny12GongSizeInner, destiny12GongSizeOuter, destinySeqTextList,innerPadding: 2),
        // drawRingWithTextList(destiny12GongSizeOuter, 33, destinySeqTextList,innerPadding: 2),
        Transform.rotate(
          // angle: 60 * math.pi / 180,
          angle:  30 * pi / 180,
          // origin: Offset.zero,
          child: starXiuRing(starXiu28RingSizeOuter, 40),
        ),
        Transform.rotate(
          // angle: 60 * math.pi / 180,
          angle:  30 * pi / 180,
          // origin: Offset.zero,
          child: Container(
            width: fateLifeStarOuterSize,
            height: fateLifeStarOuterSize,
            decoration: BoxDecoration(
              // color: Colors.red.withOpacity(.1),
              borderRadius: BorderRadius.circular(basicLifeStarCenterCircleSize + starBodyRadius * 4),
              border: Border.all(color: Colors.black87,width: 1),
            ),
            child: CustomPaint(
              size: Size(fateLifeStarOuterSize, fateLifeStarOuterSize), // 设置画布大小
              painter: InnerLifeStarRangePainter(
                stars: uiFateStarList,
                starsColorMap: QiZhengSiYuUIConstantResources.starsColorMap,
                outerSize: fateLifeStarOuterSize,
                innerSize: fateLifeStarInnerSize,
                trackSize: fateLifeStarTrackSize,
                textStyle: GoogleFonts.notoSans(
                    fontSize: 20.0,
                    height: 1,
                    // color: Color.fromRGBO(55, 53, 52, 1),
                    color: Colors.black87,
                    fontWeight: FontWeight.normal,
                    shadows: [
                      BoxShadow(
                        color: Colors.black38.withOpacity(.3),
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: Offset(1, 1), // changes position of shadow
                      )
                    ]
                ),
              ),
            ),
          ),
        ),


        Transform.rotate(
          // angle: 60 * math.pi / 180,
          angle:  30 * pi / 180,
          // origin: Offset.zero,
          child: Container(
            // width: basicLifeStarCenterCircleSize + starBodyRadius * 4,
            // height: basicLifeStarCenterCircleSize + starBodyRadius * 4,
            width: basicLifeStarRingOuterSize,
            height: basicLifeStarRingOuterSize,
            decoration: BoxDecoration(
              // borderRadius: BorderRadius.circular(basicLifeStarCenterCircleSize + starBodyRadius * 4),
              borderRadius: BorderRadius.circular(basicLifeStarRingOuterSize),
              border: Border.all(color: Colors.black87,width: 1),
            ),
            child: CustomPaint(
              // size: Size(basicLifeStarCenterCircleSize + starBodyRadius * 4, basicLifeStarCenterCircleSize + starBodyRadius * 4), // 设置画布大小
              size: Size(basicLifeStarRingOuterSize,basicLifeStarRingOuterSize), // 设置画布大小
              painter: OuterLifeStarRangePainter(
                stars: uiBasicStarList,
                starsColorMap: QiZhengSiYuUIConstantResources.starsColorMap,
                outerSize: basicLifeStarRingOuterSize,
                innerSize: basicLifeStarRingInnerSize,
                trackSize: basicLifeStarBodyTrackSize,
                textStyle: GoogleFonts.notoSans(
                    fontSize: 20.0,
                    height: 1,
                    // color: Color.fromRGBO(55, 53, 52, 1),
                    color: Colors.black87,
                    fontWeight: FontWeight.normal,
                    shadows: [
                      BoxShadow(
                        color: Colors.black38.withOpacity(.3),
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: Offset(1, 1), // changes position of shadow
                      )
                    ]
                ),
              ),
            ),
          ),
        ),

        ValueListenableBuilder(
            valueListenable: _destiny12GongListNotifier,
            builder: (ctx, destiny12GongList,child){
              return drawDestiny12Gong(destiny12GongSizeInner, destiny12GongSizeOuter-64,destiny12GongList);
            }),

        ValueListenableBuilder(
            valueListenable: _selectedTaiJiDestiny12GongListNotifier,
            builder: (ctx, selectedTaiJiDestiny12GongList,child){
              return drawSelectedTaiJiDestiny12Gong(destiny12GongSizeOuter-48,destiny12GongSizeOuter,selectedTaiJiDestiny12GongList);
            }),
        // ValueListenableBuilder(
        //     valueListenable: showTaiJiDianButtonNotifier,
        //     builder:(ctx,isShow,_) {
        //       drawDestiny12Gong(destiny12GongSizeInner, destiny12GongSizeOuter,destinyList),
        //     }
        // ),
        center()
      ],
    );
  }

  UIStarsAngle correctBasicLifeAngle(
      StarsAngle starsAngle,
      double basicLifeStarCenterCircleSize){
    double? uiSunAngle;
    double? uiMoonAngle;
    double? uiGoldenAngle;
    double? uiWoodAngle;
    double? uiFireAngle;
    double? uiSoilAngle;
    double? uiWaterAngle;
    double? uiSouthNodeAngle;
    double? uiNorthNodeAngle;
    double? uiBeiNodeAngle;
    double? uiQiAngle;
    double miniCollisionDistance = 48;
    double cosValue = (2 * basicLifeStarCenterCircleSize * basicLifeStarCenterCircleSize - miniCollisionDistance * miniCollisionDistance)/(2 * basicLifeStarCenterCircleSize * basicLifeStarCenterCircleSize);
    double acosValue = acos(cosValue);
    double minCollision = acosValue* (180/pi); // 当小于等于这个值时 两个星体碰撞

    double _diffDegree = 0;
    if (starsAngle.golden < starsAngle.sun){
      _diffDegree = starsAngle.sun - starsAngle.golden;
    }else{
      _diffDegree = starsAngle.golden - starsAngle.sun;
    }
    double needDegreeInTotal = minCollision - _diffDegree;
    double needDegreeAddEach = needDegreeInTotal * .5;
    if (starsAngle.golden < starsAngle.sun){
      uiSunAngle = starsAngle.sun + needDegreeAddEach;
      uiGoldenAngle = starsAngle.golden - needDegreeAddEach;
    }else{
      uiSunAngle = starsAngle.sun - needDegreeAddEach;
      uiGoldenAngle = starsAngle.golden + needDegreeAddEach;
    }
    print("---- Sun:$uiSunAngle Golden:$uiGoldenAngle");

    // create UIStarsAngle from StarsAngle

    return UIStarsAngle.from(
        starsAngle,
        uiSunAngle: uiSunAngle,
        uiMoonAngle: uiMoonAngle,
        uiGoldenAngle: uiGoldenAngle,
        uiWoodAngle: uiWoodAngle,
        uiFireAngle: uiFireAngle,
        uiSoilAngle: uiSoilAngle,
        uiWaterAngle: uiWaterAngle,
        uiSouthNodeAngle: uiSouthNodeAngle,
        uiNorthNodeAngle: uiNorthNodeAngle,
        uiBeiNodeAngle: uiBeiNodeAngle,
        uiQiAngle: uiQiAngle);
  }
  List<Widget> buildAllBasicLifePanelStars(StarsAngle starsAngle,double basicLifeStarCenterCircleSize){
    UIStarsAngle uiStarsAngle = correctBasicLifeAngle(starsAngle,basicLifeStarCenterCircleSize);



    return [
      basicLifePanelStar(EnumStars.Sun,uiStarsAngle),
      basicLifePanelStar(EnumStars.Moon,uiStarsAngle),

      basicLifePanelStar(EnumStars.Golden,uiStarsAngle),
      basicLifePanelStar(EnumStars.Wood,uiStarsAngle),
      basicLifePanelStar(EnumStars.Water,uiStarsAngle),
      basicLifePanelStar(EnumStars.Fire,uiStarsAngle),
      basicLifePanelStar(EnumStars.Soil,uiStarsAngle),

      basicLifePanelStar(EnumStars.Qi,uiStarsAngle),
      basicLifePanelStar(EnumStars.Bei,uiStarsAngle),
      basicLifePanelStar(EnumStars.Ji,uiStarsAngle),
      basicLifePanelStar(EnumStars.Luo,uiStarsAngle),
    ];
  }
  List<Widget> buildAllFateLifePanelStars(StarsAngle starsAngle,double size) {
    return [
      fateLifePanelStar(EnumStars.Sun, starsAngle,size),
      fateLifePanelStar(EnumStars.Moon, starsAngle,size),

      fateLifePanelStar(EnumStars.Golden, starsAngle,size),
      fateLifePanelStar(EnumStars.Wood, starsAngle,size),
      fateLifePanelStar(EnumStars.Water, starsAngle,size),
      fateLifePanelStar(EnumStars.Fire, starsAngle,size),
      fateLifePanelStar(EnumStars.Soil, starsAngle,size),

      fateLifePanelStar(EnumStars.Qi, starsAngle,size),
      fateLifePanelStar(EnumStars.Bei, starsAngle,size),
      fateLifePanelStar(EnumStars.Ji, starsAngle,size),
      fateLifePanelStar(EnumStars.Luo, starsAngle,size),
    ];
  }
  Widget fateLifePanelStar(EnumStars star, StarsAngle starsAngle,double size){

    return Consumer<QiZhengSiYuViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.daXianMapper != null && star.isFiveStar){
          return fatePanelStar(viewModel.daXianMapper![star]!,size);
        }else{
          return child!;
        }
      },
      child: fatePanelStarDefault(star,starsAngle.getByStar(star),64,size,offsetWidthTimes:0),
    );
  }
  Widget basicLifePanelStar(EnumStars star, UIStarsAngle starsAngle){
    return lifePanelStarDefault(star,starsAngle.getUIAngleByStar(star),64,offsetWidthTimes:0);

    // return Consumer<QiZhengSiYuViewModel>(
    //   builder: (context, viewModel, child) {
    //     if (viewModel.basicLifePanelStarsInfo != null){
    //       return lifePanelStar(viewModel.basicLifePanelStarsInfo!.getByStar(star),64,offsetWidthTimes:0);
    //     }else{
    //       return child!;
    //     }
    //   },
    //   child:lifePanelStarDefault(star,starsAngle.getUIAngleByStar(star),64,offsetWidthTimes:0),
    // );
  }


  Widget basicLifeStarPanelHelperCircle(double size){
    return Container(
      width: size,
      height: size,
      // width: 520+32+10,
      // height: 520+32+10,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size),
        border: Border.all(color: Colors.black.withOpacity(.1),width: 1),
      ),
    );
  }

  Widget fatePanelStarDefault(EnumStars star,double degree,double offsetWidth,double size,{int offsetWidthTimes = 0}){
    Color backgroundColor = QiZhengSiYuUIConstantResources.starsColorMap[star]!;
    double oWidth = offsetWidth;
    if (offsetWidthTimes != 0){
      if (offsetWidthTimes < 0){
        int owt = offsetWidthTimes * -1;
        oWidth = offsetWidth + offsetWidth*(owt -1) / 2;
      }else {
        oWidth = offsetWidth + offsetWidth*(offsetWidthTimes -1) / 2;
      }
    }
    return Transform.rotate(
        angle: (120-degree) * pi / 180,
        child: Container(
          width: 32 + oWidth,
          // height: 560,
          // height: 610,
          height: size,
          // color: Colors.blue.withOpacity(.1),
          alignment: Alignment.topCenter,
          child: ElTooltip(
            showModal:false,
            showChildAboveOverlay:false,
            content: Text("tooltip"),
            child: CustomPaint(
              size: const Size(32, 650-600-4),
              painter: MyCirclePainter(
                  toOuter: true,
                  starName:star.singleName,
                  starAngle: degree,
                  // angle:((360-degree) * pi) / 180,
                  radians:((360-(120-degree)) * pi) / 180,
                  offsetTimes: offsetWidthTimes,
                  backgroundColor: backgroundColor,
                  textStyle: GoogleFonts.notoSans(
                      fontSize: 20.0,
                      height: 1,
                      // color: Color.fromRGBO(55, 53, 52, 1),
                      color: QiZhengSiYuUIConstantResources.starsColorMap[star]!,
                      fontWeight: FontWeight.normal,
                      shadows: [
                        BoxShadow(
                          color: Colors.black38.withOpacity(.1),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset: Offset(1, 1), // changes position of shadow
                        )
                      ]
                  )
              ),
            ),
          ),
        ));
  }

  Widget lifePanelUIStarDefault(UIStarModel uiStar){
    Color backgroundColor = QiZhengSiYuUIConstantResources.starsColorMap[uiStar.star]!;
    return Transform.rotate(
        angle: (120-uiStar.angle) * pi / 180,
        child: Container(
          width: 32,
          height: 706,
          // color: Colors.blue.withOpacity(.1),
          alignment: Alignment.topCenter,
          child: ElTooltip(
            showModal:false,
            showChildAboveOverlay:false,
            content: Text("tooltip"),
            // child: Container(),
            child: CustomPaint(
              size: const Size(32, 48),
              painter: StarBodyPainter(
                  star: uiStar,
                  // angle:((360-degree) * pi) / 180,
                  radians:((360-(120-uiStar.angle)) * pi) / 180,
                  backgroundColor: backgroundColor,
                  textStyle: GoogleFonts.notoSans(
                      fontSize: 20.0,
                      height: 1,
                      // color: Color.fromRGBO(55, 53, 52, 1),
                      color: QiZhengSiYuUIConstantResources.starsColorMap[uiStar.star]!,
                      fontWeight: FontWeight.normal,
                      shadows: [
                        BoxShadow(
                          color: Colors.black38.withOpacity(.3),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset: Offset(1, 1), // changes position of shadow
                        )
                      ]
                  )
              ),
            ),
          ),
        ));
  }

  Widget lifePanelStarDefault(EnumStars star,double degree,double offsetWidth,{int offsetWidthTimes = 0}){
    Color backgroundColor = QiZhengSiYuUIConstantResources.starsColorMap[star]!;
    return Transform.rotate(
        angle: (120-degree) * pi / 180,
        child: Container(
          width: 32,
          // height: 560,
          // height: 610,
          // height: 610 + 64+32,
          height: 706,
          color: Colors.blue.withOpacity(.1),
          alignment: Alignment.topCenter,
          child: ElTooltip(
            showModal:false,
            showChildAboveOverlay:false,
            content: Text("tooltip"),
            child: FutureBuilder(
              future: loadImage(),
              builder: (ctx,asyncSnap,){
                return CustomPaint(
                  size: const Size(32, 650-600-4),
                  painter: MyCirclePainter(
                      starName:star.singleName,
                      starAngle: degree,
                      // angle:((360-degree) * pi) / 180,
                      radians:((360-(120-degree)) * pi) / 180,
                      offsetTimes: offsetWidthTimes,
                      backgroundColor: backgroundColor,
                      textStyle: GoogleFonts.notoSans(
                          fontSize: 20.0,
                          height: 1,
                          // color: Color.fromRGBO(55, 53, 52, 1),
                          color: QiZhengSiYuUIConstantResources.starsColorMap[star]!,
                          fontWeight: FontWeight.normal,
                          shadows: [
                            BoxShadow(
                              color: Colors.black38.withOpacity(.3),
                              spreadRadius: 1,
                              blurRadius: 1,
                              offset: Offset(1, 1), // changes position of shadow
                            )
                          ]
                      )
                  ),
                );
              },
            ),
          ),
        ));
  }


  Widget lifePanelStar(ElevenStarsInfo star,double offsetWidth,{int offsetWidthTimes = 0}){
    Color backgroundColor = QiZhengSiYuUIConstantResources.starsColorMap[star.star]!;
    double oWidth = offsetWidth;
    if (offsetWidthTimes != 0){
      if (offsetWidthTimes < 0){
        int owt = offsetWidthTimes * -1;
        oWidth = offsetWidth + offsetWidth*(owt -1) / 2;
      }else {
        oWidth = offsetWidth + offsetWidth*(offsetWidthTimes -1) / 2;
      }
    }
    return Transform.rotate(
      // angle: (120 * pi) / 180,
      angle: 0,
      child: Transform.rotate(
          angle: (120-star.angle) * pi / 180,
          child: Container(
            width: 32 + oWidth,
            // height: 560,
            // height: 610,
            height: 610 + 64+32,
            // color: Colors.blue.withOpacity(.1),
            alignment: Alignment.topCenter,
            child: ElTooltip(
              showModal:false,
              showChildAboveOverlay:false,
              content: Text("tooltip"),
              child: FutureBuilder(
                future: loadImage(),
                builder: (ctx,asyncSnap,){
                  // if (asyncSnap.hasData && asyncSnap.data != null){
                  //   return CustomPaint(
                  //     size: Size(32, 650-600-4),
                  //     painter: PlanetPainter(
                  //         starName:starName,
                  //         angle:((360-degree) * pi) / 180,
                  //         offsetTimes: offsetWidthTimes,
                  //         image: asyncSnap.data!
                  //     ),
                  //   );
                  // }
                  // if (asyncSnap.hasError){
                  //   print(asyncSnap.error);
                  // }
                  return CustomPaint(
                    size: const Size(32, 650-600-4),
                    painter: MyCirclePainter(
                        starName:star.star.singleName,
                        // angle:((360-degree) * pi) / 180,
                        radians:((360-(120-star.angle)) * pi) / 180,
                        starAngle: star.angle,
                        offsetTimes: offsetWidthTimes,
                        backgroundColor: backgroundColor,
                        textStyle: GoogleFonts.notoSans(
                            fontSize: 20.0,
                            height: 1,
                            // color: Color.fromRGBO(55, 53, 52, 1),
                            color: QiZhengSiYuUIConstantResources.starsColorMap[star.star]!,
                            fontWeight: FontWeight.normal,
                            shadows: [
                              BoxShadow(
                                color: Colors.black38.withOpacity(.1),
                                spreadRadius: 1,
                                blurRadius: 1,
                                offset: Offset(1, 1), // changes position of shadow
                              )
                            ]
                        )
                    ),
                  );
                },
              ),
            ),
          )),
    );
  }

  Widget fatePanelStar(FiveStarWalkingInfo walkingInfo,double size){
    Map<FiveStarWalkingType,Color> colorMap = {
     FiveStarWalkingType.Retrograde:Colors.black,
      FiveStarWalkingType.Fast:Colors.red,
      FiveStarWalkingType.Normal:Colors.blue,
      FiveStarWalkingType.Slow:Colors.brown,
      FiveStarWalkingType.Stay:Colors.blueGrey
    };
    Color backgroundColor = colorMap[walkingInfo.walkingType]!;
    double oWidth = 0;
    int offsetWidthTimes = 0;
    double offsetWidth = 0;
    if (offsetWidthTimes != 0){
      if (offsetWidthTimes < 0){
        int owt = offsetWidthTimes * -1;
        oWidth = offsetWidth + offsetWidth*(owt -1) / 2;
      }else {
        oWidth = offsetWidth + offsetWidth*(offsetWidthTimes -1) / 2;
      }
    }
    final textStyle= GoogleFonts.notoSans(
        fontSize: 20.0,
        height: 1,
        // color: Color.fromRGBO(55, 53, 52, 1),
        color: QiZhengSiYuUIConstantResources.zhengColorMap[walkingInfo.star]!,
        fontWeight: FontWeight.normal,
        shadows: [
          BoxShadow(
            color: Colors.black38.withOpacity(.1),
            spreadRadius: 1,
            blurRadius: 1,
            offset: Offset(1, 1), // changes position of shadow
          )
        ]
    );
    return  Transform.rotate(
        angle: (120-walkingInfo.angle) * pi / 180,
        child: Container(
          width: 32 + oWidth,
          height: size,
          // height: 610,
          // color: Colors.blue.withOpacity(.1),
          alignment: Alignment.topCenter,
          child: ElTooltip(
            showModal:false,
            showChildAboveOverlay:false,
            content: Text("tooltip"),
            child: FutureBuilder(
              future: loadImage(),
              builder: (ctx,asyncSnap,){
                return CustomPaint(
                  size: Size(32, 650-600-4),
                  painter: MyCirclePainter(
                      starName:walkingInfo.star.singleName,
                      // angle:((360-degree) * pi) / 180,
                      textStyle: textStyle,
                      radians:((360-(120-walkingInfo.angle)) * pi) / 180,
                      starAngle: walkingInfo.angle,
                      offsetTimes: offsetWidthTimes,
                      backgroundColor: backgroundColor,
                    toOuter: true
                  ),
                );
              },
            ),
          ),
        ));
  }
  Future<ui.Image> loadImage() async {
    var data = await rootBundle.load('assets/planets/mars-bubbles-50.png'); // Replace with your image path
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),targetHeight: 40,targetWidth: 42);
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }
  Widget star(String starName,double degree){
    return Transform.rotate(
        angle: (degree * pi) / 180,
        child: Container(
          width: 32,
          // height: 560,
          height: 650,
          color: Colors.blue.withOpacity(.1),
          padding: EdgeInsets.only(top: 8),
          alignment: Alignment.topCenter,
          child: Transform.rotate(
            angle: ((360-degree) * pi) / 180,
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.black87.withOpacity(.1),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Text(
                starName,style: TextStyle(fontSize: 18,fontWeight: FontWeight.normal,height: 1),
              ),
            ),
          ),
        ));
  }

  // 二十八星宿 刻度环
  Widget starXiuRing(double size, double ringWidth){
    double outerRadius = size / 2;
    return Container(
        width: size, //
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(.4),width: 1),
          color: Colors.black.withOpacity(.1),
          borderRadius: BorderRadius.circular(outerRadius),
        ),
        child: CustomPaint(
          size: Size(size, size),
          painter: StarXiuRingPainter(
            outerSize: starXiu28RingSizeOuter,
            innerSize: starXiu28RingSizeInner,
            mapper: QiZhengSiYuConstantResources.TodayStarsSystemMapper,
            sevenZhengColorMapper: QiZhengSiYuUIConstantResources.zhengColorMap,
          ),
        )
    );
  }
  Widget rulingRing(double size, double ringWidth){
    double outerRadius = size / 2;
    return Align(
      alignment: Alignment.center,
      child: Stack(
        children: [
          Container(
            width: size, //
            height: size,
            alignment: Alignment.center,
            child:CustomPaint(
              size: Size(size, size),
              painter:IndicatorScalePainter(
                  ringWidth: ringWidth,
                  tickLength: 7,
                  indicatorAngle: 45.1
              ),
            )
          ),
          Container(
              width: size, //
              height: size,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(.4),width: 1),
                color: Colors.black.withOpacity(.1),
                borderRadius: BorderRadius.circular(outerRadius),
              ),
              child: CustomPaint(
                size: Size(size, size),
                painter: StarXiuRingPainter(
                  outerSize: starXiu28RingSizeOuter,
                  innerSize: starXiu28RingSizeInner,
                    mapper: QiZhengSiYuConstantResources.TodayStarsSystemMapper,
                  sevenZhengColorMapper: QiZhengSiYuUIConstantResources.zhengColorMap,
                ),
              )
          ),
        ],
      ),
    );
  }

  // 绘制星宿环
  Widget constellationRing(double size, double ringWidth){
    return Align(
          alignment: Alignment.center,
          child: Container(
            width: size, //
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(.4),width: 1),
              // color: Colors.black.withOpacity(.1),
              borderRadius: BorderRadius.circular(270),
            ),
            child:  Transform.rotate(
              // angle: 0,
              // 逆时针旋转80°
              angle: 6 * pi / 180,
              // angle: 0,
              // origin: Offset.zero,
              // origin: Offset(245,245),
              child: CustomPaint(
                size: Size(size, size),
                painter: TwentyEightStarsCircle(
                  innerRadius: 210,
                  outerRadius: 240,
                  innerPadding: 4,
                  outerPadding: 2,
                  isReverseText: true,
                  isReverseOrderSequence: false,
                  textStyle: TextStyle(color: Colors.black, fontSize: 18,height: 1.2),
                  twentyEightStarsList: <Tuple5<int,String,String,Color,num>>[
                    Tuple5(1,"角","角木蛟",Color(0xff006400).withOpacity(.2),11),
                    Tuple5(1,"亢","亢金龙",Color(0xffFFD166).withOpacity(.2),11),
                    Tuple5(1,"氐","氐土貉",Color(0xffFFD700).withOpacity(.2),18),
                    Tuple5(1,"房","房日兔",Color(0xffFFD166).withOpacity(.2),5),
                    Tuple5(1,"心","心月狐",Color(0xfffffef8).withOpacity(.2),8),
                    Tuple5(1,"尾","尾火虎",Color(0xffE34234).withOpacity(.2),15),
                    Tuple5(1,"箕","箕水豹",Color(0xff93b5cf).withOpacity(.2),9),

                    Tuple5(4,"斗","斗木獬",Color(0xff7CFC00).withOpacity(.2),24),
                    Tuple5(4,"牛","牛金牛",Color(0xffFF8C00).withOpacity(.2),8),
                    Tuple5(4,"女","女土蝠",Color(0xff6F4E37).withOpacity(.2),11),
                    Tuple5(4,"虚","虚日鼠",Color(0xffFF8C00).withOpacity(.2),10),
                    Tuple5(4,"危","危月燕",Color(0xffEEE9E6).withOpacity(.2),20),
                    Tuple5(4,"室","室火猪",Color(0xff964B00).withOpacity(.2),16),
                    Tuple5(4,"壁","壁水㺄",Color(0xff2775b6).withOpacity(.2),13),


                    Tuple5(3,"奎","奎木狼",Color(0xff556B2F).withOpacity(.2),11),
                    Tuple5(3,"娄","娄金狗",Color(0xffD2B48C).withOpacity(.2),13),
                    Tuple5(3,"胃","胃土雉",Color(0xffCD853F).withOpacity(.2),12),
                    Tuple5(3,"昴","昴日鸡",Color(0xffFFC125).withOpacity(.2),9),
                    Tuple5(3,"毕","毕月乌",Color(0xffC0C0C0).withOpacity(.2),15),
                    Tuple5(3,"觜","觜火猴",Color(0xffDF302E).withOpacity(.2),1),
                    Tuple5(3,"参","参水猿",Color(0xff1772b4).withOpacity(.2),11),

                    Tuple5(2,"井","井木犴",Color(0xff306754).withOpacity(.2),31),
                    Tuple5(2,"鬼","鬼金羊",Color(0xffFFC125).withOpacity(.2),5),
                    Tuple5(2,"柳","柳土獐",Color(0xff8B795E).withOpacity(.2),17),
                    Tuple5(2,"星","星日马",Color(0xffD2B48C).withOpacity(.2),8),
                    Tuple5(2,"张","张月鹿",Color(0xffFDF5E6).withOpacity(.2),18),
                    Tuple5(2,"翼","翼火蛇",Color(0xffFF0000).withOpacity(.2),17),
                    Tuple5(2,"轸","轸水蚓",Color(0xff346c9c).withOpacity(.2),13),


                  ],
                ),
              ),
            ),
          ),
        );
  }


  Widget drawRing(
  double size,
  double ringWidth,
  List<String> contentList,
  TextStyle textStyle,{double innerPadding = 2}){
    double outerRadius = size / 2;
    double innerRadius = outerRadius - ringWidth;
    return Container(
      alignment: Alignment.center,
      height: size,
      width: size,
      decoration: BoxDecoration(
        // color: Colors.red.withOpacity(.1),
        borderRadius: BorderRadius.circular(size),
        border: Border.all(color: Colors.black,width: 1),
      ),
      child: Transform.rotate(
        angle: 105 * pi / 180,
        origin: Offset.zero,
        child:CustomPaint(
          size: Size(size,size),
          painter:CircleRingPainter(
            innerRadius: innerRadius,
            outerRadius: outerRadius,
            textList: contentList,
            isAntiClockwise: true,
            innerPadding: innerPadding,
            isReverseText: false,
            isHorizontalText: true,
            textStyle: textStyle.copyWith(height: 1.2),
        ),
      ),
    )
    );
  }
  Widget drawDestiny12Gong(
      double innerSize,
      double outerSize,
      List<String> contentList,
      // List<Text> contentList,
      ){
    return Container(
      alignment: Alignment.center,
      height: outerSize,
      width: outerSize,
      child: Stack(
        children:[
          ...List.generate(12, (i)=>Transform.rotate(
            angle: -(i*30+15) * pi / 180,
            // angle: 0,
            origin: Offset.zero,
            child:Column(
              children: [
                Expanded(
                  child: Container(),
                ),
                Transform.rotate(
                  angle: (i >= 3 && i<=8) ? pi: 0,
                  child: Container(
                      alignment: Alignment.bottomCenter,
                      height: 32,
                      width: 56,
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: contentList[i] == "命宫"?Colors.red:Colors.transparent,width: 2))
                      ),
                      // color: Colors.red.withOpacity(.1),
                      // child: e.value,
                      child: Text(contentList[i],style: destinyTextStyle,)
                  ),
                )


              ],
            ),
          ))
        ],
      ),
    );
  }
  Widget drawSelectedTaiJiDestiny12Gong(
      double innerSize,
      double outerSize,
      List<String>? contentList,
      // List<Text> contentList,
      ){
    return Container(
      alignment: Alignment.center,
      height: outerSize,
      width: outerSize,
      child: Stack(
        children:[
          if (contentList != null)
            ... List.generate(12, (i)=>Transform.rotate(
              angle: -(i*30+15) * pi / 180,
              // angle: 0,
              origin: Offset.zero,
              child:Column(
                children: [
                  Expanded(
                    child: Container(),
                  ),
                  Transform.rotate(
                    angle: (i >= 3 && i<=8) ? pi: 0,
                    child:Container(
                        height: 24,
                        width: 56,
                        alignment: Alignment.center,
                        // decoration: BoxDecoration(
                        //   color: Colors.red.withOpacity(.1),
                        //   borderRadius: BorderRadius.circular(10),
                        // ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(child: SizedBox()),
                            // Icon(Icons.dangerous,size: 14,color: Colors.transparent,),
                            Text(
                             contentList[i],
                              style: destinyTextStyle.copyWith(
                                  fontSize: 16,
                                  color: contentList[i] == "命宫"? Colors.red:Colors.black45,
                                  fontWeight: contentList[i] == "命宫"? FontWeight.w500:FontWeight.w300,
                                  decorationStyle: ui.TextDecorationStyle.solid
                              ),
                            ),
                            InkWell(
                                onTap: (){
                                  unselectTaiJiDestiny();
                                },
                                child: Icon(Icons.dangerous_outlined,size: 14,color: Colors.grey))
                            // InkWell(
                            //     onTap: (){
                            //       showTaiJiDianButtonNotifier.value = true;
                                  // unselectTaiJiDestiny();
                                // },
                                // child: Text("X",style: TextStyle(fontSize: 12,height: 1.0),))
                          ],
                        )
                    ),
                  ),

                  SizedBox(height: 6,)
                ],
              ),
            )),
          if (contentList == null)
            ...List.generate(12, (i)=>Transform.rotate(
              angle: (i*30-15) * pi / 180,
              // angle: 0,
              origin: Offset.zero,
              child:Column(
                children: [
                  Expanded(
                    child: Container(),
                  ),

                  Transform.rotate(
                    angle: (i >= 4 && i<=9) ? pi: 0,
                    child:InkWell(
                      onTap: (){
                        selectTaiJiDestiny(i);
                        // showTaiJiDianButtonNotifier.value = false;
                        // print("showTaiJiDianButtonNotifier.value = ${showTaiJiDianButtonNotifier.value}");
                      },
                      child: ValueListenableBuilder(
                          valueListenable: showTaiJiDianButtonNotifier,
                          builder: (ctx,isShow,child){
                            return isShow?child!:SizedBox(height: 24,);
                          },
                          child:Container(
                            height: 24,
                            width: 56,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text("太极点",style: TextStyle(fontSize: 12,height: 1.0),),
                          )
                      ),
                    ),
                  ),
                  SizedBox(height: 6,)
                ],
              ),
            ))
        ],
      ),
    );
  }

  Widget draw12GongRing(
      double innerSize,
      double outerSize,
      List<Text> contentList,{double innerPadding = 2}){
    double outerRadius = outerSize * .5;
    double innerRadius = innerSize  * .5;
    return Container(
        alignment: Alignment.center,
        height: outerSize,
        width: outerSize,
        decoration: BoxDecoration(
          // color: Colors.red.withOpacity(.1),
          borderRadius: BorderRadius.circular(outerSize),
          border: Border.all(color: Colors.black,width: 1),
        ),
        child: Transform.rotate(
          angle: 105 * pi / 180,
          // angle: 0,
          origin: Offset.zero,
          child:CustomPaint(
            size: Size(outerSize,outerSize),
            painter: RingSheetPainter(
              innerRadius: innerRadius,
              outerRadius: outerRadius,
            ),
            // painter:TextCircleRingPainter(
            //   innerRadius: innerRadius,
            //   outerRadius: outerRadius,
            //   textList: contentList,
            //   isAntiClockwise: true,
            //   innerPadding: 0,
            //   isReverseText: false,
            //   isHorizontalText: true,
            // ),
          ),
        )
    );
  }

  Widget drawRingWithTextList(
      double size,
      double ringWidth,
      List<Text> contentList,{double innerPadding = 2}){
    double outerRadius = size / 2;
    double innerRadius = outerRadius - ringWidth;
    return Container(
        alignment: Alignment.center,
        height: size,
        width: size,
        decoration: BoxDecoration(
          // color: Colors.red.withOpacity(.1),
          borderRadius: BorderRadius.circular(size),
          border: Border.all(color: Colors.black,width: 1),
        ),
        child: Transform.rotate(
          angle: 105 * pi / 180,
          // angle: 0,
          origin: Offset.zero,
          child:CustomPaint(
            size: Size(size,size),
            painter:TextCircleRingPainter(
              innerRadius: innerRadius,
              outerRadius: outerRadius,
              textList: contentList,
              isAntiClockwise: true,
              innerPadding: innerPadding,
              isReverseText: false,
              isHorizontalText: true,
            ),
          ),
        )
    );
  }

  /// gongIndex 0-11 子-亥
  void selectTaiJiDestiny(int gongIndex){
    // 根据给定gongIndex
    List<String> _tmpList = destinyList.map((d)=>d).toList();
    // 将_tmpList 从 gongIndex 处分成两个
    List<String> _tmpList1 = _tmpList.sublist(0,gongIndex);
    List<String> _tmpList2 = _tmpList.sublist(gongIndex);
    // 将_tmpList2 拼接在 _tmpList1 前面
    _selectedTaiJiDestiny12GongListNotifier.value = _tmpList2 + _tmpList1;
  }
  void unselectTaiJiDestiny(){
    _selectedTaiJiDestiny12GongListNotifier.value = null;
  }
}


// 当前为赤道
class TwentyEightStarsCircle extends CustomPainter {
  static const int TOTAL = 28;
  final double innerRadius;
  final double outerRadius;
  // tuple5: 东南西北, 星宿名,星宿全称, 颜色, 角度
  List<Tuple5<int,String,String,Color,num>> twentyEightStarsList;
  late TextStyle textStyle;
  bool isReverseText = false;
  bool isReverseOrderSequence = false;

  double innerPadding = 12;
  double outerPadding = 12;


  TwentyEightStarsCircle({
    required this.innerRadius,
    required this.outerRadius,
    required this.twentyEightStarsList,
    this.isReverseText = true,
    this.isReverseOrderSequence = false,
    this.innerPadding = 12,
    this.outerPadding = 12,
    this.textStyle = const TextStyle(color: Colors.black, fontSize: 18,height: 1.2),}){
  }

  void debugPaint(Canvas canvas, Size size, Offset center){
    // canvas.translate(center.dx, center.dy);
    // 给canvas绘制灰色透明度为0.1的背景
    final Paint backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size.width/2, backgroundPaint);

    final Paint background2Paint = Paint()
      ..color = Colors.blue.withOpacity(.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerRadius, background2Paint);

    final Paint background3Paint = Paint()
      ..color = Colors.blue.withOpacity(.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, outerRadius, background3Paint);
    // 绘制圆心点
    final Paint centerPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, centerPaint);


  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // canvas.save();

    canvas.translate(center.dx, center.dy);
    // canvas.translate(center.dx, center.dy);
    canvas.rotate(pi / 4);


    // final res = sweepAngleDegree *0.5 * math.pi / 180;
    // final double startAngle = math.pi / 2 - res;
    // final double sweepAngle = sweepAngleDegree * math.pi / 180;
    final double startAngle = 0;
    final fanRingWidth = outerRadius - innerRadius;

    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = fanRingWidth;

    // canvas.translate(center.dx, center.dy);
    // 计算每个扇环的中心角度
    // double angle = startAngle;
    double arcDrawCircleRadius = innerRadius + (fanRingWidth * 0.5);
    // double textRotationAngle =startAngle + sweepAngle / 2;
    // double textRotationAngle =startAngle;
 
    // 12点方向为起始点
    canvas.rotate(pi - pi/4);
    // 9点方向为起始点 -- not work
    // canvas.rotate(pi/4);
    // 6点方向为起始点 -- not work
    // canvas.rotate(-pi/4);
    // 3点方向为起始点 -- not work
    // canvas.rotate(pi + pi/4);


    double angleCounter = startAngle;
    for (int i = 0; i < TOTAL; i++) {

      double sweepAngle = -twentyEightStarsList[i].item5 * pi / 180;
      // double sweepAngle = 0.18954444444444445;
      // 绘制扇环
      Path path = Path()..addArc(Rect.fromCircle(center: Offset.zero, radius: arcDrawCircleRadius), angleCounter, sweepAngle,);
      // canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: arcDrawCircleRadius), startAngle, sweepAngle, false, paint);
      paint.color = twentyEightStarsList[i].item4;
      canvas.drawPath(path,paint);
      angleCounter += sweepAngle;
    }
    double prevAngle = 0;
    canvas.rotate(pi + pi/2);

    double radi = pi/360;
    double offsetRadi = 5 * radi;

    for (int i = 0; i < TOTAL; i++){
      String text = twentyEightStarsList[i].item2;
      final textSpan = TextSpan(
        text: text,
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );
      // angle to radian
      num currentAngle = twentyEightStarsList[i].item5;
      double angle = prevAngle - currentAngle * radi + offsetRadi;
      canvas.rotate(angle);
      prevAngle = -(currentAngle * radi + offsetRadi);
      textPainter.paint(canvas, Offset(0,innerRadius+innerPadding));

    }
  }

  void paintSingleChar(Canvas canvas, Size size, String text, Offset center,double rotationAngle,double yOffset) {
    final textSpan = TextSpan(
      text: text,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    Offset offset = isReverseText?Offset(
      -textPainter.width * 0.5,
      -innerRadius - innerPadding - textPainter.height +textPainter.height*.1,
    ):Offset(
      -textPainter.width * 0.5,
      innerRadius + innerPadding,
    );
    double rotateAngle = isReverseText?pi:0.0;
    canvas.rotate(rotateAngle);
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return false;
  }
}
class IndicatorScalePainter extends CustomPainter {
  final double ringWidth;
  final double tickLength;
  final double indicatorAngle;

  IndicatorScalePainter({
    required this.indicatorAngle,
    required this.ringWidth,
    required this.tickLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double outerRadius = size.width / 2;
    final double innerRadius = outerRadius - ringWidth;
    // final Paint ringPaint = Paint()
    //   ..color = Colors.black
    //   ..strokeWidth = .5
    //   ..style = PaintingStyle.stroke;

    // Draw outer ring
    // canvas.drawCircle(Offset(centerX, centerY), outerRadius, ringPaint);

    // Draw inner ring
    // canvas.drawCircle(Offset(centerX, centerY), innerRadius, ringPaint);

    final Paint scalePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw regular tick marks
    final double angle = indicatorAngle * pi / 180;
    double length = tickLength;
    // if (i != 0){
    //   if (i % 10 == 0){
    //     length = tickLength *2;
    //   }else if (i % 5 == 0){
    //     length = tickLength + tickLength *0.5;
    //   }
    // }
    final double outerX = centerX + outerRadius * cos(angle);
    final double outerY = centerY + outerRadius * sin(angle);
    final double innerX = centerX + (outerRadius - length) * cos(angle);
    final double innerY = centerY + (outerRadius - length) * sin(angle);
    // Draw scale line near the outer ring
    canvas.drawLine(
      Offset(outerX, outerY),
      Offset(innerX, innerY),
      scalePaint,
    );

    final double innerTickStartX = centerX + innerRadius * cos(angle);
    final double innerTickStartY = centerY + innerRadius * sin(angle);
    final double innerTickEndX = centerX + (innerRadius + length) * cos(angle);
    final double innerTickEndY = centerY + (innerRadius + length) * sin(angle);

    // Draw scale line near the inner ring
    canvas.drawLine(
      Offset(innerTickStartX, innerTickStartY),
      Offset(innerTickEndX, innerTickEndY),
      scalePaint,
    );

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
class MyPainter extends CustomPainter {
  final Offset start;
  final Offset end;

  MyPainter(this.start, this.end);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
class PlanetPainter extends CustomPainter {
  double angle;
  final String starName;
  final ui.Image image;

  int offsetTimes;
  PlanetPainter({required this.angle,required this.starName,required this.offsetTimes,required this.image});
  @override
  void paint(Canvas canvas, Size size) {
    double centerX = size.width*.5-(offsetTimes*size.width*.5);
    int subCenterHeightTimes = 0;
    if (offsetTimes != 0){
      subCenterHeightTimes = offsetTimes < 0?offsetTimes * -1:offsetTimes;
    }
    double centerY = size.height*.5 + (size.height*.05*subCenterHeightTimes);
    Offset center = Offset(centerX,centerY);
    // const radius = 12.0; // Fixed radius

    // indicator line
    // draw a line from, left edge center to canves center
    // canvas.rotate(offsetDegree * pi/180);
    canvas.drawLine(center,Offset(size.width * .5,size.height) , Paint()..color = Colors.red);
    canvas.translate(center.dx,center.dy);



    // canvas.drawLine(center, Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle)), Paint()..color = Colors.red);

    // turning with 45 degree, turning center is center
    // canvas.translate(0, size.height / 2);
    // canvas.translate(size.width, size.height / 2);

    // canvas.rotate(pi / 6);
    // canvas.rotate((360-108) * pi / 180);

    // canvas.drawCircle(Offset.zero, radius, Paint()..color = Colors.green.withOpacity(.1));

    // canvas draw image from assets
    // ui.Image.asset("assets/planets/mars-bubbles-50.png")


    // draw a background block size as this canvas, color with Colors.black.whithOpactiy(.1)
    // canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.black.withOpacity(0.4));

    // canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: size.width, height: size.height), Paint()..color = Colors.black87.withOpacity(.5));

    canvas.rotate(angle);
    // draw text content
    final textStyle= GoogleFonts.longCang(
        fontSize: 22.0,
        height: 1,
        color: Color.fromRGBO(55, 53, 52, 1),
        fontWeight: FontWeight.w600,
        shadows: [
          BoxShadow(
            color: Colors.black38.withOpacity(.1),
            spreadRadius: 1,
            blurRadius: 1,
            offset: Offset(1, 1), // changes position of shadow
          )
        ]
    );
    var textPainter = TextPainter(
      text: TextSpan(
        text:starName,
        style: textStyle,
      ),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    Offset textCenter = Offset(-textPainter.width / 2, -textPainter.height / 2);
    // canvas.drawImage(image, Offset(-textPainter.width * .75, -textPainter.height * .75), Paint());
    canvas.drawImage(image, Offset(-20, -20), Paint());
    // 创建一个模糊效果的层
    // final layer = ui.ImageFilterLayer(
    //   imageFilter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
    // );
    canvas.saveLayer(Offset.zero & size, Paint()..imageFilter = ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0));
    canvas.restore();

    textPainter.paint(canvas, textCenter);


    // draw a red dot at center
    canvas.drawCircle(Offset.zero, 1, Paint()..color = Colors.red);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}


class StarBodyPainter extends CustomPainter {
  UIStarModel star;
  // ElevenStarsInfo starInfo;
  double radians;
  double get starAngle => star.angle;
  double get uiStarAngle => star.originalAngle;
  String get starName=>star.star.singleName;

  final Color backgroundColor;
  final TextStyle textStyle;
  bool toOuter;
  StarBodyPainter({
    required this.star,
    // required this.starInfo,
    required this.radians,
    required this.textStyle,
    required this.backgroundColor,
    this.toOuter = false
  });
  @override
  void paint(Canvas canvas, Size size) {
    // final center = Offset(size.width / 2, size.height / 2);
    // Offset center = toLeft != null?Offset((toLeft!) ?0:size.width, size.height * .5):Offset(size.width * .5, size.height * .5);
    // if (toLeft != null){
    //   offsetTimes = toLeft! ? 1: -1;
    // }else{
    //   offsetTimes = 0;
    // }
    // Offset center = Offset(size.width*.5-(offsetTimes*size.width*.5),size.height*.5);

    int offsetTimes = 0;
    int subCenterHeightTimes = 0;
    print("${starName} - ${starAngle}");
    double centerX = size.width*.5-(offsetTimes*size.width*.5);

    double centerY = size.height*.5 + (size.height*.05*subCenterHeightTimes);
    if (subCenterHeightTimes >= 7){
      centerY += size.height*.2;
    }
    if (subCenterHeightTimes >= 9){
      centerY += size.height*.3;
    }
    Offset center = Offset(centerX,centerY);
    // print("$center $subCenterHeightTimes ${size.width*.5}");
    const radius = 16.0; // Fixed radius

    // indicator line
    // draw a line from, left edge center to canves center
    // canvas.rotate(offsetDegree * pi/180);
    // line's shadow
    if (toOuter){
      canvas.drawLine(
          center,
          Offset(size.width * .5,-size.height * .2) ,
          Paint()
            // ..color = textStyle.color!
            ..color = Colors.red
            ..strokeWidth = .5);
      canvas.drawLine(
          center,
          Offset(size.width * .5,-size.height * .2) ,
          Paint()
            ..color = Colors.black38.withOpacity(.1)
            ..strokeWidth = 3);
    }
    else{
      canvas.drawLine(
          center,
          Offset(size.width * .5 ,size.height) ,
          Paint()
            ..color = Colors.black38.withOpacity(.1)
            ..strokeWidth = 3);
      canvas.drawLine(
          center,
          Offset(size.width * .5,size.height) ,
          Paint()
            // ..color = textStyle.color!
            // ..strokeWidth = .5
            ..color = Colors.red
            ..strokeWidth = .5
      );

    }



    // add shadow to drawLine


    canvas.translate(center.dx,center.dy);



    // canvas.drawLine(center, Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle)), Paint()..color = Colors.red);

    // turning with 45 degree, turning center is center
    // canvas.translate(0, size.height / 2);
    // canvas.translate(size.width, size.height / 2);

    // canvas.rotate(pi / 6);
    // canvas.rotate((360-108) * pi / 180);

    canvas.drawCircle(Offset.zero, radius*.3, Paint()..color = textStyle.color!.withOpacity(.3));
    canvas.drawCircle(Offset(1,1), radius*.3, Paint()..color =  textStyle.color!.withOpacity(.1));

    // canvas draw image from assets
    // ui.Image.asset("assets/planets/mars-bubbles-50.png")


    // draw a background block size as this canvas, color with Colors.black.whithOpactiy(.1)
    // canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.black.withOpacity(0.4));

    // canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: size.width, height: size.height), Paint()..color = Colors.black87.withOpacity(.5));

    canvas.rotate(radians);
    // draw text content

    var textPainter = TextPainter(
      text: TextSpan(
        text:starName,
        style: textStyle,
      ),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2 + 1));


    var typeTextPainter = TextPainter(
      text: TextSpan(
        text:"荫",
        style: textStyle.copyWith(color: Colors.black45,fontSize: 12),
      ),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    typeTextPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    if (toOuter){
      if (starAngle < 180){
        typeTextPainter.paint(canvas, Offset(-textPainter.width, -textPainter.height / 2 - 1));
      }else{
        typeTextPainter.paint(canvas, Offset(textPainter.width*.5, -textPainter.height / 2 - 1));
      }
    }else{
      if (starAngle < 180){
        typeTextPainter.paint(canvas, Offset(textPainter.width*.5, -textPainter.height / 2 - 1));
      }else{
        typeTextPainter.paint(canvas, Offset(-textPainter.width, -textPainter.height / 2 - 1));
      }
    }

    if (["金","木","水","火","土"].contains(starName)) {
      var typeTextPainter = TextPainter(
        text: TextSpan(
          text: "速",
          style: textStyle.copyWith(color: Colors.red, fontSize: 12),
        ),
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      );
      typeTextPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );
      if (toOuter) {
        if (starAngle < 180){
          typeTextPainter.paint(canvas, Offset(-textPainter.width, 1));
        }else{
          typeTextPainter.paint(canvas, Offset(textPainter.width * .5, 1));
        }
      } else {
        if (starAngle < 180){
          typeTextPainter.paint(canvas, Offset(textPainter.width * .5, 1));
        }else{
          typeTextPainter.paint(canvas, Offset(-textPainter.width, 1));
        }
      }
    }


    // draw a red dot at center
    // canvas.drawCircle(Offset.zero, 1, Paint()..color = Colors.red);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}


class MyCirclePainter extends CustomPainter {
  double radians;
  double starAngle;
  final String starName;
  final Color backgroundColor;
  final TextStyle textStyle;
  int offsetTimes;
  bool toOuter;
  MyCirclePainter({
    required this.radians,
    required this.starAngle,
    required this.starName,
    required this.textStyle,
    required this.offsetTimes,
    required this.backgroundColor,
    this.toOuter = false
  });
  @override
  void paint(Canvas canvas, Size size) {
    // final center = Offset(size.width / 2, size.height / 2);
    // Offset center = toLeft != null?Offset((toLeft!) ?0:size.width, size.height * .5):Offset(size.width * .5, size.height * .5);
    // if (toLeft != null){
    //   offsetTimes = toLeft! ? 1: -1;
    // }else{
    //   offsetTimes = 0;
    // }
    // Offset center = Offset(size.width*.5-(offsetTimes*size.width*.5),size.height*.5);
    print("${starName} - ${starAngle}");
    double centerX = size.width*.5-(offsetTimes*size.width*.5);
    int subCenterHeightTimes = 0;
    if (offsetTimes != 0){
      subCenterHeightTimes = offsetTimes < 0?offsetTimes * -1:offsetTimes;
    }
    double centerY = size.height*.5 + (size.height*.05*subCenterHeightTimes);
    if (subCenterHeightTimes >= 7){
      centerY += size.height*.2;
    }
    if (subCenterHeightTimes >= 9){
      centerY += size.height*.3;
    }
    Offset center = Offset(centerX,centerY);
    // print("$center $subCenterHeightTimes ${size.width*.5}");
    const radius = 16.0; // Fixed radius

    // indicator line
    // draw a line from, left edge center to canves center
    // canvas.rotate(offsetDegree * pi/180);
    // line's shadow
    if (toOuter){

      canvas.drawLine(
          center,
          Offset(size.width * .5,-size.height * .2) ,
          Paint()
            ..color = textStyle.color!
            ..strokeWidth = .5);
      canvas.drawLine(
          center,
          Offset(size.width * .5,-size.height * .2) ,
          Paint()
            ..color = Colors.black38.withOpacity(.1)
            ..strokeWidth = 3);
    }
    else{
      canvas.drawLine(
          center,
          Offset(size.width * .5 ,size.height) ,
          Paint()
            ..color = Colors.black38.withOpacity(.1)
            ..strokeWidth = 3);
      canvas.drawLine(
          center,
          Offset(size.width * .5,size.height) ,
          Paint()
            ..color = textStyle.color!
            ..strokeWidth = .5);
    }



    // add shadow to drawLine


    canvas.translate(center.dx,center.dy);



    // canvas.drawLine(center, Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle)), Paint()..color = Colors.red);

    // turning with 45 degree, turning center is center
    // canvas.translate(0, size.height / 2);
    // canvas.translate(size.width, size.height / 2);

    // canvas.rotate(pi / 6);
    // canvas.rotate((360-108) * pi / 180);

    canvas.drawCircle(Offset.zero, radius*.3, Paint()..color = textStyle.color!.withOpacity(.3));
    canvas.drawCircle(Offset(1,1), radius*.3, Paint()..color =  textStyle.color!.withOpacity(.1));

    // canvas draw image from assets
    // ui.Image.asset("assets/planets/mars-bubbles-50.png")


    // draw a background block size as this canvas, color with Colors.black.whithOpactiy(.1)
    // canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.black.withOpacity(0.4));

    // canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: size.width, height: size.height), Paint()..color = Colors.black87.withOpacity(.5));

    canvas.rotate(radians);
    // draw text content

    var textPainter = TextPainter(
      text: TextSpan(
        text:starName,
        style: textStyle,
      ),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2 + 1));


    var typeTextPainter = TextPainter(
      text: TextSpan(
        text:"荫",
        style: textStyle.copyWith(color: Colors.black45,fontSize: 12),
      ),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    typeTextPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    if (toOuter){
      if (starAngle < 180){
        typeTextPainter.paint(canvas, Offset(-textPainter.width, -textPainter.height / 2 - 1));
      }else{
        typeTextPainter.paint(canvas, Offset(textPainter.width*.5, -textPainter.height / 2 - 1));
      }
    }else{
      if (starAngle < 180){
        typeTextPainter.paint(canvas, Offset(textPainter.width*.5, -textPainter.height / 2 - 1));
      }else{
        typeTextPainter.paint(canvas, Offset(-textPainter.width, -textPainter.height / 2 - 1));
      }
    }

    if (["金","木","水","火","土"].contains(starName)) {
      var typeTextPainter = TextPainter(
        text: TextSpan(
          text: "速",
          style: textStyle.copyWith(color: Colors.red, fontSize: 12),
        ),
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      );
      typeTextPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );
      if (toOuter) {
        if (starAngle < 180){
          typeTextPainter.paint(canvas, Offset(-textPainter.width, 1));
        }else{
          typeTextPainter.paint(canvas, Offset(textPainter.width * .5, 1));
        }
      } else {
        if (starAngle < 180){
          typeTextPainter.paint(canvas, Offset(textPainter.width * .5, 1));
        }else{
          typeTextPainter.paint(canvas, Offset(-textPainter.width, 1));
        }
      }
    }
    // draw a red dot at center
    // canvas.drawCircle(Offset.zero, 1, Paint()..color = Colors.red);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class StarIndicator extends CustomPainter {
  double angle;
  final Color backgroundColor;
  final bool toOuter;
  StarIndicator({
    required this.angle,
    required this.backgroundColor,
    this.toOuter = false
  });
  @override
  void paint(Canvas canvas, Size size) {

    double centerX = size.width*.5;
    int subCenterHeightTimes = 0;

    double centerY = size.height*.5 + (size.height*.05*subCenterHeightTimes);
    if (subCenterHeightTimes >= 7){
      centerY += size.height*.2;
    }
    if (subCenterHeightTimes >= 9){
      centerY += size.height*.3;
    }
    Offset center = Offset(centerX,centerY);
    // print("$center $subCenterHeightTimes ${size.width*.5}");
    const radius = 16.0; // Fixed radius

    // indicator line
    // draw a line from, left edge center to canves center
    // canvas.rotate(offsetDegree * pi/180);
    // line's shadow
    if (toOuter){

      canvas.drawLine(
          center,
          Offset(size.width * .5,-size.height * .2) ,
          Paint()
            ..color = backgroundColor
            ..strokeWidth = .5);
      canvas.drawLine(
          center,
          Offset(size.width * .5,-size.height * .2) ,
          Paint()
            ..color = Colors.black38.withOpacity(.1)
            ..strokeWidth = 3);
    }else{
      canvas.drawLine(
          center,
          Offset(size.width * .5 ,size.height) ,
          Paint()
            ..color = Colors.black38.withOpacity(.1)
            ..strokeWidth = 3);
      canvas.drawLine(
          center,
          Offset(size.width * .5,size.height) ,
          Paint()
            ..color = backgroundColor
            ..strokeWidth = .5);
    }



    // add shadow to drawLine


    canvas.translate(center.dx,center.dy);

    canvas.drawCircle(Offset.zero, radius, Paint()..color = backgroundColor.withOpacity(.1));

    canvas.rotate(angle);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

