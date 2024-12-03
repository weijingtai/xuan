
import 'dart:ui';

import 'package:animated_read_more_text/animated_read_more_text.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:common/const_resources_mapper.dart';
import 'package:common/model/enum_ji_xiong.dart';
import 'package:common/model/enum_jia_zi.dart';
import 'package:common/model/enum_tian_gan.dart';
import 'package:common/model/enum_twelve_zhang_sheng.dart';
import 'package:common/widgets/four_zhu_eight_char.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:lunar/calendar/Lunar.dart';
import 'package:qimendunjia/model/ten_gan_ke_ying.dart';
import 'package:qimendunjia/model/ten_gan_ke_ying_ge_ju.dart';
import 'package:qimendunjia/utils/constant_ui_resources_of_qi_men.dart';
import 'package:qimendunjia/widgets/ten_gan_ke_ying_yin_zhang.dart';
import 'package:qimendunjia/widgets/resizable_gong_widget.dart';

import '../widgets/tmp.dart';

class RootPage extends StatefulWidget {
  double defaultEachGongWidth = 256;
  RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> with TickerProviderStateMixin,WidgetsBindingObserver {
  final datetimeNotifier = ValueNotifier<DateTime?>(null);

  late AnimationController fontAnimationController;
  late Animation<double> fontAnimation;
  late Tween<double> fontTween;

  GlobalKey rootPageGlobalKey = GlobalKey();
  late final ValueNotifier<double> eachGongCardWidthNotifier;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Duration duration = Duration(milliseconds: 80);
    // duration = Duration.zero;
    fontAnimationController = AnimationController(vsync: this,
        upperBound: 48,
        lowerBound: 24,
        duration:duration,reverseDuration: duration);
    fontAnimationController.value = nineStarBoxSizeNotifier.value.width;
    fontTween = Tween<double>(begin: 0, end: 1);
    fontAnimation = fontTween.animate(fontAnimationController);


    eachGongCardWidthNotifier = ValueNotifier(widget.defaultEachGongWidth);

    WidgetsBinding.instance.addObserver(this);
  }
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    Size windowsSize = MediaQuery.of(context).size;
    double finalSize = windowsSize.width < windowsSize.height?windowsSize.width:windowsSize.height;

    eachGongCardWidthNotifier.value =  finalSize / 3 - 4*4;
    print("metrics changed eachGong width ${eachGongCardWidthNotifier.value}");
  }
  ValueNotifier<bool> showAppBarNotifier = ValueNotifier(true);
  ValueNotifier<double> widthNotifier = ValueNotifier(256);
  ValueNotifier<double> slideWidthNotifier= ValueNotifier(54);
  ValueNotifier<bool> isHorNotifier= ValueNotifier(true);
  ValueNotifier<Size> nineStarBoxSizeNotifier = ValueNotifier(Size(48, 24));
  ValueNotifier<bool> showHintNotifier = ValueNotifier(true);
  ValueNotifier<bool> showTextHintNotifier = ValueNotifier(true);
  ValueNotifier<bool> isZhiShiDoor = ValueNotifier(true);

  ValueNotifier<double> cardPaddingSizeNotifier = ValueNotifier(24);
  ValueNotifier<double> fontSizeNotifier = ValueNotifier(36);

  double MAX_CARD_EACH_GONG_WIDTH = 0; // max card width
  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);


    nineStarBoxSizeNotifier.dispose();
    showHintNotifier.dispose();
    showTextHintNotifier.dispose();


    eachGongCardWidthNotifier.dispose();
    cardPaddingSizeNotifier.dispose();
    fontSizeNotifier.dispose();


    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   appBar: AppBar(title: Text('Responsive Example')),
    //   body: LayoutBuilder(
    //     builder: (BuildContext context, BoxConstraints constraints) {
    //       // 这里你可以根据 constraints 来判断屏幕尺寸或方向
    //       // 并根据这些信息来构建你的 Widget
    //       print('新的屏幕尺寸: ${constraints.maxWidth}x${constraints.maxHeight}');
    //       return Center(
    //         child: Text('新的屏幕尺寸: ${constraints.maxWidth}x${constraints.maxHeight}'),
    //       );
    //     },
    //   ),
    // );
    // double cardWidth = 256;
    // double carHeight = 256;
    if (MAX_CARD_EACH_GONG_WIDTH == 0){
      // 初始化 init
      Size size = MediaQuery.of(context).size;
      double finalSize = size.width < size.height?size.width:size.height;
      MAX_CARD_EACH_GONG_WIDTH = finalSize / 3; // 4*4 为间距
    }
    if (eachGongCardWidthNotifier.value == widget.defaultEachGongWidth){
      eachGongCardWidthNotifier.value = MAX_CARD_EACH_GONG_WIDTH;
    }
    return Scaffold(
      // appBar: ValueListenableBuilder<bool>(
      //     valueListenable: showAppBarNotifier,
      //     builder: builder
      // )
      appBar: MediaQuery.of(context).orientation == Orientation.portrait?AppBar(
        key: rootPageGlobalKey,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Main'),
      ):null,
      // body: ConstrainedBox(
      //   constraints: BoxConstraints(
      //     maxHeight: MediaQuery.of(context).size.height,
      //     maxWidth: MediaQuery.of(context).size.width,
      //   ),
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          // width: MediaQuery.of(context).size.width,
          // height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // WillowBranchAnimation(),
                // geJuTag(),

                Container(
                  padding: EdgeInsets.all(12),
                  width: 226+24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color:Color.fromRGBO(255,251,240, 1),
                    boxShadow: [
                      BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      )
                    ]
                  ),
                  child: FourZhuEightChar(
                    year: JiaZi.JIA_CHEN,
                    month: JiaZi.GUI_YOU,
                    day: JiaZi.XIN_CHOU,
                    chen: JiaZi.BING_SHEN,
                    isColorful: true,
                    zodiacGanColors: ConstResourcesMapper.zodiacGanColors,
                    zodiacZhiColors: ConstResourcesMapper.zodiacZhiColors,
                  ),
                ),
                SizedBox(height: 12,),
                buildCenterPanTime(),

                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("text box width"),
                      SizedBox(
                        width: 512,
                        child: ValueListenableBuilder(
                            valueListenable: fontSizeNotifier,
                            builder: (ctx,fontSize,_){
                              return Slider(
                                value: fontSize,
                                max: 64,
                                min: 24,
                                divisions: 20,
                                label: fontSize.toString(),
                                onChanged: (double value) {
                                  fontSizeNotifier.value = value;
                                },
                              );
                            }),
                      ),
                      ValueListenableBuilder(
                          valueListenable: fontSizeNotifier,
                          builder: (ctx,double,_){
                            return Text(double.toStringAsFixed(2));
                          })
                    ]),
                SizedBox(height: 32,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 12,),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        // SizedBox(height: 24,),
                        // ValueListenableBuilder(
                        //     valueListenable: cardWidthNotifier,
                        //     builder: (ctx,width,_){
                        //       return _gong(width);
                        //     }),
                        SizedBox(height: 16,),
                        ValueListenableBuilder(
                            valueListenable: eachGongCardWidthNotifier,
                            builder: (ctx,width,_){
                              return Row(
                                children: [
                                  SizedBox(
                                    width: 360,
                                    child: Slider(
                                        value: width,
                                        min: 64,
                                        max: 480,
                                        divisions: 20,
                                        label: width.round().toString(),
                                        onChanged:(value)=>eachGongCardWidthNotifier.value = value),
                                  ),
                                  SizedBox(width: 10,),
                                  Text(width.toStringAsFixed(2))
                                ],
                              );
                            }),
                        SizedBox(height: 16,),
                        ValueListenableBuilder(
                            valueListenable: isHorNotifier,
                            builder: (ctx,isHor,_) {
                              return Switch(
                                  value: isHor,
                                  onChanged: (bool value) {
                                    setState(() {
                                      isHorNotifier.value = value;
                                    });
                                  });
                            }),
                      ],
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("card side width"),
                      SizedBox(
                        width: 512,
                        child: ValueListenableBuilder(
                            valueListenable: cardPaddingSizeNotifier,
                            builder: (ctx,padding,_){
                              return Slider(
                                value: padding,
                                max: 64,
                                min: 0,
                                divisions: 16,
                                label: cardPaddingSizeNotifier.value.round().toString(),
                                onChanged: (double value) {
                                  cardPaddingSizeNotifier.value = value;
                                },
                              );
                            }),
                      ),
                      ValueListenableBuilder(
                          valueListenable: cardPaddingSizeNotifier,
                          builder: (ctx,padding,_){
                            return Text("${padding.round()}");
                          }),
                    ],
                ),
                SizedBox(
                width: 128,
                child: ValueListenableBuilder(
                    valueListenable: nineStarBoxSizeNotifier,
                    builder: (ctx,size,_){
                      return Slider(
                        value: size.height,
                        max: 48,
                        min: 12,
                        // divisions: 6,
                        label: nineStarBoxSizeNotifier.value.height.round().toString(),
                        onChanged: (double value) {
                          nineStarBoxSizeNotifier.value = Size(size.width, value);
                          // fontAnimationController.animateTo(value);
                        },
                      );
                    }),
              ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("字体框大小"),
                      SizedBox(
                        width: 256,
                        child: ValueListenableBuilder(
                            valueListenable: slideWidthNotifier,
                            builder: (ctx,size,_){
                              return Slider(
                                value: slideWidthNotifier.value,
                                max: 54,
                                min: 24,
                                // divisions: 6,
                                label: slideWidthNotifier.value.round().toString(),
                                onChanged: (double value) {
                                  slideWidthNotifier.value = value;
                                  // fontAnimationController.animateTo(value);
                                },
                              );
                            }),
                      ),
                    ]),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ValueListenableBuilder(
                        valueListenable: showHintNotifier,
                        builder: (ctx,showHint,_) {
                          return Switch(
                              value: showHint,
                              onChanged: (bool value) {
                                setState(() {
                                  showHintNotifier.value = value;
                                });
                              });
                        }),
                    SizedBox(width: 32,),
                    ValueListenableBuilder(
                        valueListenable: showTextHintNotifier,
                        builder: (ctx,showHint,_) {
                          return Switch(
                              value: showHint,
                              onChanged: (bool value) {
                                setState(() {
                                  showTextHintNotifier.value = value;
                                });
                              });
                        }),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        onPressed: (){
                          widthNotifier.value = widthNotifier.value + 12;
                        },
                        child: Text("+")),
                    SizedBox(width: 12,),
                    ElevatedButton(
                        onPressed: (){
                          widthNotifier.value = widthNotifier.value! - 12;
                        },
                        child: Text("-")),
                  ],
                ),
                Card(
                  child: InkWell(
                    onTap: (){
                      Navigator.pushNamed(context, '/qimendunjia');
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: 160,
                      height: 64,
                      child: Text("奇门遁甲",style: ConstantUiResourcesOfQiMen.nineGongNameTextStyle.copyWith(fontSize: 28,color: Colors.blueGrey),),
                    )
                  ),
                ),
                SizedBox(height: 18,),
                Card(
                  child: InkWell(
                      onTap: (){
                        Navigator.pushNamed(context, '/daliuren');
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: 160,
                        height: 64,
                        child: Text("大六壬",style: ConstantUiResourcesOfQiMen.nineGongNameTextStyle.copyWith(fontSize: 28,color: Colors.blueGrey),),
                      )
                  ),
                ),
                SizedBox(height: 18,),
                ElevatedButton(
                    onPressed: ()=>Navigator.pushNamed(context, '/qizhengsiyu'),
                    child: Text("七政四余")),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _eachGong(bool withSelectedCircle,double width){
    return Stack(
        alignment: Alignment.center,
        children: [
          // glass type container
          Container(
            width: width,
            height: width,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 5,
                    blurRadius: 5,
                  )
                ]
            ),
          ),
          // SizedBox(
          //     width: width,
          //     height: width,
          //     child: ColorFiltered(
          //         colorFilter: ColorFilter.mode(Color.fromRGBO(176, 31, 36, .8), BlendMode.srcIn),
          //         child: Image.asset("assets/icons/yin_zhang.png",)
          //     )
          // ),
          // Container(
          //   width: width,
          //   height: width,
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //     crossAxisAlignment: CrossAxisAlignment.center,
          //     children: [
          //       Column(
          //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //         crossAxisAlignment: CrossAxisAlignment.center,
          //         children: [
          //           Text("朱",style: TextStyle(fontSize: width * .3,color: Colors.white),),
          //           Text("雀",style: TextStyle(fontSize: width * .3,color: Colors.white))
          //         ],
          //       ),
          //
          //       Column(
          //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //         crossAxisAlignment: CrossAxisAlignment.center,
          //         children: [
          //           Text("投",style: TextStyle(fontSize: width * .3,color: Colors.white)),
          //           Text("江",style: TextStyle(fontSize: width * .3,color: Colors.white))
          //         ],
          //       )
          //     ],
          //   ),
          // ),
          // Container(
          //   width: width,
          //   height: width,
          //   decoration: BoxDecoration(
          //       color: Colors.blue.withOpacity(.2),
          //       borderRadius: BorderRadius.circular(24),
          //   ),
          // ),

          // ClipRRect(
          //   borderRadius: BorderRadius.circular(24),
          //   child: BackdropFilter(
          //     filter: ImageFilter.blur(sigmaX: 4,sigmaY: 4),
          //     child:Container(
          //       color: Colors.white.withOpacity(.5),
          //       width: width,
          //       height: width,
          //     ),
          //   ),
          // ),
          // SizedBox(
          //   width: 240,
          //   height: 240,
          //   child: Image.asset("assets/icons/beautiful_selected_circle.jpeg",),
          // ),

          // FutureBuilder(
          //   future: precacheImage(AssetImage('assets/gifs/beautiful_selected_circle_hehua.png'), context),
          //   builder: (context, snapshot) {
          //     if (snapshot.connectionState == ConnectionState.done) {
          //       // 图片加载完成后执行的操作
          //       return SizedBox(
          //         width: width,
          //         height: width,
          //         child: Image.asset("assets/gifs/beautiful_selected_circle_hehua.gif",),
          //       )
          //           .animate(autoPlay: true)
          //           .fadeIn(begin:.4,curve: Curves.ease,duration: Duration(milliseconds: 800))
          //           .scale(begin: Offset.zero,end: Offset(1, 1),curve: Curves.ease,duration: Duration(milliseconds: 800));
          //     } else {
          //       // 加载中显示的内容
          //       return Container();
          //     }
          //   },
          // ),
          // SizedBox(
          //   width: width,
          //   height: width,
          //   child: Image.asset("assets/gifs/beautiful_selected_circle_hehua.gif",),
          // ),
          if (withSelectedCircle)
            FutureBuilder(
              future: precacheImage(AssetImage('assets/gifs/beautiful_selected_circle_hehua.png'), context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // 图片加载完成后执行的操作
                  return SizedBox(
                    width: width,
                    height: width,
                    child: Image.asset("assets/gifs/beautiful_selected_circle_hehua.gif",),
                  )
                      .animate(autoPlay: true)
                      .fadeIn(begin:.4,curve: Curves.ease,duration: Duration(milliseconds: 800))
                      .scale(begin: Offset.zero,end: Offset(1, 1),curve: Curves.ease,duration: Duration(milliseconds: 800));
                } else {
                  // 加载中显示的内容
                  return Container();
                }
              },
            ),

          if (withSelectedCircle)
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 1,sigmaY: 1),
                child:Container(
                  width: width,
                  height: width,
                  color: Colors.white.withOpacity(.1),
                ),
              ),
            ),
          // ValueListenableBuilder(
          //     valueListenable: showHintNotifier,
          //     builder: (ctx,showHint,_){
          //       print("showHint $showHint");
          //       return ResizableGongWidget(
          //         cardSize:width,
          //         withAnGan:true,
          //         withYinGan:true,
          //         showHint:showHint,
          //         isZhiFuStar:true,
          //         isJiStarZhiFu:true,
          //       );
          //     }),

        ]
    );
  }

  Widget _gong(double cardSize,bool showHint,bool withYinGan,bool withAnGan){

    bool displayGeJu = false;
    bool displayTenGanKeYing = false;
    return ValueListenableBuilder(
      valueListenable: cardPaddingSizeNotifier,
      builder: (context,paddingSize,_) {
        // double paddingSideWidth = paddingSize;
        double paddingSideWidth = cardSize * .08;
        if (paddingSideWidth < 12){
          paddingSideWidth = 0;
        }
        double centerWidth = cardSize - paddingSideWidth * 2;
        double centerBoxWidth =  (cardSize * 0.4) * .7;
        double centerSideWidth = (cardSize * 0.4) * .25 * 1.6;



        double fontSize = (cardSize * 0.4) * .3;
        if (fontSize < 16){
          fontSize = 16;
        }
        double yinAnGanfontSize = fontSize * .8;
        // double yinAnGanHintFontSize = yinAnGanfontSize *.5;
        double hintFontSize = yinAnGanfontSize * .5;
        double yinAnGanHintFontSize = hintFontSize;

        Duration duration = Duration(milliseconds: 400);
        return AnimatedContainer(
          duration: Duration.zero,
          width: cardSize,
          height: cardSize,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
          ),
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: paddingSideWidth,
                    height: cardSize,
                    // color: Colors.blue.withOpacity(.2),
                    alignment: Alignment.centerRight,
                    // margin: EdgeInsets.symmetric(vertical: paddingSideWidth),
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 200),
                      child: paddingSideWidth < 10 ?Container():AutoSizeText(
                        "卯",
                        style: ConstantUiResourcesOfQiMen.twelveDiZhiTextStyle.copyWith(fontSize: paddingSideWidth),
                        minFontSize: 10,
                        maxFontSize: 32,
                      ),
                    ),
                  ),
                  Container(
                    // color: Colors.orange.withOpacity(.1),
                    // width: centerBoxWidth + centerSideWidth * 2,
                    // width: isHor?centerWidth:centerWidth+yinAnGanfontSize+yinAnGanHintFontSize,
                    width: centerWidth,
                    height: cardSize,
                    // color: Colors.yellow.withOpacity(.1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: centerWidth,
                          height: paddingSideWidth,
                          // color: Colors.red.withOpacity(.1),
                          alignment: Alignment.bottomCenter,
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 200),
                            child: paddingSideWidth < 10 ?Container():AutoSizeText(
                              "午",
                              style: ConstantUiResourcesOfQiMen.twelveDiZhiTextStyle.copyWith(fontSize: paddingSideWidth),
                              minFontSize: 10,
                              maxFontSize: 32,
                            ),
                          ),
                        ),
                        Container(
                          // color: Colors.orange.withOpacity(.1),
                          // width: centerWidth,
                          // height: centerWidth,
                          // height: cardSize - paddingSideWidth * 2,
                          child: ValueListenableBuilder(
                              valueListenable: isHorNotifier,
                              builder: (ctx,isHorOld,_){
                                bool isHor = (centerBoxWidth + centerSideWidth *2) <= 120;
                                // print("${(centerBoxWidth + centerSideWidth *2)} --- $isHor");
                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Positioned(
                                    //   left: 0,
                                    //   child:
                                    // ),
                                    Container(
                                      // width: centerBoxWidth + centerSideWidth *2,
                                      // height: centerBoxWidth + centerSideWidth *2 + fontSize * .6,
                                      // color: Colors.black54.withOpacity(.1),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          AnimatedContainer(
                                            duration: Duration(milliseconds: 400),
                                            // height: isHor?centerWidth * .6:,
                                            // color: Colors.green.withOpacity(.1),
                                            width: isHor?centerSideWidth:yinAnGanfontSize,
                                            alignment: isHor?Alignment.center:Alignment.centerLeft,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                yinAnGan(
                                                    TianGan.DING,
                                                    "天暗",
                                                    TwelveZhangSheng.DI_WANG,
                                                    TwelveZhangSheng.SI,
                                                    yinAnGanfontSize,
                                                    yinAnGanHintFontSize,
                                                    isHor,
                                                    showHint,
                                                    duration),
                                                yinAnGan(
                                                    TianGan.XIN,
                                                    "隐干",
                                                    TwelveZhangSheng.LIN_GUAN,
                                                    TwelveZhangSheng.MU,
                                                    yinAnGanfontSize,
                                                    yinAnGanHintFontSize,
                                                    isHor,
                                                    showHint,
                                                    duration),
                                                yinAnGan(
                                                    TianGan.BING,
                                                    "人暗",
                                                    TwelveZhangSheng.LIN_GUAN,
                                                    TwelveZhangSheng.LIN_GUAN,
                                                    yinAnGanfontSize,
                                                    yinAnGanHintFontSize,
                                                    isHor,
                                                    showHint,
                                                    duration),
                                              ],
                                            ),
                                          ),
                                          AnimatedContainer(
                                            duration: duration,
                                            // height: centerWidth,
                                            // height: centerBoxWidth + centerSideWidth *2 + fontSize * .6,
                                            // width: isHor?centerBoxWidth:centerBoxWidth+yinAnGanfontSize,
                                            // width: isHor?centerBoxWidth+fontSize:centerBoxWidth+fontSize,
                                            width: fontSize * 3,
                                            alignment: Alignment.centerLeft,
                                            // color: Colors.red.withOpacity(.9),
                                            // margin: EdgeInsets.only(left: isHor?centerSideWidth:yinAnGanfontSize),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  // width: centerBoxWidth+fontSize,
                                                  width: fontSize * 3,
                                                  alignment: Alignment.center,
                                                  // color:Colors.blue.withOpacity(.2),
                                                  child: _gods("值符",fontSize* 2,fontSize * .75 * .5,showHint: showHint),
                                                ),
                                                Container(
                                                    // width: centerBoxWidth+fontSize,
                                                    width: fontSize * 3,
                                                    // color: Colors.blue.withOpacity(.1),
                                                    child: _stars("天芮",fontSize* 2,fontSize * .5,true, isHor,showHint: showHint)
                                                ),
                                                Container(
                                                    // width: centerBoxWidth+fontSize,
                                                    width: fontSize * 3,
                                                    alignment: Alignment.center,
                                                  // color: Colors.blue.withOpacity(.1),
                                                  child: Column(
                                                    children: [
                                                      // _doors("休门",fontSize* 2,fontSize * .5,showHint: showHint),
                                                      _doors("休门",fontSize* 2,fontSize * .75 * .5,showHint: showHint),
                                                      Text("值符",style: ConstantUiResourcesOfQiMen
                                                          .nineStarTextStyle.copyWith(
                                                          fontSize: fontSize*.6,color: Colors.grey.withOpacity(.8)))
                                                    ],
                                                  )
                                                )
                                              ],
                                            ),
                                          ),
                                          Container(
                                          // AnimatedContainer(
                                          //   duration: duration,
                                          //   color: Colors.green.withOpacity(.1),
                                            // height: isHor?centerWidth * .5:centerWidth,
                                            // width: centerSideWidth,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                tianDiPanGanMarked(TianGan.DING,TwelveZhangSheng.BING,TwelveZhangSheng.DI_WANG,fontSize,hintFontSize,showHint,TianGan.DING,TwelveZhangSheng.BING,TwelveZhangSheng.DI_WANG),
                                                SizedBox(height: 4,),
                                                tianDiPanGanMarked(TianGan.GENG,TwelveZhangSheng.BING,TwelveZhangSheng.DI_WANG,fontSize,hintFontSize,showHint,TianGan.DING,TwelveZhangSheng.BING,TwelveZhangSheng.DI_WANG,isTianPan: false),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }),
                        ),
                        Container(
                          width: centerWidth,
                          height: paddingSideWidth,
                          // color: Colors.orange.withOpacity(.1),
                          alignment: Alignment.topCenter,
                          child:AnimatedSwitcher(
                            duration: Duration(milliseconds: 200),
                            child: paddingSideWidth < 10 ?Container():AutoSizeText(
                              "子",
                              style: ConstantUiResourcesOfQiMen.twelveDiZhiTextStyle.copyWith(fontSize: paddingSideWidth),
                              minFontSize: 10,
                              maxFontSize: 32,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: paddingSideWidth,
                    height: cardSize,
                    // color: Colors.blue.withOpacity(.2),
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.symmetric(vertical: paddingSize),
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 200),
                      child: paddingSideWidth < 10 ?Container():AutoSizeText(
                        "酉",
                        style: ConstantUiResourcesOfQiMen.twelveDiZhiTextStyle.copyWith(fontSize: paddingSideWidth),
                        minFontSize: 10,
                        maxFontSize: 32,
                      ),
                    ),
                  ),
                ],
              ),

              if (displayTenGanKeYing)
                AnimatedPositioned(
                  left: paddingSideWidth * .5,
                  top: paddingSideWidth* .5,
                  duration:Duration(milliseconds: 200),
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/icons/yin_zhang.png"),
                            colorFilter: ColorFilter.mode(Color.fromRGBO(176, 31, 36, .8), BlendMode.srcIn),
                            fit: BoxFit.cover
                        )
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Text("朱",style: TextStyle(fontSize: 52 * .3,color: Colors.white),),
                            Text("朱",style: ConstantUiResourcesOfQiMen.eightSkyDoorTextStyle.copyWith(fontSize: 52 * .3,color: Colors.white)),
                            Text("雀",style: ConstantUiResourcesOfQiMen.eightSkyDoorTextStyle.copyWith(fontSize: 52 * .3,color: Colors.white)),
                            // Text("雀",style: TextStyle(fontSize: 52 * .3,color: Colors.white))
                          ],
                        ),

                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Text("投",style: TextStyle(fontSize: 52 * .3,color: Colors.white)),
                            // Text("江",style: TextStyle(fontSize: 52 * .3,color: Colors.white))
                            Text("投",style: ConstantUiResourcesOfQiMen.eightSkyDoorTextStyle.copyWith(fontSize: 52 * .3,color: Colors.white)),
                            Text("江",style: ConstantUiResourcesOfQiMen.eightSkyDoorTextStyle.copyWith(fontSize: 52 * .3,color: Colors.white)),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              if (displayTenGanKeYing)
                AnimatedPositioned(
                  left: paddingSideWidth * .5,
                  top: paddingSideWidth* .5,
                  duration:Duration(milliseconds: 200),
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/icons/yin_zhang.png"),
                            colorFilter: ColorFilter.mode(Color.fromRGBO(176, 31, 36, .8), BlendMode.srcIn),
                            fit: BoxFit.cover
                        )
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Text("朱",style: TextStyle(fontSize: 52 * .3,color: Colors.white),),
                            Text("朱",style: ConstantUiResourcesOfQiMen.eightSkyDoorTextStyle.copyWith(fontSize: 52 * .3,color: Colors.white)),
                            Text("雀",style: ConstantUiResourcesOfQiMen.eightSkyDoorTextStyle.copyWith(fontSize: 52 * .3,color: Colors.white)),
                            // Text("雀",style: TextStyle(fontSize: 52 * .3,color: Colors.white))
                          ],
                        ),

                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Text("投",style: TextStyle(fontSize: 52 * .3,color: Colors.white)),
                            // Text("江",style: TextStyle(fontSize: 52 * .3,color: Colors.white))
                            Text("投",style: ConstantUiResourcesOfQiMen.eightSkyDoorTextStyle.copyWith(fontSize: 52 * .3,color: Colors.white)),
                            Text("江",style: ConstantUiResourcesOfQiMen.eightSkyDoorTextStyle.copyWith(fontSize: 52 * .3,color: Colors.white)),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              if (displayGeJu)
                AnimatedPositioned(
                  // left: paddingSideWidth * .5,
                  // bottom: paddingSideWidth* .5,
                    bottom: paddingSideWidth * .5,
                    left: 0,
                    duration:Duration(milliseconds: 200),
                    child: Transform.scale(
                        scale:1,
                        // child: Container(
                        // color: Colors.redAccent,
                        child: ge_ju_template_small("天运昌气",Color.fromRGBO(59,78,61, 1),Color.fromRGBO(240, 167, 46, 1)))
                  // ),
                ),
              if (displayGeJu)
                AnimatedPositioned(
                  // left: paddingSideWidth * .5,
                  // bottom: paddingSideWidth* .5,
                    bottom: paddingSideWidth * .5,
                    right: 0,
                    duration:Duration(milliseconds: 200),
                    child: Transform.scale(
                        scale:1,
                        // child: Container(
                        // color: Colors.redAccent,
                        child: ge_ju_template_small("天辅吉时",Color.fromRGBO(25, 44, 59, 1),Color.fromRGBO(176, 132, 88,1)))
                  // ),
                )
            ],
          ),
        );
      }
    );
  }
  Widget tianDiPanGanMarked(
      TianGan gan,
      TwelveZhangSheng monthly,
      TwelveZhangSheng gong,
      double fontSize,
      double hintFontSize,
      bool showHint,
      TianGan? jiGan,
      TwelveZhangSheng? jiGanMonthly,
      TwelveZhangSheng? jiGanGong,{bool isTianPan = true}){
    double jiFontSize = fontSize*.64;
    if (fontSize == 16){
      jiFontSize = 16;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: isTianPan?CrossAxisAlignment.start:CrossAxisAlignment.end,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 400),
              // height:showHint?hintFontSize:0,
              height:hintFontSize,
              alignment: Alignment.bottomCenter,
              child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: const Offset(0, 0),
                      ).animate(animation),
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child:showHint?AutoSizeText(
                    monthly.name,
                    style: TextStyle(color: Colors.red,fontWeight: FontWeight.w300,height: 1),
                    minFontSize : 8,
                    maxFontSize : 24,
                  ):Container()
              ),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width:fontSize * .8,
                  height: fontSize * .8,
                  child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                          Colors.blueGrey,
                          BlendMode.srcIn),
                      child: Image.asset("assets/icons/red-ink-circle.png")
                    // child: Image.asset("assets/icons/thin-black-ink-circle.png")
                      // child: Image.asset("assets/icons/jia_dun_jia.png")
                  ),
                ),
                SizedBox(
                  width:fontSize,
                  height: fontSize,
                  child: RotatedBox(
                    quarterTurns: 0,
                    child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                            Colors.blueGrey,
                            BlendMode.srcIn),
                        // child: Image.asset("assets/icons/thin-black-ink-circle.png")
                        child: Image.asset("assets/icons/mu.png")
                    ),
                  ),
                ),
                // SizedBox(
                //   width:fontSize *.7,
                //   height: fontSize * .7,
                //   child: ColorFiltered(
                //       colorFilter: ColorFilter.mode(
                //           Colors.blueGrey,
                //           BlendMode.srcIn),
                //       // child: Image.asset("assets/icons/thin-black-ink-circle.png")
                //       child: Image.asset("assets/icons/jia_ru_mu.png")
                //   ),
                // ),
                SizedBox(
                  width:fontSize,
                  height: fontSize,
                  child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                          Colors.blueGrey,
                          BlendMode.srcIn),
                      child: Image.asset("assets/icons/ji_xing.png")),
                ),
                Text(
                    gan.name,
                    style: ConstantUiResourcesOfQiMen.tianGanTextStyle.copyWith(
                        fontSize: fontSize,
                        color: ConstResourcesMapper.zodiacGanColors[gan],
                        shadows: [
                          Shadow(color: ConstResourcesMapper.zodiacGanColors[gan]!.withOpacity(.4), offset: Offset(1, 1), blurRadius: 2),
                          Shadow(color: Colors.white.withOpacity(.2), offset: Offset(1, -1), blurRadius: 2),
                        ]
                    )
                ),
              ],
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 400),
              // height:showHint?hintSize:0,
              height:hintFontSize,
              alignment: Alignment.topCenter,
              // color: Colors.red.withOpacity(.1),
              child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -1),
                        end: const Offset(0, 0),
                      ).animate(animation),
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child:showHint?AutoSizeText(
                    gong.name,
                    style: TextStyle(color: Colors.grey,fontWeight: FontWeight.w300,height: 1),
                    minFontSize : 8,
                    maxFontSize : 24,
                  ):Container()
              ),
            ),
          ],
        ),
        jiGan!=null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 400),
              // height:showHint?hintFontSize:0,
              height:hintFontSize,
              alignment: Alignment.bottomCenter,
              child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: const Offset(0, 0),
                      ).animate(animation),
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child:showHint?AutoSizeText(
                    jiGanMonthly!.name,
                    style: TextStyle(color: Colors.red,fontWeight: FontWeight.w300,height: 1),
                    minFontSize : 8,
                    maxFontSize : 24,
                  ):Container()
              ),
            ),
            Stack(
              children: [
                SizedBox(
                  width:jiFontSize * .8,
                  height: jiFontSize * .8,
                  child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                          Colors.blueGrey,
                          BlendMode.srcIn),
                      child: Image.asset("assets/icons/red-ink-circle.png")
                    // child: Image.asset("assets/icons/thin-black-ink-circle.png")
                    // child: Image.asset("assets/icons/jia_dun_jia.png")
                  ),
                ),
                SizedBox(
                  width:jiFontSize,
                  height: jiFontSize,
                  child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                          Colors.blueGrey,
                          BlendMode.srcIn),
                      // child: Image.asset("assets/icons/thin-black-ink-circle.png")
                      child: Image.asset("assets/icons/mu.png")
                  ),
                ),
                // SizedBox(
                //   width:fontSize *.7,
                //   height: fontSize * .7,
                //   child: ColorFiltered(
                //       colorFilter: ColorFilter.mode(
                //           Colors.blueGrey,
                //           BlendMode.srcIn),
                //       // child: Image.asset("assets/icons/thin-black-ink-circle.png")
                //       child: Image.asset("assets/icons/jia_ru_mu.png")
                //   ),
                // ),
                SizedBox(
                  width:jiFontSize,
                  height: jiFontSize,
                  child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                          Colors.blueGrey,
                          BlendMode.srcIn),
                      child: Image.asset("assets/icons/ji_xing.png")),
                ),

                Text(
                    jiGan.name,
                    style: ConstantUiResourcesOfQiMen.tianGanTextStyle.copyWith(fontSize: jiFontSize,color: ConstResourcesMapper.zodiacGanColors[jiGan])
                ),
              ],
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 400),
              // height:showHint?hintSize:0,
              // height:hintFontSize,
              height:hintFontSize,
              alignment: Alignment.topCenter,
              // color: Colors.red.withOpacity(.1),
              child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -1),
                        end: const Offset(0, 0),
                      ).animate(animation),
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child:showHint?AutoSizeText(
                    jiGanGong!.name,
                    style: TextStyle(color: Colors.grey,fontWeight: FontWeight.w300,height: 1),
                    minFontSize : 8,
                    maxFontSize : 24,
                  ):Container()
              ),
            ),
          ],
        )
            : SizedBox(width: fontSize*.6,)
      ],
    );
  }

  Widget tianDiPanGan(TianGan gan,TwelveZhangSheng monthly,TwelveZhangSheng gong,double fontSize,double hintFontSize,bool showHint,TianGan? jiGan,TwelveZhangSheng? jiGanMonthly,TwelveZhangSheng? jiGanGong){
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 400),
              // height:showHint?hintFontSize:0,
              height:hintFontSize,
              alignment: Alignment.bottomCenter,
              child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: const Offset(0, 0),
                      ).animate(animation),
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child:showHint?AutoSizeText(
                    monthly.name,
                    style: TextStyle(color: Colors.red,fontWeight: FontWeight.w300,height: 1),
                    minFontSize : 8,
                    maxFontSize : 24,
                  ):Container()
              ),
            ),
            Text(
                gan.name,
                style: ConstantUiResourcesOfQiMen.tianGanTextStyle.copyWith(fontSize: fontSize,color: ConstResourcesMapper.zodiacGanColors[gan])
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 400),
              // height:showHint?hintSize:0,
              height:hintFontSize,
              alignment: Alignment.topCenter,
              // color: Colors.red.withOpacity(.1),
              child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -1),
                        end: const Offset(0, 0),
                      ).animate(animation),
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child:showHint?AutoSizeText(
                    gong.name,
                    style: TextStyle(color: Colors.grey,fontWeight: FontWeight.w300,height: 1),
                    minFontSize : 8,
                    maxFontSize : 24,
                  ):Container()
              ),
            ),
          ],
        ),
        jiGan!=null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 400),
              // height:showHint?hintFontSize:0,
              height:hintFontSize,
              alignment: Alignment.bottomCenter,
              child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: const Offset(0, 0),
                      ).animate(animation),
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child:showHint?AutoSizeText(
                    jiGanMonthly!.name,
                    style: TextStyle(color: Colors.red,fontWeight: FontWeight.w300,height: 1),
                    minFontSize : 8,
                    maxFontSize : 24,
                  ):Container()
              ),
            ),
            Text(
                jiGan.name,
                style: ConstantUiResourcesOfQiMen.tianGanTextStyle.copyWith(fontSize: fontSize*.6,color: ConstResourcesMapper.zodiacGanColors[jiGan])
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 400),
              // height:showHint?hintSize:0,
              // height:hintFontSize,
              height:hintFontSize,
              alignment: Alignment.topCenter,
              // color: Colors.red.withOpacity(.1),
              child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -1),
                        end: const Offset(0, 0),
                      ).animate(animation),
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child:showHint?AutoSizeText(
                    jiGanGong!.name,
                    style: TextStyle(color: Colors.grey,fontWeight: FontWeight.w300,height: 1),
                    minFontSize : 8,
                    maxFontSize : 24,
                  ):Container()
              ),
            ),
          ],
        )
            : SizedBox(width: fontSize*.6,)
      ],
    );
  }
  Widget yinAnGan(
      TianGan tian,
      String yinAnGan,
      TwelveZhangSheng monthly,
      TwelveZhangSheng gong,
      double yinAnGanfontSize,
      double yinAnGanHintSize,
      bool isHor,
      bool showHint,
      Duration duration){
    double tagTextFontSize = yinAnGanHintSize * .8;
    double yinAnGanHintFontSize = yinAnGanHintSize;
    if (yinAnGanHintFontSize > 12){
      yinAnGanHintFontSize = 12;
    }else if (yinAnGanHintFontSize < 9){
      yinAnGanHintFontSize = 9;
    }
    double tianGanSize = yinAnGanfontSize;
    return Container(
      width:tianGanSize,
      height: yinAnGanfontSize+yinAnGanHintFontSize*2 + 1,
      // color: Colors.red,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: duration,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: const Offset(0, 0),
                ).animate(animation),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child:showHint?Text(
              isHor?monthly.name.split("").last:monthly.name,
              // monthly.name,
              style: TextStyle(color: Colors.black45,fontSize: yinAnGanHintFontSize,fontWeight: FontWeight.w300,height: 1),
              maxLines: 1,
            ):SizedBox(height: yinAnGanHintFontSize,)
          ),
          Text(
              tian.name,
              style: ConstantUiResourcesOfQiMen.tianGanTextStyle.copyWith(
                  fontSize: tianGanSize,
                  shadows: [
                    Shadow(color: Colors.black12,offset: Offset(1, 1), blurRadius: 2),
                  ])
          ),
          AnimatedSwitcher(
              duration: duration,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -1),
                    end: const Offset(0, 0),
                  ).animate(animation),
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child:showHint?Text(
                isHor?gong.name.split("").last:gong.name,
                // gong.name,
                style: TextStyle(color: Colors.black45,fontSize: yinAnGanHintFontSize,fontWeight: FontWeight.w300,height: 1),
                maxLines: 1,
              ):SizedBox(height: yinAnGanHintFontSize,)
          )
        ],
      ),
    );
    return Stack(
      children: [
        AnimatedPositioned(
          duration: duration,
          left: 0,
          child: AnimatedContainer(
              duration: duration,
              width:yinAnGanfontSize,
              height: yinAnGanfontSize+yinAnGanHintFontSize*2,
              alignment: Alignment.center,
              // width:isHor?yinAnGanHintFontSize:yinAnGanfontSize,
              // height: isHor?yinAnGanfontSize:yinAnGanfontSize+yinAnGanHintFontSize*2,
              // alignment: isHor?Alignment.centerRight:Alignment.center,
              color: Colors.purple.withOpacity(.1),
              child:zhangShengText(
                  // isHor?yinAnGanfontSize:yinAnGanfontSize+yinAnGanHintFontSize*2,
                  // isHor?yinAnGanHintFontSize:yinAnGanfontSize,
                 // yinAnGanfontSize+yinAnGanHintFontSize*2,
                 //  yinAnGanfontSize,
                  yinAnGanHintFontSize,
                  monthly,
                  gong,
                  isHor,
                  showHint,
                  duration
              )
          ),
        ),
        AnimatedContainer(
          duration: duration,
          width:isHor?yinAnGanfontSize+yinAnGanHintFontSize:yinAnGanfontSize,
          alignment: isHor?Alignment.centerRight:Alignment.center,
          height: isHor?yinAnGanfontSize:yinAnGanfontSize+yinAnGanHintFontSize*2,
          child: Text(
              tian.name,
              style: ConstantUiResourcesOfQiMen.tianGanTextStyle.copyWith(
                  fontSize: yinAnGanfontSize,
                  shadows: [
                Shadow(color: Colors.black12,offset: Offset(1, 1), blurRadius: 2),
              ])
          ),
        ),
        AnimatedPositioned(
            duration: duration,
            right: 0,
            bottom: isHor?0:yinAnGanHintFontSize,
            child: Container(
                padding: EdgeInsets.symmetric(vertical: 1,horizontal: 1),
                // height: yinAnGanfontSize * .8,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(2),
                ),
                child:Column(
                  children: [
                    Text(
                        yinAnGan.split("").first,
                        style: TextStyle(fontSize: tagTextFontSize,height: 1,color: Colors.white,fontWeight: FontWeight.w600),
                        maxLines: 1,
                    ),
                    if (tagTextFontSize>8)
                      Text(
                        yinAnGan.split("").last,
                        style: TextStyle(fontSize: tagTextFontSize,height: 1,color: Colors.white,fontWeight: FontWeight.w600),
                        maxLines: 1,
                      ),
                    // AutoSizeText(
                    //     yinAnGan.split("").first,
                    //     style: TextStyle(height: 1,color: Colors.black87,fontWeight: FontWeight.w300),
                    //     maxFontSize: 16,
                    //     minFontSize:8,
                    //     maxLines: 1,
                    // ),
                    // AutoSizeText(
                    //   yinAnGan.split("").last,
                    //   style: TextStyle(height: 1,color: Colors.black87,fontWeight: FontWeight.w300),
                    //   maxFontSize: 16,
                    //   minFontSize:8,
                    //   maxLines: 1,
                    // ),
                  ],
                )
            ).animate().fadeIn(duration: Duration(milliseconds: 100),curve: Curves.easeInOutQuart)
        ),
      ],
    );
  }

  Widget _gods(String godName,double width,double sideWidth,{bool showHint = true}) {
    bool isZhiFu = godName == "值符";
    Duration duration = const Duration(milliseconds: 400);
    double centerBoxWidth = width;
    if (centerBoxWidth < 24) {
      centerBoxWidth = 24;
    }
    double miniFontSize = 16;
    double fontSize = width * .5;
    bool isSingleChar = false;
    if (fontSize<=miniFontSize){
      fontSize = miniFontSize;
      isSingleChar = true;
    }
    double centerBoxHeight = width * .5;
    // double sideWidth = fontSize * .5;
    double totalWidth = centerBoxWidth + sideWidth * 2;


    return AnimatedContainer(
      duration: duration,
      height: centerBoxHeight+4 ,
      // width: showHint?totalWidth:centerBoxWidth,
      width:totalWidth,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          SizedBox(
              height: centerBoxHeight<miniFontSize?miniFontSize:centerBoxHeight,
              width: totalWidth<miniFontSize?miniFontSize:totalWidth,
              child:Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  wangShuaText(centerBoxHeight, sideWidth, showHint,Duration(milliseconds: 400)),
                  isSingleChar
                      ?Container(
                    alignment: Alignment.center,
                    height: miniFontSize,
                    width: miniFontSize,
                    child: Text(godName.split("").last,
                      maxLines: 1,
                      style: ConstantUiResourcesOfQiMen
                          .nineStarTextStyle.copyWith(
                          color: isZhiFu?Color.fromRGBO(176, 31, 36, 1):Color.fromRGBO(28, 45, 37, 1),
                          fontSize: miniFontSize),
                    ),)
                      : Container(
                    alignment: Alignment.center,
                    height: centerBoxHeight,
                    width: centerBoxWidth,
                    child: Text(godName,
                      maxLines: 1,
                      style: ConstantUiResourcesOfQiMen
                          .nineStarTextStyle.copyWith(
                          fontSize: fontSize,
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 3,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: duration,
                    // color: Colors.orange.withOpacity(.1),
                    width: showHint?sideWidth:0,
                  ),
                ],
              )

          ),
          if (isZhiFu&&!isSingleChar)
            AnimatedPositioned(
              duration: duration,
              right: showHint?sideWidth:0,
              top: 0,
              child: Container(
                width: 8,
                height: miniFontSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(.2),
                        spreadRadius: 1,
                        blurRadius: 1,
                      )
                    ]
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("贵",style: ConstantUiResourcesOfQiMen
                        .eightDoorTextStyle.copyWith(
                        fontSize: 8,color: Colors.yellow)),
                    Text("人",style: ConstantUiResourcesOfQiMen
                        .eightDoorTextStyle.copyWith(
                        fontSize: 8,color: Colors.yellow)),
                  ],
                ),

              ),
            )
        ],
      ),
    );
  }
  Widget _doors(String doorName,double width,double sideWidth,{bool showHint = false,bool isZhiShiDoor = false}){
    double fontSize = width * .5;
    // double sideWidth = fontSize * .5;
    double totalWidth = width + sideWidth * 2;

    double centerBoxWidth = width;
    double centerBoxHeight = width * .5;
    if (centerBoxWidth < 24){
      centerBoxWidth = 24;
    }
    // double totalWidth = width * 1.5;
    double miniFontSize = 16;
    // double fontSize = width * .5;
    bool isSingleChar = false;
    if (fontSize<=miniFontSize){
      fontSize = miniFontSize;
      isSingleChar = true;
    }
    // double sideWidth = fontSize * .5;
    return Container(
      height: isSingleChar?fontSize:centerBoxHeight,
      width: isSingleChar?fontSize:totalWidth,
      alignment: Alignment.center,
      // color: Colors.yellow,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (!isSingleChar && isZhiShiDoor)
            Positioned(
                bottom: -2,
                child: _buildZhiShiDoor(centerBoxWidth+24)
            ),
          Positioned(
            top:0,
            child: SizedBox(
              height: isSingleChar?fontSize:centerBoxHeight,
              width:isSingleChar?fontSize:totalWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    // color: Colors.red.withOpacity(.2),
                      child: wangShuaText(centerBoxHeight, sideWidth, showHint,Duration(milliseconds: 400))),
                  isSingleChar
                      ? Container(
                    alignment: Alignment.center,
                    height: miniFontSize,
                    width: miniFontSize,
                    child: Text(doorName.split("").first,
                      maxLines: 1,
                      style: ConstantUiResourcesOfQiMen
                          .nineStarTextStyle.copyWith(
                          color: isZhiShiDoor?Color.fromRGBO(176, 31, 36, 1):Color.fromRGBO(28, 45, 37, 1),
                          fontSize: miniFontSize),
                    ),)
                      : Container(
                    alignment: Alignment.center,
                    height: centerBoxHeight,
                    width: centerBoxWidth,
                    child: Text(doorName,
                      maxLines: 1,
                      style: ConstantUiResourcesOfQiMen
                          .nineStarTextStyle.copyWith(
                          fontSize: fontSize,
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 3,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 400),
                    height: centerBoxHeight,
                    width: showHint?sideWidth:0,
                    alignment: Alignment.centerLeft,
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 400),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            end: const Offset(0, 0),
                            begin: const Offset(-1, 0),
                          ).animate(animation),
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: showHint
                          ?buildDescYinZhang("门迫","迫",sideWidth,centerBoxHeight)
                          :Container(),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
  Widget _stars(String starName,double width,double sideWidth,bool isJiTianQin,bool isHor,{bool showHint = true}){
    bool isZhiFuStar = true;
    bool isJiStarZhiFu = true;
    double baseWidth = width * .5;
    double fontSize = baseWidth;
    double miniFontSize = 16;
    // double sideWidth = 12;
    // double fontSize = width * .5;
    bool isSingleChar = false;
    if (fontSize<=miniFontSize) {
      fontSize = miniFontSize;
      isSingleChar = true;
    }
    if (isSingleChar){
      return Container(
        height: fontSize +10,
        width: fontSize,
        alignment: Alignment.center,
        // color: Colors.blueAccent,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              bottom: 0,
              child: SizedBox(
                height: fontSize,
                width:fontSize,
                child: Row(
                  children: [
                    ValueListenableBuilder(
                      valueListenable: showTextHintNotifier,
                      builder: (context, bool showTextHint, child) {
                        return showTextHint
                            ?wangShuaText(miniFontSize, sideWidth, showHint,Duration(milliseconds: 400))
                            : AnimatedContainer(
                          duration: Duration(milliseconds: 400),
                          height: miniFontSize,
                          width: showHint?sideWidth:0,
                          alignment: Alignment.centerRight,
                        );
                      },
                    ),
                    Container(
                      alignment: Alignment.center,
                      height: miniFontSize,
                      width: miniFontSize,
                      child: Text(starName.split("").last,
                        maxLines: 1,
                        style: ConstantUiResourcesOfQiMen
                            .nineStarTextStyle.copyWith(
                            color: isJiStarZhiFu?Color.fromRGBO(176, 31, 36, 1):Color.fromRGBO(28, 45, 37, 1),
                            fontSize: miniFontSize),
                      ),),
                  ],
                ),
              ),
            ),

            if (isJiTianQin)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  height: 10,
                  width:10,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        height: 10,
                        width: 10,
                        child: Text("禽",
                          maxLines: 1,
                          style: ConstantUiResourcesOfQiMen
                              .nineStarTextStyle.copyWith(
                              color: isJiStarZhiFu?Color.fromRGBO(176, 31, 36, 1):Color.fromRGBO(28, 45, 37, 1),
                              fontSize: 10),
                        ),),
                      Container(
                          color: Colors.white,
                          // width: sideWidth,
                          child: wangShuaText(miniFontSize * 0.75, sideWidth, showHint,Duration(milliseconds: 400))),

                    ],
                  ),
                ),
              )
          ],
        ),
      );
    }

    double minHeight = baseWidth;
    double maxHeight = baseWidth * 2;
    double minWidth = baseWidth;
    double maxWidth = baseWidth * 2;
    double maxBoxWidth = isHor?maxWidth:minWidth;
    double maxBoxHeight = isHor?minHeight:maxHeight;
    Duration duration = const Duration(milliseconds: 400);
    double topHeight = minHeight * 0.75;
    double jiStarWidth = topHeight;
    double sizeWidth = topHeight;
    double minFontSize = 16;
    // double sideWidth = fontSize * .5;
    double jiStarFontSize = topHeight * .5;
    TextStyle tianQinFontStyle =  ConstantUiResourcesOfQiMen.nineStarTextStyle.copyWith(fontSize: topHeight,shadows: [
      Shadow(
        offset: Offset(1, 1),
        blurRadius: 3,
        color: Colors.grey,
      ),
    ],);
    TextStyle starFontStyle =  ConstantUiResourcesOfQiMen.nineStarTextStyle.copyWith(fontSize: fontSize,shadows: [
      Shadow(
        offset: Offset(1, 1),
        blurRadius: 3,
        color: Colors.grey,
      ),
    ],);
    return AnimatedContainer(
      duration: Duration(milliseconds: 400),
      alignment: isHor ?Alignment.center:Alignment.centerLeft,
      // width:  isHor ?maxWidth + sideWidth*2:maxWidth+sizeWidth*2,
      width:  isHor ?maxWidth + sideWidth*2:fontSize+jiStarFontSize,
      height: isHor?topHeight+maxHeight-minHeight:sizeWidth+fontSize*2,
      // color: Colors.indigo.withOpacity(.1),
      child: Stack(
        children: [
          if (isJiStarZhiFu)
            isHor?Positioned(
                top:topHeight * .5,
                right: 0,
                child: _buildZhiFuStar(topHeight * 3)
            ):
            Positioned(
              // top:topHeight * .5,
                top:0,
                left: minWidth * .7,
                child: RotatedBox(
                  quarterTurns: 1,
                  child: _buildZhiFuStar(topHeight * 3),
                )
            ),
          if (isZhiFuStar)
            isHor?Positioned(
                bottom: 0,
                left: fontSize >= 16?0:16,
                child: _buildZhiFuStar(fontSize >= 16?maxWidth + sideWidth*2:16+8)
            ):
            Positioned(
                top: 0,
                left: 0,
                child: RotatedBox(
                  quarterTurns: 1,
                  child: _buildZhiFuStar(maxWidth+ sideWidth*2),
                )
            ),

          // 寄天禽 旺衰
          if (isJiTianQin)
            AnimatedPositioned(
              duration: duration,
              // top: isHor?0:topHeight * .5,
              top: 0,
              left: isHor?(sideWidth+ maxBoxWidth):minWidth * .7,
              child: AnimatedContainer(
                  duration: duration,
                  width: jiStarWidth,
                  height: isHor?topHeight:topHeight *2+topHeight,
                  alignment: isHor?Alignment.centerLeft:Alignment.center,
                  child: wangShuaText(isHor?topHeight:topHeight*3, jiStarFontSize, showHint,Duration(milliseconds: 400),alignment: Alignment.centerLeft
                  )
              ),
            ),
          // 星 旺衰
          AnimatedPositioned(
            duration: duration,
            left: 0,
            top: isHor?topHeight:0,
            child: AnimatedContainer(
                duration: duration,
                width:isHor?sideWidth:minWidth,
                height: isHor?maxBoxHeight:sizeWidth+fontSize*2,
                alignment: isHor?Alignment.centerRight:Alignment.center,
                // color: Colors.green.withOpacity(.1),
                child:wangShuaText(isHor?minHeight:maxBoxHeight+sideWidth*2, jiStarFontSize, showHint,Duration(milliseconds: 400)
                )
            ),
          ),
          if (isJiTianQin)
            AnimatedPositioned(
              // top: isHor?0:topHeight,
              top: isHor?0:jiStarFontSize,
              left: isHor?(sideWidth+ (maxBoxWidth-jiStarWidth*2)):minWidth * .7,
              duration: duration,
              child:AnimatedContainer(
                  duration: duration,
                  width: isHor?maxBoxWidth+sizeWidth:jiStarWidth,
                  height: isHor?topHeight:topHeight*2,
                  // color: Colors.yellow.withOpacity(.4),
                  child: Stack(
                      alignment: Alignment.topLeft,
                      children:[
                        Container(
                          width: jiStarWidth,
                          height: jiStarWidth,
                          alignment: Alignment.center,
                          child: Text("天",style:tianQinFontStyle),
                        ),
                        AnimatedContainer(
                            duration:Duration(milliseconds: 200),
                            alignment: isHor?Alignment.topRight:Alignment.bottomCenter,
                            // width:maxBoxWidth-sizeWidth,
                            width:isHor?jiStarWidth*2:sizeWidth,
                            // height: maxWidth - animationWidth < 24?24:maxWidth-animationWidth+16,
                            height: isHor?topHeight:topHeight*2,
                            // color: Colors.blue.withOpacity(.1),
                            child: Container(
                              // color: Colors.red.withOpacity(.1),
                              height: jiStarWidth,
                              width: jiStarWidth,
                              alignment: Alignment.center,
                              child: Text("禽",style:tianQinFontStyle),
                            )
                        ),
                      ]
                  )
              ),
            ),
          AnimatedPositioned(
              duration: duration,
              top: isHor?topHeight:sideWidth,
              left: isHor?sideWidth:0,
              child: Row(
                  children: [
                    Stack(
                        alignment: Alignment.topLeft,
                        children:[
                          AnimatedSwitcher(
                            duration: Duration(milliseconds: 400),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return SlideTransition(
                                position: Tween<Offset>(
                                  end: const Offset(0, 0),
                                  begin: const Offset(-1, 0),
                                ).animate(animation),
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: fontSize >= minFontSize
                                ?Container(
                              width: fontSize,
                              height: fontSize,
                              // width: baseWidth,
                              // height: baseWidth,
                              // color: Colors.purple.withOpacity(.1),
                              alignment: Alignment.center,
                              child: Text(starName.split("").first,style:starFontStyle),
                            ):Container(),
                          ),
                          AnimatedContainer(
                              duration:Duration(milliseconds: 200),
                              alignment: isHor?(fontSize<minFontSize?Alignment.center:Alignment.topRight):Alignment.bottomCenter,
                              width:fontSize >= minFontSize?maxBoxWidth:fontSize*2,
                              height: maxBoxHeight,
                              child: Container(
                                // color: Colors.red.withOpacity(.1),
                                width: fontSize,
                                height: fontSize,
                                // height: baseWidth,
                                // width: baseWidth,
                                alignment: Alignment.center,
                                child: Text(starName.split("").last,style:starFontStyle),
                              )
                          ),
                        ]
                    ),
                    isHor?SizedBox(
                      width: sideWidth,
                      height: maxBoxHeight,
                      // color: Colors.grey.withOpacity(.5),
                    ):SizedBox()
                  ]
              )
          ),
        ],
      ),
    );
  }

  @Deprecated("use _stars")
  Widget _stars_v1(String starName,bool isJiTianQin){
    return ValueListenableBuilder(
        // valueListenable: nineStarBoxSizeNotifier,
        // builder: (ctx,size,_){
        valueListenable: slideWidthNotifier,
        builder: (ctx,width,_){
          double baseWidth = width * .5;
          double fontSize = baseWidth;
          return ValueListenableBuilder(
              valueListenable: isHorNotifier,
              builder: (ctx,isHor,_){
                double minHeight = baseWidth;
                double maxHeight = baseWidth * 2;
                double minWidth = baseWidth;
                double maxWidth = baseWidth * 2;
                double maxBoxWidth = isHor?maxWidth:minWidth;
                double maBoxHeight = isHor?minHeight:maxHeight;
                Duration duration = const Duration(milliseconds: 400);
                // print(minHeight * 0.75);
                // double topHeight = 18;
                // double sizeWidth = 16;
                double topHeight = minHeight * 0.75;
                double smallWidth = topHeight;
                double sizeWidth = topHeight;
                double sideWidth = 12;
                return AnimatedContainer(
                  duration: Duration(milliseconds: 100),
                  alignment: isHor ?Alignment.center:Alignment.centerLeft,
                  width:  isHor ?maxWidth + sizeWidth+sizeWidth:maxWidth+sizeWidth*4,
                  // height: topHeight+maxHeight,
                  height: isHor ?topHeight+maxHeight- minHeight:topHeight+maxHeight,
                  child: Stack(
                    children: [
                      if (isJiTianQin)
                        AnimatedPositioned(
                          top: isHor?0:topHeight,
                          // left: isHor?(maxWidth + sizeWidth *2 - (maxBoxWidth-sizeWidth+sizeWidth)):(sizeWidth+minWidth),
                          left: isHor?(sideWidth+ (maxBoxWidth-smallWidth*2)):(sizeWidth+minWidth),
                          duration: duration,
                          child:AnimatedContainer(
                              duration: duration,
                              width: maxBoxWidth-sizeWidth+sizeWidth+sizeWidth,
                              height: isHor?topHeight:topHeight*2,
                              // color: Colors.yellow.withOpacity(.4),
                              child: Row(
                                children: [
                                  Stack(
                                      alignment: Alignment.topLeft,
                                      children:[
                                        Container(
                                          width: smallWidth,
                                          height: topHeight,
                                          color: Colors.orange.withOpacity(.1),
                                          alignment: Alignment.center,
                                          child: Text("天",style: ConstantUiResourcesOfQiMen.nineStarTextStyle.copyWith(fontSize: topHeight)),
                                        ),
                                        AnimatedContainer(
                                            duration:Duration(milliseconds: 200),
                                            alignment: isHor?Alignment.topRight:Alignment.bottomCenter,
                                            // width:maxBoxWidth-sizeWidth,
                                            width:isHor?smallWidth*2:sizeWidth,
                                            // height: maxWidth - animationWidth < 24?24:maxWidth-animationWidth+16,
                                            height: isHor?topHeight:topHeight*2,
                                            color: Colors.blue.withOpacity(.1),
                                            child: Container(
                                              color: Colors.red.withOpacity(.1),
                                              height: topHeight,
                                              width: smallWidth,
                                              alignment: Alignment.center,
                                              child: Text("禽",style: ConstantUiResourcesOfQiMen.nineStarTextStyle.copyWith(fontSize: topHeight)),
                                            )
                                        ),

                                      ]
                                  ),
                                  Container(
                                      width: sizeWidth,
                                      height: isHor?topHeight:topHeight*2,
                                      color: Colors.pink.withOpacity(.2),
                                      alignment: Alignment.centerLeft,
                                      child: ValueListenableBuilder(
                                          valueListenable:showHintNotifier,
                                          builder: (ctx,show,_){
                                            return wangShuaText(isHor?topHeight:topHeight*2, topHeight * .5, show,Duration(milliseconds: 400));
                                          }
                                      )
                                  )
                                ],
                              )
                          ),

                        ),
                      Positioned(
                          top: topHeight,
                          child: Column(
                            children: [
                              Row(
                                  children: [
                                    AnimatedContainer(
                                      duration: duration,
                                      width:sideWidth,
                                      height: maBoxHeight,
                                      alignment: Alignment.centerRight,
                                      color: Colors.green.withOpacity(.1),
                                      child: ValueListenableBuilder(
                                        valueListenable: showHintNotifier,
                                        builder: (ctx,showHint,_){
                                          return wangShuaText(isHor?minHeight:maxHeight, sideWidth, showHint,Duration(milliseconds: 400));
                                        },
                                      ),
                                    ),
                                    Stack(
                                        alignment: Alignment.topLeft,
                                        children:[
                                          Container(
                                            width: baseWidth,
                                            height: baseWidth,
                                            color: Colors.orange.withOpacity(.1),
                                            alignment: Alignment.center,
                                            child: Text(starName.split("").first,style: ConstantUiResourcesOfQiMen.nineStarTextStyle.copyWith(fontSize: fontSize)),
                                          ),
                                          AnimatedContainer(
                                              duration:Duration(milliseconds: 200),
                                              alignment: isHor?Alignment.topRight:Alignment.bottomCenter,
                                              width:maxBoxWidth,
                                              // height: maxWidth - animationWidth < 24?24:maxWidth-animationWidth+16,
                                              height: maBoxHeight,
                                              color: Colors.blue.withOpacity(.1),
                                              child: Container(
                                                color: Colors.red.withOpacity(.1),
                                                height: baseWidth,
                                                width: baseWidth,
                                                alignment: Alignment.center,
                                                child: Text(starName.split("").last,style: ConstantUiResourcesOfQiMen.nineStarTextStyle.copyWith(fontSize: fontSize)),
                                              )
                                          ),
                                        ]
                                    ),
                                    Container(
                                      width: sideWidth,
                                      height: maBoxHeight,
                                      // color: Colors.grey.withOpacity(.5),
                                    )

                                  ]
                              ),
                            ],
                          ))
                    ],
                  ),
                );
              }

          );
        }
    );
  }

  Widget _buildZhiFuStar(double width){
    return AnimatedContainer(
        width: width,
        height: width * .2,
        alignment: Alignment.center,
        duration: Duration.zero,
        child:ColorFiltered(
            colorFilter: ColorFilter.mode(
                Color.fromRGBO(176, 31, 36, .8),
                BlendMode.srcIn),
            child: Image.asset("assets/icons/wide-black-ink-line.png",))
    );
  }

  Widget _buildZhiShiDoor(double width){
    return AnimatedContainer(
        width: width,
        height: width * .2,
        alignment: Alignment.center,
        // duration: Duration.zero,
        duration: Duration(milliseconds: 200),
        child:ColorFiltered(
            colorFilter: ColorFilter.mode(
                Color.fromRGBO(176, 31, 36, .8),
                BlendMode.srcIn),
            child: Image.asset("assets/icons/wide-black-ink-radian-line2.png",))
    );

    return FutureBuilder(
      future: precacheImage(AssetImage("assets/icons/wide-black-ink-radian-line2.png"), context),
      builder: (context, snapshot) {
        return AnimatedSwitcher(
            duration: Duration(milliseconds: 400),
            child:snapshot.connectionState == ConnectionState.done
                ?AnimatedContainer(
              duration: Duration(milliseconds: 100),
                width: width,
                height: width * .2,
                child:ColorFiltered(
                    colorFilter: ColorFilter.mode(Color.fromRGBO(176, 31, 36, .8), BlendMode.srcIn),
                    child: Image.asset("assets/icons/wide-black-ink-radian-line2.png",))
            )
                .animate()
                .fadeIn(duration: Duration(milliseconds: 400))
                :Container(width: width, height: 12,)
        );
      },
    );
  }

  Widget buildDescYinZhang(String name,String single,double width,double height){
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          color: Colors.indigo,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 2,
            )
          ]
      ),
      alignment: Alignment.center,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: height <20
            ? Container(
          width: width,
          height: width,
          alignment: Alignment.center,
          child: AutoSizeText(
            single,
            maxLines: 1,
            minFontSize: 8,
            maxFontSize: 12,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w200,
                height: 1,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 2,
                  )
                ]
            ),
          ),
        )
            : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              width: width,
              height: width,
              alignment: Alignment.center,
              child: AutoSizeText(
                name.split("").first,
                maxLines: 1,
                minFontSize: 8,
                maxFontSize: 12,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w200,
                    height: 1,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 2,
                      )
                    ]
                ),
              ),
            ),
          Container(
            width: width,
            height: width,
            alignment: Alignment.center,
            child: AutoSizeText(
              name.split("").last,
              maxLines: 1,
              minFontSize: 8,
              maxFontSize: 12,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w200,
                  height: 1,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 2,
                    )
                  ]
              ),
            ),

          )
        ],
      ),
    )
    );
  }

  Widget wangShuaArrow(double boxHeight,double width, bool showHint){
    return AnimatedContainer(
      duration: Duration(milliseconds: 400),
      height: boxHeight,
      width: showHint?width:0,
      alignment: Alignment.centerRight,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 400),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0),
              end: const Offset(0, 0),
            ).animate(animation),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: showHint?Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              color: Colors.black87.withOpacity(.1),
                child: _buildTwoArrowHint(true,Colors.red,width)),
            _buildThreeArrowHint(false,Colors.grey,width),
          ],
        ):Container(),
      ),
    );
  }
  Widget zhangShengText(
      double yinAnGanHintFontSize,
      TwelveZhangSheng monthly,
      TwelveZhangSheng gong,
      bool isHor,
      bool showHint,
      Duration duration,
      {Alignment alignment = Alignment.centerRight}){
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: const Offset(0, 0),
          ).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: showHint?Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            isHor?monthly.name.split("").last:monthly.name,
            style: TextStyle(color: Colors.black87,fontSize: yinAnGanHintFontSize,fontWeight: FontWeight.w300,height: 1),
            maxLines: 1,
          ),
          Text(
            isHor?gong.name.split("").last:gong.name,
            style: TextStyle(color: Colors.black87,fontSize:yinAnGanHintFontSize,fontWeight: FontWeight.w300,height: 1),
            maxLines: 1,
          ),
        ],
      ):Container(),
    );
  }
  Widget wangShuaText(
      double boxHeight,
      double width,
      bool showHint,
      Duration duration,
      {Alignment alignment = Alignment.centerRight}){
    return AnimatedContainer(
      duration: duration,
      height: boxHeight,
      width: showHint?width:0,
      alignment: alignment,
      child: AnimatedSwitcher(
        duration: duration,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: const Offset(0, 0),
            ).animate(animation),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: showHint?Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: width,
              height: width,
              alignment: alignment,
              child: AutoSizeText(
                "旺",
                style: TextStyle(color: Colors.black87,fontWeight: FontWeight.w300,height: 1),
                minFontSize : 8,
                maxFontSize : 24,
              ),
            ),
            Container(
              width: width,
              height: width,
              alignment: alignment,
              child: AutoSizeText(
                "衰",
                style: TextStyle(color: Colors.black87,fontWeight: FontWeight.w300,height: 1),
                minFontSize : 8,
                maxFontSize : 24,
              ),

            )
          ],
        ):Container(),
      ),
    );
  }
  Widget _buildTwoArrowHint(bool toTop,Color color,double size){
    return RotatedBox(
      quarterTurns: toTop?2:0,
      child: Lottie.asset(
          'assets/lotties/two_down_arrow.json',
          width: size,
          height: size,
          delegates:LottieDelegates(
              values:[
                ValueDelegate.colorFilter(
                  ["**"],
                  value: ColorFilter.mode(color, BlendMode.src),
                )
              ]
          )
      ),
    );
  }
  Widget _buildThreeArrowHint(bool toTop,Color color,double size){
    return RotatedBox(
      quarterTurns: toTop?-1:1,
      child: Lottie.asset(
          'assets/lotties/three_down_arrow.json',
          width: size,
          height: size,
          delegates:LottieDelegates(
              values:[
                ValueDelegate.colorFilter(
                  ["**"],
                  value: ColorFilter.mode(color.withOpacity(.5), BlendMode.src),
                )
              ]
          )
      ),
    );
  }

  Widget buildBuWen(List<Map<String,String>> mapper){
    List<Widget> lists = [];
    for (int i = 0; i < mapper.length; i++){
      lists.add(Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              alignment: Alignment.topRight,
              child: Text("${mapper[i]["key"]}：",style: TextStyle(fontWeight: FontWeight.w600),)),
          Expanded(
              flex: 7,
              child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text("${mapper[i]["content"]}"))
          ),
        ],
      ));
      if (i != mapper.length - 1){
        lists.add(SizedBox(height: 4,));
      }

    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("卜问",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
        Divider(height: 8,color: Colors.grey,),
        ...lists
      ],
    );
  }
  Widget tenGanKeYingZhuJie(List<TenGanKeYingZhu> zhuList){
    TextStyle titleStyle = TextStyle(fontWeight: FontWeight.bold,fontSize: 18);
    TextStyle contentStyle = TextStyle(fontSize: 16,color: Colors.black87);
    TextStyle seeMoreStyle = TextStyle(fontSize: 16,
        color: Colors.blue.shade600,
        fontWeight: FontWeight.w200);

    List<Widget> lists = [];
    for (var zhu in zhuList){
      lists.add(Text(zhu.author ?? "注解",style: titleStyle));
      lists.add(Divider(height: 8,));
      lists.add(Container(
        child: AnimatedReadMoreText(
          "利静不利动。出行结伴主失散，还容易得病。遇伏吟，不宜动。一动，就出事。如果此格临马星或九天，你不让他动，他肯定也动，一动就倒霉，然后后悔。此格，遇到击刑，也主牢狱、伤灾。遇此格，自己独立出行、独立行事，一般没有大问题。就怕多人出行以及合作做事，则必然出问题。庚+庚，癸+癸，一合作就出事。遇到此格，切忌结伴出行，若结伴出行：一是自己生病；二是与同伴失去联系或分道扬镳。二者必应其一。",
          maxLines: 3,
          // Set a custom text for the expand button. Defaults to Read more
          readMoreText: '展开',
          // Set a custom text for the collapse button. Defaults to Read less
          readLessText: '收起',
          // Set a custom text style for the main block of text
          textStyle: contentStyle,
          // Set a custom text style for the expand/collapse button
          buttonTextStyle: seeMoreStyle,
          expandOnTextTap: true,
        ),
      ));
      lists.add(SizedBox(height: 8,));
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lists,
    );
  }

  Widget geJuTag(){
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              width: 280,
              height: 160,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: Offset(0, 1), // changes position of shadow
                    )
                  ]
              ),
              child:Stack(
                children: [
                  FourZhuEightChar(
                    year:JiaZi.JIA_CHEN,
                    month:JiaZi.REN_CHEN,
                    day:JiaZi.DING_MAO,
                    chen:JiaZi.WU_ZI,
                    zodiacGanColors:ConstResourcesMapper.zodiacGanColors,
                    zodiacZhiColors:ConstResourcesMapper.zodiacZhiColors,
                    isColorful:true,
                  ),
                ],
              )
          ),
          shape_2(),
          ge_ju_template("天运昌气",Color.fromRGBO(59,78,61, 1),Color.fromRGBO(240, 167, 46, 1)),
          ge_ju_template("天显时格",Color.fromRGBO(32, 50, 54, 1),Color.fromRGBO(209, 181, 146, 1)),
          ge_ju_template("天辅吉时",Color.fromRGBO(25, 44, 59, 1),Color.fromRGBO(176, 132, 88,1)),

          // ge_ju_template("天辅吉时",Color.fromRGBO(25, 44, 59, 1),Color.fromRGBO(144, 105, 62,1)),
          // Color backColor = Color.fromRGBO(185, 128, 124, 1);
          // Color color = Color.fromRGBO(63, 75, 80,1);

          shape_3("三奇入墓", Color.fromRGBO(63, 75, 80,1),Color.fromRGBO(185, 128, 124, 1),Size(120, 32)),
          shape_3("三奇入墓", Color.fromRGBO(63, 75, 80,1),Color.fromRGBO(185, 128, 124, 1),Size(180, 48)),
          shape_3("五不遇时", Color.fromRGBO(130,78,64,1),Color.fromRGBO(88,15,5, 1),Size(180, 48)),
          shape_3("庚格·飞宫格", Color.fromRGBO(250,237,223,1),Color.fromRGBO(59,59,61, 1),Size(200, 48),contentSplitter: ""),
          shape_3("飞干格", Color.fromRGBO(255,250,250,1),Color.fromRGBO(68,68,60, 1),Size(160, 48)),
          shape_3("悖格", Color.fromRGBO(250,237,223,1),Color.fromRGBO(59,59,61, 1),Size(140, 48)),

          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                  child:Image.asset("assets/icons/ge_ju_template_1.png",)),
              Text("玉 女 守 门",style: GoogleFonts.maShanZheng(color: Color.fromRGBO(233,231,239, 1),fontSize: 18),)
            ],
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                child: Image.asset("assets/icons/ge_ju_template_2.png"),
              ),
              Text("三 奇 得 使",style: GoogleFonts.maShanZheng(color: Color.fromRGBO(233,231,239, 1),fontSize: 18),)
            ],
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                child: Image.asset("assets/icons/ge_ju_template_3.png"),
              ),
              Text("三 奇 升 殿",style: GoogleFonts.maShanZheng(color: Color.fromRGBO(233,231,239, 1),fontSize: 18),)
            ],
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                child: Image.asset("assets/icons/ge_ju_template_4.png"),
              ),
              Text("交 泰",style: GoogleFonts.maShanZheng(color: Color.fromRGBO(233,231,239, 1),fontSize: 18),)
            ],
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                child: Image.asset("assets/icons/ge_ju_template_5.png"),
              ),
              Text("九 遁 · 天 遁",style: GoogleFonts.maShanZheng(color: Color.fromRGBO(233,231,239, 1),fontSize: 18),)
            ],
          ),

          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                  child: Image.asset("assets/icons/ge_ju_template_6.png",)),
              Container(
                // child: GoldText(text:"玉 女 守 门",fontSize: 28,),
                  padding: EdgeInsets.only(top: 6),
                  // color: Colors.orange,
                  child: Text("交 泰",style: GoogleFonts.maShanZheng(color: Color.fromRGBO(234,205,118, 1),fontSize: 36),)
              )
            ],
          ),
        ]
    );
  }
  Widget shape_3(String name, Color color,Color backColor,Size size,{String contentSplitter=" "}){
    double width = size.width;
    double height = size.height;

    return Stack(
      alignment: Alignment.center,
      children: [

        Container(
          width: width,
          height: height - 20,
          decoration: BoxDecoration(
              color: color,
            boxShadow: [
              BoxShadow(
                color: Colors.black87.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 1,
                  offset: Offset(1, 1)
              )
            ]
          ),
        ),
        Container(
          width: width - 10,
          height: height - 10,
          decoration: BoxDecoration(
            color: color,
              boxShadow: [
                BoxShadow(
                  color: Colors.black87.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: Offset(1, 1)
                )
              ]

          ),
        ),
        Container(
          width: width-20,
          height: height,
          decoration: BoxDecoration(
            color: color,
              boxShadow: [
                BoxShadow(
                  color: Colors.black87.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 1,
                  offset: Offset(1, 1)
                )
              ]
          ),
        ),
        Container(
          width: width - 4,
          height: height - 20 -4,
          decoration: BoxDecoration(
            color: backColor,
          ),
        ),
        Container(
          width: width - 10 - 4,
          height: height - 10 -4,
          decoration: BoxDecoration(
            color:backColor,
          ),
        ),
        Container(
          width: width-20 - 4,
          height: height-4,
          decoration: BoxDecoration(
            color: backColor,
          ),
        ),

        Container(
          width: width-8,
          height: height - 20 -6,
          decoration: BoxDecoration(
            color: color,
          ),
        ),
        Container(
          width: width-10-8,
          height: height - 10 -6,
          decoration: BoxDecoration(
            color: color,
          ),
        ),

        Container(
          width: width-20-8,
          height: height -6,
          decoration: BoxDecoration(
            color: color,
          ),
          alignment: Alignment.center,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                height: size.height,
                width: size.width * .1,
                child:ColorFiltered(
                    colorFilter: ColorFilter.mode(backColor, BlendMode.srcIn),
                    child: Image.asset("assets/icons/deng_long.png",)),
              ),
              Container(
                alignment: Alignment.center,
                width: size.width * .5,
                  child: AutoSizeText(
                name.split("").join(contentSplitter),
                style: GoogleFonts.maShanZheng(color:backColor,fontSize: 24),
                maxLines: 1,
                minFontSize: 10,
                maxFontSize: 32,
              ))
              ,
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      colorFilter: ColorFilter.mode(backColor, BlendMode.srcIn),
                      image: AssetImage("assets/icons/ru_mu.png")
                  ),
                ),
                width: width * .1,
                alignment: Alignment.center,
                child: AutoSizeText(
                  "凶",
                  style: GoogleFonts.maShanZheng(height: 1.0,color: color,fontWeight: FontWeight.w600,shadows: [Shadow(color: Colors.white.withOpacity(.4),blurRadius: 4)]),
                  maxLines: 1,
                  minFontSize: 8,
                  maxFontSize: 16,
                ),
              )
            ],
          ),
        ),
      ],

    );
  }

  Widget ge_ju_template_small(String name, Color color, Color backColor){

    // Color backColor = Color.fromRGBO(252, 204, 140, 1);
    // Color color = Color.fromRGBO(77, 79, 100, 1);
    double innerDotSize = 12;
    Container dot1 = Container(
      height: 20,
      width: 20,
      decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(.5),
              offset: Offset(1, 1), //阴影xy轴偏移量
              blurRadius: 1, //阴影模糊程度
              spreadRadius: 1, //阴影扩散程度
            )
          ]
      ),
    );
    Container dot2 =  Container(
      height: 16,
      width: 16,
      decoration: BoxDecoration(
        color:backColor,
        // color:Colors.redAccent,
        borderRadius: BorderRadius.circular(10),
      ),
    );
    Container dot3 =  Container(
      height: 12,
      width: 12,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
    );
    double width = 120;
    double height = 36;

    double outerWidth = 160;
    double outerHeight = 52;
    double outerRadius = 10;
    double offset = 2;
    Size size = Size(48, 24);
    return SizedBox(
      width: outerWidth,
      height: outerHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            // width: outerWidth - 18-9-1,
            width: width + innerDotSize,
            height: outerHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                dot1,dot1
              ],
            ),
          ),

          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(outerRadius),
                boxShadow: [
                  BoxShadow(
                    // color: Colors.black26,
                    color: color.withOpacity(.5),
                    offset: Offset(1, 1), //阴影xy轴偏移量
                    blurRadius: 1, //阴影模糊程度
                    spreadRadius: 1, //阴影扩散程度
                  )
                ]
            ),
          ),

          SizedBox(
            // width: outerWidth - 18 - 9 -6,
            width: width + innerDotSize - offset * 2,
            height: outerHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [dot2,dot2],
            ),
          ),
          Container(
              width: width -4,
              height: height -4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(outerRadius - offset),
                color:backColor,
              )),


          Container(
            // width: outerWidth - 18 - 9 - 8,
            width: width + innerDotSize - offset * 3,
            height: outerHeight,
            // color: Colors.white.withOpacity(.6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                dot3,dot3
              ],
            ),
          ),
          Container(
            width: width -6,
            height: height -6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(outerRadius - offset),
              color:color,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 10,),
                Text(name.split("").join(" "),style: GoogleFonts.maShanZheng(color: backColor,fontSize: 18),),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 26,
                      width: 14,
                      child:ColorFiltered(
                          colorFilter: ColorFilter.mode(Colors.red, BlendMode.srcIn),
                          child: Image.asset("assets/icons/ji_xiong_yin_zhang.png",)),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("大",style: GoogleFonts.longCang(height: 1.0,color: color,fontSize: 12,fontWeight: FontWeight.w600,shadows: [Shadow(color: Colors.white.withOpacity(.4),blurRadius: 4)]),),
                        Text("吉",style: GoogleFonts.longCang(height: 1.0,color: color,fontSize: 12,fontWeight: FontWeight.w600,shadows: [Shadow(color: Colors.white.withOpacity(.4),blurRadius: 4)])),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
          FutureBuilder(
            future: precacheImage(AssetImage('assets/icons/xiang_yun_wen_l.png'), context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // 图片加载完成后执行的操作
                return Positioned(
                    left: -2,
                    top: -2,
                    child: Container(
                      height: 24,
                      width: 64,
                      child:ColorFiltered(
                          colorFilter: ColorFilter.mode(backColor, BlendMode.srcIn),
                          child: Image.asset("assets/icons/xiang_yun_line_1.png",)),
                    )
                ).animate(autoPlay: true).scale(begin: Offset.zero,end: Offset(1, 1),curve: Curves.ease,duration: Duration(milliseconds: 800));
              } else {
                // 加载中显示的内容
                return Container();
              }
            },
          ),
          FutureBuilder(
            future: precacheImage(AssetImage('assets/icons/xiang_yun_wen_l.png'), context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // 图片加载完成后执行的操作
                return Positioned(
                    left: 0,
                    bottom: 4,
                    child: SizedBox.fromSize(
                      size:size,
                      child:ColorFiltered(
                          colorFilter: ColorFilter.mode(backColor, BlendMode.srcIn),
                          child: Image.asset("assets/icons/xiang_yun_wen_l.png",)),
                    )
                ).animate(autoPlay: true).moveX(begin: outerWidth * .2,end: 0,curve: Curves.ease,duration: Duration(milliseconds: 800));
              } else {
                // 加载中显示的内容
                return Container();
              }
            },
          ),
          FutureBuilder(
            future: precacheImage(AssetImage('assets/icons/xiang_yun_wen_r.png'), context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // 图片加载完成后执行的操作
                print('Image loaded.');
                return Positioned(
                  right: 4,
                  top: -2,
                  child: Container(
                    child: SizedBox.fromSize(
                        size:size,
                        child:ColorFiltered(
                            colorFilter: ColorFilter.mode(backColor, BlendMode.srcIn),
                            child: Image.asset("assets/icons/xiang_yun_wen_r.png",))),
                  ),
                )
                    .animate(autoPlay: true,)
                    .moveX(begin: -(outerWidth * .2),end: 0,curve: Curves.ease,duration: Duration(milliseconds: 800))
                // .then()
                // .animate(autoPlay: true,delay: Duration(milliseconds: 1000),onComplete: (an)=>an.repeat(),)
                // .moveX(begin: 0,end: 24,curve: Curves.ease,duration: Duration(milliseconds: 800))
                    ;
              } else {
                // 加载中显示的内容
                return Container();
              }
            },
          ),

        ],

      ),
    );
  }
  Widget ge_ju_template(String name, Color color, Color backColor){

    // Color backColor = Color.fromRGBO(252, 204, 140, 1);
    // Color color = Color.fromRGBO(77, 79, 100, 1);
    Container dot1 = Container(
      height: 26,
      width: 26,
      decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(.5),
              offset: Offset(1, 1), //阴影xy轴偏移量
              blurRadius: 1, //阴影模糊程度
              spreadRadius: 1, //阴影扩散程度
            )
          ]
      ),
    );
    Container dot2 =  Container(
      height: 22,
      width: 22,
      decoration: BoxDecoration(
        color:backColor,
        // color:Colors.redAccent,
        borderRadius: BorderRadius.circular(10),
      ),
    );
    Container dot3 =  Container(
      height: 20,
      width: 20,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
    );
    double width = 180;
    double height = 42;

    double outerWidth = 200;
    double outerHeight = 60;
    double outerRadius = 12;
    double offset = 2;
    Size size = Size(48, 24);
    return SizedBox(
      width: outerWidth,
      height: outerHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: outerWidth - 6,
            height: outerHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                dot1,dot1
              ],
            ),
          ),

          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(outerRadius),
                boxShadow: [
                  BoxShadow(
                    // color: Colors.black26,
                    color: color.withOpacity(.5),
                    offset: Offset(1, 1), //阴影xy轴偏移量
                    blurRadius: 1, //阴影模糊程度
                    spreadRadius: 1, //阴影扩散程度
                  )
                ]
            ),
          ),

          SizedBox(
            // color: Colors.white,
            width: outerWidth - outerRadius,
            height: outerHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [dot2,dot2],
            ),
          ),
          Container(
            width: width -6,
            height: height -6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(outerRadius - offset),
              // color:backColor,
              // border: Border.all(color: backColor, width: 1),
              color:color,
              border: Border.all(color: backColor, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 16,),
                Text(name.split("").join(" "),style: GoogleFonts.maShanZheng(color: backColor,fontSize: 24),),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 32,
                      width: 16,
                      child:ColorFiltered(
                          // colorFilter: ColorFilter.mode(backColor, BlendMode.srcIn),
                          colorFilter: ColorFilter.mode(Colors.red, BlendMode.srcIn),
                          child: Image.asset("assets/icons/ji_xiong_yin_zhang.png",)),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 14,
                          // color: Colors.blue,
                          alignment: Alignment.center,
                          child: Text("大",style: GoogleFonts.longCang(height: 1.0,color: color,fontSize: 14,fontWeight: FontWeight.w600,shadows: [Shadow(color: Colors.grey.withOpacity(.4),blurRadius: 4)]),),
                        ),
                        Container(
                          width: 14,
                          alignment: Alignment.center,
                          child: Text("吉",style: GoogleFonts.longCang(height: 1.0,color: color,fontSize: 14,fontWeight: FontWeight.w600,shadows: [Shadow(color: Colors.white.withOpacity(.4),blurRadius: 4)])),
                        )
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),

          Container(
            width: outerWidth - outerRadius - offset,
            height: outerHeight,
            // color: Colors.white.withOpacity(.6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                dot3,dot3
              ],
            ),
          ),

          FutureBuilder(
            future: precacheImage(AssetImage('assets/icons/xiang_yun_wen_l.png'), context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // 图片加载完成后执行的操作
                return Positioned(
                    left: -2,
                    top: -2,
                    child: Container(
                      height: 24,
                      width: 64,
                      child:ColorFiltered(
                          colorFilter: ColorFilter.mode(backColor, BlendMode.srcIn),
                          child: Image.asset("assets/icons/xiang_yun_line_1.png",)),
                    )
                ).animate(autoPlay: true).scale(begin: Offset.zero,end: Offset(1, 1),curve: Curves.ease,duration: Duration(milliseconds: 800));
              } else {
                // 加载中显示的内容
                return Container();
              }
            },
          ),


          FutureBuilder(
            future: precacheImage(AssetImage('assets/icons/xiang_yun_wen_l.png'), context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // 图片加载完成后执行的操作
                return Positioned(
                    left: 0,
                    bottom: 4,
                    child: SizedBox.fromSize(
                      size:size,
                      child:ColorFiltered(
                          colorFilter: ColorFilter.mode(backColor, BlendMode.srcIn),
                          child: Image.asset("assets/icons/xiang_yun_wen_l.png",)),
                    )
                ).animate(autoPlay: true).moveX(begin: outerWidth * .2,end: 0,curve: Curves.ease,duration: Duration(milliseconds: 800));
              } else {
                // 加载中显示的内容
                return Container();
              }
            },
          ),
          FutureBuilder(
            future: precacheImage(AssetImage('assets/icons/xiang_yun_wen_r.png'), context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // 图片加载完成后执行的操作
                print('Image loaded.');
                return Positioned(
                  right: 4,
                  top: -4,
                  child: Container(
                    color: Colors.red.withOpacity(.1),
                    child: SizedBox.fromSize(
                        size:size,
                        child:ColorFiltered(
                            colorFilter: ColorFilter.mode(backColor, BlendMode.srcIn),
                            child: Image.asset("assets/icons/xiang_yun_wen_r.png",))),
                  ),
                )
                    .animate(autoPlay: true,)
                    .moveX(begin: -(outerWidth * .2),end: 0,curve: Curves.ease,duration: Duration(milliseconds: 800))
                    // .then()
                    // .animate(autoPlay: true,delay: Duration(milliseconds: 1000),onComplete: (an)=>an.repeat(),)
                    // .moveX(begin: 0,end: 24,curve: Curves.ease,duration: Duration(milliseconds: 800))
                ;
              } else {
              // 加载中显示的内容
              return Container();
              }
            },
          ),
          // Positioned(
          //     left: 0,
          //     bottom: 4,
          //     child: SizedBox(
          //       height: 24,
          //       width: 48,
          //       child:ColorFiltered(
          //           colorFilter: ColorFilter.mode(backColor, BlendMode.srcIn),
          //           child: Image.asset("assets/icons/xiang_yun_wen_l.png",)),
          //     )
          // ),
          // Positioned(
          //   right: 0,
          //   top: -4,
          //   child: Container(
          //       height: 24,
          //       width: 48,
          //       color: Colors.blue.withOpacity(.2),
          //       child:ColorFiltered(
          //           colorFilter: ColorFilter.mode(backColor, BlendMode.srcIn),
          //           child: Image.asset("assets/icons/xiang_yun_wen_r.png",))),
          // ).animate(autoPlay: false).moveX(begin: -100,end: 0,duration: Duration(milliseconds: 4000)),
          // Container(
          //   width: outerWidth,
          //   height: outerHeight,
          //   color: Colors.redAccent.withOpacity(.1),
          //     child: SizedBox(
          //         height: 24,
          //         width: 48,
          //         child:ColorFiltered(
          //             colorFilter: ColorFilter.mode(backColor, BlendMode.srcIn),
          //             child: Image.asset("assets/icons/xiang_yun_wen_r.png",))),
          // )
        ],

      ),
    );
  }
  Widget ge_ju_template_fixed_size(String name, Color color, Color backColor){

    // Color backColor = Color.fromRGBO(252, 204, 140, 1);
    // Color color = Color.fromRGBO(77, 79, 100, 1);
    Container dot1 = Container(
      height: 28,
      width: 28,
      decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(.5),
              offset: Offset(1, 1), //阴影xy轴偏移量
              blurRadius: 1, //阴影模糊程度
              spreadRadius: 1, //阴影扩散程度
            )
          ]
      ),
    );
    Container dot2 =  Container(
      height: 22,
      width: 22,
      decoration: BoxDecoration(
        color:backColor,
        borderRadius: BorderRadius.circular(10),
      ),
    );
    Container dot3 =  Container(
      height: 20,
      width: 20,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
    );
    double width = 180;
    double height = 42;
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 200,
          height: 60,
          decoration: BoxDecoration(
            // color: Colors.orange,
            // borderRadius: BorderRadius.circular(10),
          ),
        ),
        Positioned(
          left: 4,
          child: dot1,
        ),
        Positioned(
          right: 4,
          child: dot1,
        ),
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  // color: Colors.black26,
                  color: color.withOpacity(.5),
                  offset: Offset(1, 1), //阴影xy轴偏移量
                  blurRadius: 1, //阴影模糊程度
                  spreadRadius: 1, //阴影扩散程度
                )
              ]
          ),
        ),

        Positioned(
          left: 6,
          child:dot2,
        ),
        Positioned(
          right: 6,
          child: dot2,
        ),
        Container(
          width: width-4,
          height: height - 4,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              color: backColor
            // border: Border.all(color: Colors.white, width: 1),
          ),
        ),

        Positioned(
          left: 7,
          child: dot3,
        ),
        Positioned(
          right: 7,
          child: dot3,
        ),
        Container(
          width: width -6,
          height: height -6,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color:color
            // border: Border.all(color: Colors.white, width: 1),
          ),
        ),

        Container(
          width: 180,
          // child: Text("玉 女 守 门",style: GoogleFonts.maShanZheng(color: backColor,fontSize: 24),),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 17,),
              Text(name.split("").join(" "),style: GoogleFonts.maShanZheng(color: backColor,fontSize: 24),),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 32,
                    width: 17,
                    child:ColorFiltered(
                        colorFilter: ColorFilter.mode(backColor, BlendMode.srcIn),
                        child: Image.asset("assets/icons/ji_xiong_yin_zhang.png",)),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 14,
                        // color: Colors.blue,
                        alignment: Alignment.center,
                        child: Text("大",style: GoogleFonts.longCang(height: 1.0,color: color,fontSize: 14,fontWeight: FontWeight.w600,shadows: [Shadow(color: Colors.grey.withOpacity(.4),blurRadius: 4)]),),
                      ),
                      Container(
                        width: 14,
                        alignment: Alignment.center,
                        child: Text("吉",style: GoogleFonts.longCang(height: 1.0,color: color,fontSize: 14,fontWeight: FontWeight.w600,shadows: [Shadow(color: Colors.white.withOpacity(.4),blurRadius: 4)])),
                      )
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
        Positioned(
            left: 4,
            top: 4,
            child: SizedBox(
              height: 24,
              width: 48,
              child:ColorFiltered(
                  colorFilter: ColorFilter.mode(backColor, BlendMode.srcIn),
                  child: Image.asset("assets/icons/xiang_yun_line_1.png",)),
            )
        ),
        Positioned(
            left: 0,
            bottom: 4,
            child: SizedBox(
              height: 24,
              width: 48,
              child:ColorFiltered(
                  colorFilter: ColorFilter.mode(backColor, BlendMode.srcIn),
                  child: Image.asset("assets/icons/xiang_yun_wen_l.png",)),
            )
        ),
        Positioned(
          right: 0,
          top: -4,
          child: SizedBox(
              height: 24,
              width: 48,
              child:ColorFiltered(
                  colorFilter: ColorFilter.mode(backColor, BlendMode.srcIn),
                  child: Image.asset("assets/icons/xiang_yun_wen_r.png",))),
        ),
      ],

    );
  }

  Widget shape_2(){

    Color backColor = Color.fromRGBO(252, 204, 140, 1);
    Color color = Color.fromRGBO(77, 79, 100, 1);
    Container dot1 = Container(
      height: 28,
      width: 28,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(.4),
              offset: Offset(0, 0), //阴影xy轴偏移量
              blurRadius: 4, //阴影模糊程度
              spreadRadius: 2, //阴影扩散程度
            )
          ]
      ),
    );
    Container dot2 =  Container(
      height: 22,
      width: 22,
      decoration: BoxDecoration(
        color:backColor,
        borderRadius: BorderRadius.circular(10),
      ),
    );
    Container dot3 =  Container(
      height: 20,
      width: 20,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
    );
    double width = 180;
    double height = 42;

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 200,
          height: 60,
          decoration: BoxDecoration(
            // color: Colors.orange,
            // borderRadius: BorderRadius.circular(10),
          ),
        ),
        Positioned(
          left: 4,
          child: dot1,
        ),
        Positioned(
          right: 4,
          child: dot1,
        ),
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 0), //阴影xy轴偏移量
                blurRadius: 4, //阴影模糊程度
                spreadRadius: 2, //阴影扩散程度
              )
            ]
          ),
        ),

        Positioned(
          left: 6,
          child:dot2,
        ),
        Positioned(
          right: 6,
          child: dot2,
        ),
        Container(
          width: width-4,
          height: height - 4,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              color: backColor
            // border: Border.all(color: Colors.white, width: 1),
          ),
        ),

        Positioned(
          left: 7,
          child: dot3,
        ),
        Positioned(
          right: 7,
          child: dot3,
        ),
        Container(
          width: width -6,
          height: height -6,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color:color
            // border: Border.all(color: Colors.white, width: 1),
          ),
        ),

        Container(
          width: 180,
          // child: Text("玉 女 守 门",style: GoogleFonts.maShanZheng(color: backColor,fontSize: 24),),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 17,),
              Text("玉 女 守 门",style: GoogleFonts.maShanZheng(color: backColor,fontSize: 24),),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 32,
                    width: 17,
                    child:ColorFiltered(
                        colorFilter: ColorFilter.mode(backColor, BlendMode.srcIn),
                        child: Image.asset("assets/icons/ji_xiong_yin_zhang.png",)),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 14,
                        // color: Colors.blue,
                        alignment: Alignment.center,
                        child: Text("大",style: GoogleFonts.longCang(height: 1.0,color: color,fontSize: 14,fontWeight: FontWeight.w600,shadows: [Shadow(color: Colors.grey.withOpacity(.4),blurRadius: 4)]),),
                      ),
                      Container(
                        width: 14,
                        alignment: Alignment.center,
                        child: Text("吉",style: GoogleFonts.longCang(height: 1.0,color: color,fontSize: 14,fontWeight: FontWeight.w600,shadows: [Shadow(color: Colors.white.withOpacity(.4),blurRadius: 4)])),
                      )
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
        Positioned(
            left: 4,
            top: 4,
            child: SizedBox(
              height: 24,
              width: 48,
              child:ColorFiltered(
                  colorFilter: ColorFilter.mode(backColor, BlendMode.srcIn),
                  child: Image.asset("assets/icons/xiang_yun_line_1.png",)),
            )
        ),
        Positioned(
          left: 0,
          bottom: 4,
          child: SizedBox(
              height: 24,
              width: 48,
              child:ColorFiltered(
              colorFilter: ColorFilter.mode(backColor, BlendMode.srcIn),
                  child: Image.asset("assets/icons/xiang_yun_wen_l.png",)),
          )
        ),
        Positioned(
          right: 0,
          top: -4,
          child: SizedBox(
              height: 24,
              width: 48,
    child:ColorFiltered(
    colorFilter: ColorFilter.mode(backColor, BlendMode.srcIn),
        child: Image.asset("assets/icons/xiang_yun_wen_r.png",))),
        ),
      ],

    );
  }
  Widget shape_1(){
    return  Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 200,
          height: 60,
          decoration: BoxDecoration(
            // color: Colors.orange,
            // borderRadius: BorderRadius.circular(10),
          ),
        ),
        Positioned(
          left: 4,
          child: Container(
            height: 20,
            width: 20,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        Positioned(
          right: 4,
          child: Container(
            height: 20,
            width: 20,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        Container(
          width: 180,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        Positioned(
          left: 6,
          child: Container(
            height: 16,
            width: 16,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        Positioned(
          right: 6,
          child: Container(
            height: 16,
            width: 16,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        Container(
          width: 176,
          height: 38,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white
            // border: Border.all(color: Colors.white, width: 1),
          ),
        ),

        Positioned(
          left: 7,
          child: Container(
            height: 14,
            width: 14,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        Positioned(
          right: 7,
          child: Container(
            height: 14,
            width: 14,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        Container(
          width: 174,
          height: 36,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.blue
            // border: Border.all(color: Colors.white, width: 1),
          ),
        ),

        // Positioned(
        //   right: 4,
        //   child: Container(
        //     height: 20,
        //     width: 20,
        //     decoration: BoxDecoration(
        //       color: Colors.blue,
        //       borderRadius: BorderRadius.circular(10),
        //     ),
        //   ),
        // ),
        //
        // Container(
        //   width: 180,
        //   height: 42,
        //   decoration: BoxDecoration(
        //     color: Colors.white,
        //     borderRadius: BorderRadius.circular(16),
        //   ),
        // ),
        // Container(
        //   width: 175,
        //   height: 36,
        //   decoration: BoxDecoration(
        //     borderRadius: BorderRadius.circular(16),
        //     color: Colors.blue
        //     // border: Border.all(color: Colors.white, width: 1),
        //   ),
        // ),

        // Positioned(
        //   left: 0,
        //   bottom: 4,
        //   child: SizedBox(
        //       height: 24,
        //       width: 48,
        //       child:Image.asset("assets/icons/xiang_yun_wen_l.png",)),
        // ),
        // Positioned(
        //   right: 0,
        //   top: -4,
        //   child: SizedBox(
        //       height: 24,
        //       width: 48,
        //       child:Image.asset("assets/icons/xiang_yun_wen_r.png",)),
        // ),
      ],

    );
  }

  Widget buildTenGanKeYingGeJuDetail(TenGanKeYingGeJu geJu){
    List<Widget> explainList = [];
    for (int i = 0; i <geJu.explains.length;i++){
      if (i != 0) explainList.add(const SizedBox(height: 8,));
      explainList.add(
            Text(
                geJu.explains[i],
                overflow: TextOverflow.visible,
                softWrap: true,
                style: TextStyle(fontWeight: FontWeight.w300, fontSize: 16,height: 1.2)
            ),
      );

    }
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: RichText(
                        text: TextSpan(
                            style: ConstantUiResourcesOfQiMen.tianGanTextStyle,
                            children: [
                              TextSpan(text: geJu.tianPan.name,style: ConstantUiResourcesOfQiMen.tianGanTextStyle.copyWith(color:ConstResourcesMapper.zodiacGanColors[geJu.tianPan])),
                              TextSpan(text:"+"),
                              TextSpan(text: geJu.diPan.name,style: ConstantUiResourcesOfQiMen.tianGanTextStyle.copyWith(color:ConstResourcesMapper.zodiacGanColors[geJu.diPan])),
                            ]
                        ),
                      ),
                    ),
                    Divider(height: 4,),
                    RichText(
                      text: TextSpan(
                        // style: ConstantUiResourcesOfQiMen.tianGanTextStyle,
                          text: geJu.geJuNames.join("、"),
                          style: TextStyle(fontWeight: FontWeight.w600)
                      ),
                    )


                  ],
                ),
              ),
              SizedBox(width: 8,),
              // buildTenGanKeYingYinZhang(geJu.geJuNames.first,geJu.jiXiong)
              TenGanKeYingYinZhang(
                  geJuName:geJu.geJuNames.first,
                  jiXiong:geJu.jiXiong,
                  size:const Size(48,48),
                  textStyle:GoogleFonts.maShanZheng(height: 1.0,fontSize: 18,fontWeight: FontWeight.w500,color: Colors.white),
              )
            ],
          ),
          SizedBox(height: 8,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: explainList,
          )
        ]


    );
  }

  Widget buildTenGanKeYingYinZhang(String geJuName,JiXiongEnum jiXiong){
    List<String> juName = geJuName.split("");
    String yinZhang0 = juName[0];
    String yinZhang1 = juName[1];
    String yinZhang2 = juName[2];
    String yinZhang3 = juName[3];
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                ConstResourcesMapper.jiXiongColorMapper[jiXiong]!,
                  // Colors.blueGrey.shade700,
                  BlendMode.srcIn),
              child: Image.asset("assets/icons/yin_zhang.png",width: 32,height: 32,)),
        ),
        Container(
          height: 44,
          width: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children:[
                  AutoSizeText(
                      yinZhang2,
                    style: GoogleFonts.maShanZheng(height: 1.0,fontSize: 18,fontWeight: FontWeight.w500,color: Colors.white),
                    maxLines: 1,
                    maxFontSize: 24,
                    minFontSize: 12,
                  ),
                  AutoSizeText(
                    yinZhang3,
                    style: GoogleFonts.maShanZheng(height: 1.0,fontSize: 18,fontWeight: FontWeight.w500,color: Colors.white),
                    maxLines: 1,
                    maxFontSize: 24,
                    minFontSize: 12,
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children:[
                  AutoSizeText(
                    yinZhang0,
                    style: GoogleFonts.maShanZheng(height: 1.0,fontSize: 18,fontWeight: FontWeight.w500,color: Colors.white),
                    maxLines: 1,
                    maxFontSize: 24,
                    minFontSize: 12,
                  ),
                  AutoSizeText(
                    yinZhang1,
                    style: GoogleFonts.maShanZheng(height: 1.0,fontSize: 18,fontWeight: FontWeight.w500,color: Colors.white),
                    maxLines: 1,
                    maxFontSize: 24,
                    minFontSize: 12,
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _gong_v1(double cardSize){

    double centerWidth = cardSize * .4;
    double sideWidth = cardSize * .3;
    double tianGanSideWidth = sideWidth * .6;
    double paddingSideWidth = sideWidth * .4;
    double tianGanSideHeight = cardSize * .5;
    double paddingSideHeight = cardSize * .25;
    return AnimatedContainer(
      duration: Duration.zero,
      width: cardSize,
      height: cardSize,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 3,
            )
          ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: sideWidth,
            height: cardSize,
            color: Colors.red.withOpacity(.1),
            child: Column(
              children: [
                Container(
                  width: sideWidth,
                  height: paddingSideHeight,
                  color: Colors.blue.withOpacity(.2),
                ),
                Row(
                  children: [
                    Container(
                      width: paddingSideWidth,
                      height: tianGanSideHeight,
                      color: Colors.orange.withOpacity(.2),
                    ),
                    Container(
                      width: tianGanSideWidth,
                      height: tianGanSideHeight,
                      color: Colors.white.withOpacity(.2),
                    )
                  ],
                ),
                Container(
                  width:sideWidth,
                  height: paddingSideHeight,
                  color: Colors.blue.withOpacity(.2),
                )
              ],
            ),
          ),
          Column(
            children: [
              Container(
                width: centerWidth,
                height: paddingSideWidth,
                color: Colors.orange.withOpacity(.1),
              ),
              Container(
                width: centerWidth,
                height: cardSize - paddingSideWidth * 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      // color: Colors.black87.withOpacity(.1),
                        child: _gods("值符",centerWidth,centerWidth * .25,showHint: true)
                    ),
                    Container(
                      // color: Colors.blue.withOpacity(.1),
                      child: _stars("天芮",centerWidth,centerWidth * .25,true,true,showHint: true),
                    ),
                    Container(
                      child: _doors("休门",centerWidth,centerWidth * .25,showHint: true),
                    )
                  ],
                ),
              ),
              Container(
                width: centerWidth,
                height: paddingSideWidth,
                color: Colors.orange.withOpacity(.1),
              ),
            ],
          ),
          Container(
            width: sideWidth,
            height: cardSize,
            color: Colors.red.withOpacity(.1),
            child: Column(
              children: [
                Container(
                  width: sideWidth,
                  height: paddingSideHeight,
                  color: Colors.blue.withOpacity(.2),
                ),
                Row(
                  children: [
                    Container(
                      width: tianGanSideWidth,
                      height: tianGanSideHeight,
                      color: Colors.white.withOpacity(.2),
                    ),
                    Container(
                      width: paddingSideWidth,
                      height: tianGanSideHeight,
                      color: Colors.orange.withOpacity(.2),
                    )
                  ],
                ),
                Container(
                  width: sideWidth,
                  height: paddingSideHeight,
                  color: Colors.blue.withOpacity(.2),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _gods_v1(String godName) {
    bool isZhiFu = godName == "值符";
    Duration duration = const Duration(milliseconds: 400);
    return ValueListenableBuilder(
        valueListenable: slideWidthNotifier,
        builder: (ctx, width, child) {
          double centerBoxWidth = width;
          if (centerBoxWidth < 24) {
            centerBoxWidth = 24;
          }
          double centerBoxHeight = width * .5;
          double totalWidth = centerBoxWidth + 12+12;
          // double sideWidth = centerBoxWidth * .25;
          double sideWidth = 12;
          return ValueListenableBuilder(
              valueListenable: showHintNotifier,
              builder: (ctx, showHint, _) {
                return AnimatedContainer(
                  duration: Duration(milliseconds: 100),
                  height: centerBoxHeight,
                  width: showHint?totalWidth:centerBoxWidth,
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isZhiFu)
                        Positioned(
                            bottom: -2,
                            child: _buildZhiShiDoor(centerBoxWidth + 24)
                        ),
                      Positioned(
                        top: 0,
                        child: Container(
                            color: Colors.blueAccent.withOpacity(.2),
                            height: centerBoxHeight,
                            width: totalWidth,

                            child:Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Stack(
                                  children: [
                                    Row(
                                      children: [
                                        wangShuaText(centerBoxHeight, sideWidth, showHint,duration),
                                        Container(
                                          alignment: Alignment.center,
                                          height: centerBoxHeight,
                                          width: centerBoxWidth,
                                          child: Text(godName,
                                            maxLines: 1,
                                            style: ConstantUiResourcesOfQiMen
                                                .nineStarTextStyle.copyWith(
                                                fontSize: width / 2),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Positioned(
                                      left: 1,
                                      top: 0,
                                      child: ValueListenableBuilder(
                                          valueListenable: showTextHintNotifier,
                                          builder: (ctx, showTextHint, _) {
                                            return AnimatedSwitcher(
                                              duration: duration,
                                              transitionBuilder: (
                                                  Widget child, Animation<
                                                      double> animation) {
                                                return SlideTransition(
                                                  position: Tween<Offset>(
                                                    end: const Offset(0, 0),
                                                    begin: const Offset(
                                                        0, 0),
                                                  ).animate(animation),
                                                  child: FadeTransition(
                                                    opacity: animation,
                                                    child: child,
                                                  ),
                                                );
                                              },
                                              child: showHint &&
                                                  !showTextHint
                                                  ? _buildThreeArrowHint(
                                                  true, Colors.red, 16)
                                                  : Container(),
                                            );
                                          }
                                      ),
                                      // child: _buildTwoArrowHint(true,Colors.red,24)
                                    ),
                                    Positioned(
                                      left: 2,
                                      bottom: 0,
                                      child: ValueListenableBuilder(
                                          valueListenable: showTextHintNotifier,
                                          builder: (ctx, showTextHint, _) {
                                            return AnimatedSwitcher(
                                              duration: duration,
                                              transitionBuilder: (
                                                  Widget child, Animation<
                                                      double> animation) {
                                                return SlideTransition(
                                                  position: Tween<Offset>(
                                                    end: const Offset(0, 0),
                                                    begin: const Offset(
                                                        0, 0),
                                                  ).animate(animation),
                                                  child: FadeTransition(
                                                    opacity: animation,
                                                    child: child,
                                                  ),
                                                );
                                              },
                                              child: showHint &&
                                                  !showTextHint
                                                  ? _buildThreeArrowHint(
                                                  false, Colors.black54, 16)
                                                  : Container(),
                                            );
                                          }
                                      ),
                                    ),
                                  ],
                                ),
                                AnimatedContainer(
                                  duration: duration,
                                  // color: Colors.orange.withOpacity(.1),
                                  width: showHint?sideWidth:0,
                                ),
                              ],
                            )

                        ),
                      )
                    ],
                  ),
                );
              });
        });
  }
  Widget _doors_v1(String doorName){
    return ValueListenableBuilder(
        valueListenable: slideWidthNotifier,
        builder: (ctx, width,child){
          double centerBoxWidth = width;
          if (centerBoxWidth < 24){
            centerBoxWidth = 24;
          }
          double centerBoxHeight = width * .5;
          double totalWidth = width * 1.5;
          // double sideWidth = centerBoxWidth * .25;
          double sideWidth = 12;
          return ValueListenableBuilder(
              valueListenable: isZhiShiDoor,
              builder: (ctx,isZhiShiDoor,_){
                return Container(
                  height: centerBoxHeight,
                  width: totalWidth,
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                          bottom: -2,
                          child: _buildZhiShiDoor(centerBoxWidth+24)
                      ),
                      Positioned(
                        top:0,
                        child: SizedBox(
                          height: centerBoxHeight,
                          width:totalWidth,
                          child: ValueListenableBuilder(
                              valueListenable: showHintNotifier,
                              builder: (ctx,showHint,_) {
                                return  Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Stack(
                                      children: [
                                        Row(
                                          children: [
                                            ValueListenableBuilder(
                                              valueListenable: showTextHintNotifier,
                                              builder: (context, bool showTextHint, child) {
                                                return showTextHint
                                                    ?wangShuaText(centerBoxHeight, sideWidth, showHint,Duration(milliseconds: 400))
                                                    : AnimatedContainer(
                                                  duration: Duration(milliseconds: 400),
                                                  height: centerBoxHeight,
                                                  width: showHint?sideWidth:0,
                                                  alignment: Alignment.centerRight,
                                                );
                                              },
                                            ),
                                            Container(
                                              alignment: Alignment.center,
                                              height: centerBoxHeight,
                                              width: centerBoxWidth,
                                              // color: Colors.orange.withOpacity(.2),
                                              child:Text(doorName,
                                                maxLines: 1,
                                                style: ConstantUiResourcesOfQiMen.nineStarTextStyle.copyWith(fontSize: width/2),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Positioned(
                                          left: 1,
                                          top:0,
                                          child:ValueListenableBuilder(
                                              valueListenable: showTextHintNotifier,
                                              builder:(ctx,showTextHint,_){
                                                return AnimatedSwitcher(
                                                  duration: Duration(milliseconds: 400),
                                                  transitionBuilder: (Widget child, Animation<double> animation) {
                                                    return SlideTransition(
                                                      position: Tween<Offset>(
                                                        end: const Offset(0, 0),
                                                        begin: const Offset(0, 0),
                                                      ).animate(animation),
                                                      child: FadeTransition(
                                                        opacity: animation,
                                                        child: child,
                                                      ),
                                                    );
                                                  },
                                                  child: showHint&&!showTextHint?_buildThreeArrowHint(true,Colors.red,16):Container(),
                                                );
                                              }
                                          ),
                                          // child: _buildTwoArrowHint(true,Colors.red,24)
                                        ),
                                        Positioned(
                                          left: 2,
                                          bottom:0,
                                          child:ValueListenableBuilder(
                                              valueListenable: showTextHintNotifier,
                                              builder:(ctx,showTextHint,_){
                                                return AnimatedSwitcher(
                                                  duration: Duration(milliseconds: 400),
                                                  transitionBuilder: (Widget child, Animation<double> animation) {
                                                    return SlideTransition(
                                                      position: Tween<Offset>(
                                                        end: const Offset(0, 0),
                                                        begin: const Offset(0, 0),
                                                      ).animate(animation),
                                                      child: FadeTransition(
                                                        opacity: animation,
                                                        child: child,
                                                      ),
                                                    );
                                                  },
                                                  child: showHint&&!showTextHint?_buildThreeArrowHint(false,Colors.black54,16):Container(),
                                                );
                                              }
                                          ),
                                        ),
                                      ],
                                    ),
                                    AnimatedContainer(
                                      duration: Duration(milliseconds: 400),
                                      height: centerBoxHeight,
                                      width: showHint?sideWidth:0,
                                      alignment: Alignment.centerLeft,
                                      child: AnimatedSwitcher(
                                        duration: Duration(milliseconds: 400),
                                        transitionBuilder: (Widget child, Animation<double> animation) {
                                          return SlideTransition(
                                            position: Tween<Offset>(
                                              end: const Offset(0, 0),
                                              begin: const Offset(-1, 0),
                                            ).animate(animation),
                                            child: FadeTransition(
                                              opacity: animation,
                                              child: child,
                                            ),
                                          );
                                        },
                                        child: showHint
                                            ?buildDescYinZhang("门迫","迫",sideWidth,centerBoxHeight)
                                            :Container(),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                        ),
                      )
                    ],
                  ),
                );
              }
          );
        });
  }
  Widget _buildArrowUp(Color color,Size size){
    return RotatedBox(
      quarterTurns: -2,
      child: Lottie.asset(
          'assets/lotties/arrow_up.json',
          width: size.width,
          height: size.height,
          delegates:LottieDelegates(
              values:[
                ValueDelegate.colorFilter(
                  ["Arrow-Down Outlines","**"],
                  value: ColorFilter.mode(color, BlendMode.src),
                )
              ]
          )
      ),
    );
  }
  
  Widget _buildQiMenGong(){
    return ValueListenableBuilder(
        valueListenable: showHintNotifier,
        builder: (ctx,showHint,_){
          print("showHint $showHint");
          TextStyle hintFontStyle = TextStyle(color: Colors.black54,height: 1,fontSize: 8,);
          List<Shadow> shadows = [
            Shadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 1,
                offset: Offset(1, 1)
            )
          ];
          return Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 1,
                  )
                ]
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 200),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(1, 0),
                                end: const Offset(0, 0),
                              ).animate(animation),
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                          child:!showHint?Container():Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("旺",style: hintFontStyle),
                              Text("衰",style: hintFontStyle)
                            ],
                          ),
                        ),
                        Text("辛",style: ConstantUiResourcesOfQiMen.tianGanTextStyle.copyWith(fontSize: 16,shadows: shadows))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 200),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(1, 0),
                                end: const Offset(0, 0),
                              ).animate(animation),
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                          child:!showHint?Container():Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("旺",style: hintFontStyle),
                              Text("衰",style: hintFontStyle)
                            ],
                          ),
                        ),
                        Text("辛",style: ConstantUiResourcesOfQiMen.tianGanTextStyle.copyWith(fontSize: 16,shadows: shadows))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 200),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(1, 0),
                                end: const Offset(0, 0),
                              ).animate(animation),
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                          child:!showHint?Container():Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("旺",style: hintFontStyle),
                              Text("衰",style: hintFontStyle)
                            ],
                          ),
                        ),
                        Text("辛",style: ConstantUiResourcesOfQiMen.tianGanTextStyle.copyWith(fontSize: 16,shadows: shadows))
                      ],
                    )
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 200),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(1, 0),
                                end: const Offset(0, 0),
                              ).animate(animation),
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                          child:!showHint?Container(width: hintFontStyle.fontSize,):Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("旺",style: hintFontStyle),
                              Text("衰",style: hintFontStyle)
                            ],
                          ),
                        ),
                        Text("值符",style: ConstantUiResourcesOfQiMen.nineStarTextStyle.copyWith(fontSize: 16,shadows: shadows)),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("天禽",style: ConstantUiResourcesOfQiMen.nineStarTextStyle.copyWith(fontSize: 12,shadows: shadows)),

                                AnimatedSwitcher(
                                  duration: Duration(milliseconds: 200),
                                  transitionBuilder: (Widget child, Animation<double> animation) {
                                    return SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(-1, 0),
                                        end: const Offset(0, 0),
                                      ).animate(animation),
                                      child: FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child:!showHint?Container():Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text("旺",style: hintFontStyle),
                                      Text("衰",style: hintFontStyle)
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                AnimatedSwitcher(
                                  duration: Duration(milliseconds: 200),
                                  transitionBuilder: (Widget child, Animation<double> animation) {
                                    return SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(1, 0),
                                        end: const Offset(0, 0),
                                      ).animate(animation),
                                      child: FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child:!showHint?Container():Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text("旺",style: hintFontStyle),
                                      Text("衰",style: hintFontStyle)
                                    ],
                                  ),
                                ),
                                Text("天芮",style: ConstantUiResourcesOfQiMen.nineStarTextStyle.copyWith(fontSize: 16,shadows: shadows)),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                AnimatedSwitcher(
                                  duration: Duration(milliseconds: 200),
                                  transitionBuilder: (Widget child, Animation<double> animation) {
                                    return SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(1, 0),
                                        end: const Offset(0, 0),
                                      ).animate(animation),
                                      child: FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child:!showHint?Container():Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text("旺",style: hintFontStyle),
                                      Text("衰",style: hintFontStyle)
                                    ],
                                  ),
                                ),

                                Text("生门",style: ConstantUiResourcesOfQiMen.nineStarTextStyle.copyWith(fontSize: 16,shadows: shadows)),
                              ],
                            ),
                            Text("太阴",style: ConstantUiResourcesOfQiMen.nineStarTextStyle.copyWith(fontSize: 12,color: Colors.grey)),
                          ],
                        )
                      ],
                    )
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AnimatedSwitcher(
                              duration: Duration(milliseconds: 200),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 1),
                                    end: const Offset(0, 0),
                                  ).animate(animation),
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child:!showHint?Container():Text("帝",style: TextStyle(height: 1,fontSize: 8),),
                            ),
                            Text("丙",style: ConstantUiResourcesOfQiMen.tianGanTextStyle.copyWith(fontSize: 16,shadows: shadows)),
                            AnimatedSwitcher(
                              duration: Duration(milliseconds: 200),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, -1),
                                    end: const Offset(0, 0),
                                  ).animate(animation),
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child:!showHint?Container():Text("沐",style: TextStyle(height: 1,fontSize: 8),),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AnimatedSwitcher(
                              duration: Duration(milliseconds: 200),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 1),
                                    end: const Offset(0, 0),
                                  ).animate(animation),
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child:!showHint?Container():Text("帝",style: TextStyle(height: 1,fontSize: 8),),
                            ),
                            Text("丙",style: ConstantUiResourcesOfQiMen.tianGanTextStyle.copyWith(fontSize: 12,shadows: shadows)),
                            AnimatedSwitcher(
                              duration: Duration(milliseconds: 200),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, -1),
                                    end: const Offset(0, 0),
                                  ).animate(animation),
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child:!showHint?Container():Text("沐",style: TextStyle(height: 1,fontSize: 8),),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AnimatedSwitcher(
                              duration: Duration(milliseconds: 200),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 1),
                                    end: const Offset(0, 0),
                                  ).animate(animation),
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child:!showHint?Container():Text("帝",style: TextStyle(height: 1,fontSize: 8),),
                            ),
                            Text("丙",style: ConstantUiResourcesOfQiMen.tianGanTextStyle.copyWith(fontSize: 16,shadows: shadows)),
                            AnimatedSwitcher(
                              duration: Duration(milliseconds: 200),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, -1),
                                    end: const Offset(0, 0),
                                  ).animate(animation),
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child:!showHint?Container():Text("沐",style: TextStyle(height: 1,fontSize: 8),),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AnimatedSwitcher(
                              duration: Duration(milliseconds: 200),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 1),
                                    end: const Offset(0, 0),
                                  ).animate(animation),
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child:!showHint?Container():Text("帝",style: TextStyle(height: 1,fontSize: 8),),
                            ),
                            Text("丙",style: ConstantUiResourcesOfQiMen.tianGanTextStyle.copyWith(fontSize: 12,shadows: shadows)),
                            AnimatedSwitcher(
                              duration: Duration(milliseconds: 200),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, -1),
                                    end: const Offset(0, 0),
                                  ).animate(animation),
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child:!showHint?Container():Text("沐",style: TextStyle(height: 1,fontSize: 8),),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
          // return _gong(width,showHint,true,true);
        });
  }
  Widget buildCenterPanTime(){
    DateTime now = DateTime.now();
    Lunar lunar = Lunar.fromDate(now);
    TextStyle normalTextStyle =  GoogleFonts.zhiMangXing(color:Color.fromRGBO(49,37,32,1),fontSize: 16,height: 1.0);

    return Container(
        alignment: Alignment.center,
        width:  250,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Color.fromRGBO(255,242,223, 1),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
              )
            ]
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(flex:3,child: Text("时间：",style: normalTextStyle,)),
                  Flexible(flex:7,child: Text(DateFormat("yyyy/MM/dd HH:mm").format(now),style: normalTextStyle,)),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(flex:3,child: Text("农历：",style: normalTextStyle)),
                  Flexible(flex:7,child: Text("${lunar.getYearInGanZhi()}年 ${lunar.getMonthInChinese()}月 ${lunar.getDayInChinese()} ${lunar.getTimeZhi()}时",style: normalTextStyle)),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(flex:3,child: Text("${lunar.getPrevJieQi().getName()}：",style: normalTextStyle)),
                  Flexible(flex:7,child: Text(lunar.getPrevJieQi().getSolar().toYmdHms().replaceAll("-", "/"),style:normalTextStyle,)),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Flexible(flex:3,child: Text("值符门：")),
                  Flexible(flex:3,child: Text("${lunar.getNextJieQi().getName()}：",style: normalTextStyle)),
                  Flexible(flex:7,child: Text(lunar.getNextJieQi().getSolar().toYmdHms().replaceAll("-", "/"),style: normalTextStyle,)),
                ],
              )
            ]
        )
    );
  }
}

