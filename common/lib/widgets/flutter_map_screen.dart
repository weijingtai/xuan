import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:common/datamodel/basic_person_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';
import 'package:geojson_vi/geojson_vi.dart';
import 'package:topojson/topojson.dart' as topojson;

import '../datamodel/location.dart';

class FlutterMapScreen extends StatefulWidget {
  // final Address seekerAreaLocation;
  // Coordinates? seekerCoordinate;
  // Coordinates? seerCoordinate;
  Location? seekerLocation;
  Location? seerLocation;
  IconData? seekerIcon;
  FlutterMapScreen({super.key, this.seerLocation, this.seekerLocation});

  @override
  State<FlutterMapScreen> createState() => _FlutterMapScreenState();
}

class _FlutterMapScreenState extends State<FlutterMapScreen>
    with SingleTickerProviderStateMixin {
  final Logger _l =
      Logger(level: Level.trace, printer: PrettyPrinter(errorMethodCount: 16));
  // 标记列表
  final List<Marker> _markers = [];
  List<Polygon>? _polygons;
  late LatLng seekerCoordinate;
  late LatLng? seerPoint;
  // Coordinates get seekerCoordinate => widget.seekerCoordinate ?? widget.seekerAreaLocation.coordinates;

  late Marker? seerLocationMarker;
  late Marker? centerMaker;
  final ValueNotifier<List<Marker>> _markerValueNotifier =
      ValueNotifier<List<Marker>>([]);
  late final MapController mapController;
  LatLng get locationCenterPoint => LatLng(
      widget.seekerLocation!.address!.coordinates.latitude,
      widget.seekerLocation!.address!.coordinates!.longitude);

  late AnimationController _animationController;
  late Animation<double> _firstZoomAnimation;
  late Animation<LatLng> _positionAnimation;
  late Animation<double> _lastZoomAnimation;

  late double startAnimationZoom;
  LatLng? startAnimationLatLng;
  LatLng? _newSeekerPointCenter;

  //
  //
  // late AnimationController _controller;
  // late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    seekerCoordinate = LatLng(
        widget.seekerLocation!.address!.coordinates.latitude,
        widget.seekerLocation!.address!.coordinates.longitude);

    if (widget.seerLocation?.coordinates != null) {
      seerPoint = LatLng(widget.seerLocation!.coordinates!.latitude,
          widget.seerLocation!.coordinates!.longitude);
    } else {
      seerPoint = null;
    }
    if (widget.seekerLocation?.address?.coordinates != null) {
      _newSeekerPointCenter = LatLng(
          widget.seekerLocation!.coordinates!.latitude,
          widget.seekerLocation!.coordinates!.longitude);
    }
    mapController = MapController();
    // 初始化动画控制器
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() {
        if (startAnimationLatLng != null) {
          mapController.move(startAnimationLatLng!, startAnimationZoom);
        }
      });

    // 创建复合动画
    if (seerPoint != null) {
      _createAnimations(seerPoint!);
    }

    // 延迟启动动画确保地图加载完成
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(seconds: 1)).then((val) {
        _animationController.forward();
      });
    });
  }

  TextStyle locationTextStyle = const TextStyle(
      height: 1,
      fontSize: 14,
      color: Colors.black45,
      fontWeight: FontWeight.w600,
      fontFamily: "NotoSansSC-Regular",
      shadows: [
        Shadow(
          color: Colors.black38,
        )
      ]);
  TextStyle lngLatTextStyle = const TextStyle(
      fontSize: 14, color: Colors.black87, fontFamily: "NotoSansSC-Regular");

  // 执行动画序列
  double iconSize = 48;
  Marker buildMouseMarker(LatLng point) {
    return Marker(
        width: iconSize,
        height: 48 + 48,
        point: point,
        child: Column(
          children: [
            Container(
              height: 48,
              alignment: Alignment.topCenter,
              child: Icon(
                Icons.location_on_sharp,
                color: Colors.red.withAlpha(100),
                size: 48,
              ),
            ),
            Container(
              height: 48,
              // width: 256,
              // decoration: BoxDecoration(
              //     color: Colors.white.withAlpha(180),
              //   borderRadius: BorderRadius.circular(24),
              // ),
              // child: Text.rich(
              //   TextSpan(
              //       style: lngLatTextStyle.copyWith(color: Colors.black87,fontSize: 16,fontWeight: FontWeight.w600),
              //       children: [
              //         TextSpan(
              //             text:"${point.longitude}, ${point.latitude}"
              //         )
              //       ]
              //   ),
              // ),
            ),
          ],
        ));
  }

  Marker buildSeerMarker(LatLng seerPoint) {
    double titleWidth = 16 * 5;
    return Marker(
        width: titleWidth,
        height: iconSize * 2,
        point: seerPoint,
        child: Column(
          children: [
            Container(
              height: iconSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 第一层模糊阴影
                  Transform.translate(
                    offset: Offset(1, 1),
                    child: Icon(
                      Icons.location_history_rounded,
                      color: Colors.black.withAlpha(100),
                      size: iconSize,
                    ),
                  ),
                  // 主图标
                  Icon(
                    Icons.location_history_rounded,
                    color: Colors.blue,
                    size: iconSize,
                  )
                ],
              ),
            ),
            Container(
              alignment: Alignment.topCenter,
              height: iconSize,
              width: titleWidth,
              child: Container(
                  height: iconSize * .5,
                  width: titleWidth,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(180),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text.rich(TextSpan(
                    text: "我的位置",
                    style: lngLatTextStyle.copyWith(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.normal),
                  ))),
            )
          ],
        ));
  }

  Marker? get seerMarker =>
      seerPoint != null ? buildSeerMarker(seerPoint!) : null;
  Marker get seekerAreaMarker => _buildSeekerAreaCenterMarker();
  Widget _buildSeekerAreaCenterMarkerIcon() {
    final Address location = widget.seekerLocation!.address!;
    return Column(
      children: [
        Opacity(
          opacity: _newSeekerPointCenter == null ? 1 : 0.5,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 第一层模糊阴影
              Transform.translate(
                offset: Offset(1, 1),
                child: Icon(
                  widget.seekerIcon ?? Icons.location_history,
                  color: Colors.black.withAlpha(100),
                  size: iconSize,
                ),
              ),
              // 主图标
              Icon(
                widget.seekerIcon ?? Icons.location_history,
                color: Colors.black87,
                size: iconSize,
              )
            ],
          ),
        ),
        SizedBox(
          height: 8,
        ),
        Container(
            alignment: Alignment.center,
            width: 256,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(180),
              borderRadius: BorderRadius.all(Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 32,
                ),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text.rich(
                        TextSpan(
                            style: lngLatTextStyle.copyWith(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                            children: [
                              TextSpan(
                                  text:
                                      "${location.lowestGeoLocation.coordinates.longitude}, ${location.lowestGeoLocation.coordinates.latitude}")
                            ]),
                      ),
                      Text.rich(TextSpan(
                          text:
                              "(${location.province.name} · ${location.city?.name}",
                          style: locationTextStyle,
                          children: [
                            if (location.area != null)
                              TextSpan(
                                text: " · ${location.area!.name}",
                                // style: locationTextStyle,
                              ),
                            TextSpan(text: ")"),
                            // WidgetSpan(
                            //     child: )
                          ])),
                      Text.rich(
                        TextSpan(
                            text: "(行政中心坐标)",
                            style: lngLatTextStyle.copyWith(
                                color: Colors.black45)),
                      )
                    ]),
                InkWell(
                  radius: 16,
                  onTap: resetLocationCenterAsSeerLocation,
                  child: Icon(
                    Icons.my_location,
                    size: 16,
                  ),
                )
              ],
            ))
      ],
    );
  }

  Marker _buildSeekerAreaCenterMarker() {
    // Location location = widget.seekerAreaLocation;
    return Marker(
        width: 256,
        height: iconSize + 68,
        point: LatLng(widget.seekerLocation!.coordinates!.latitude,
            widget.seekerLocation!.coordinates!.longitude),
        child: _buildSeekerAreaCenterMarkerIcon());
  }

  void resetLocationCenterAsSeerLocation() {
    UnimplementedError();
  }

  void _createAnimations(LatLng seerPoint) {
    // 缩放动画：14 → 11
    startAnimationZoom = 14;
    startAnimationLatLng = seerPoint;
    _firstZoomAnimation = Tween<double>(begin: 14, end: 8).animate(
      CurvedAnimation(
          parent: _animationController,
          // curve: Curves.easeInOut,
          curve: Interval(0, 0.3, curve: Curves.easeInOut)),
    )..addListener(() {
        startAnimationZoom = _firstZoomAnimation.value;
      });

    // // 位置动画：A → B
    _positionAnimation = LatLngTween(
      begin: seerPoint,
      end: locationCenterPoint,
    ).animate(
      CurvedAnimation(
          parent: _animationController,
          curve: Interval(0.3, 0.8, curve: Curves.linear)),
    )..addListener(() {
        startAnimationLatLng = _positionAnimation.value;
      });
    _lastZoomAnimation = Tween<double>(begin: 8, end: 12).animate(
      CurvedAnimation(
          parent: _animationController,
          // curve: Curves.easeInOut,
          curve: Interval(0.8, 1, curve: Curves.easeInOut)),
    )..addListener(() {
        startAnimationZoom = _lastZoomAnimation.value;
      });
  }

  @override
  void dispose() {
    _markerValueNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: _newSeekerPointCenter == null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 32,
                    ),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text.rich(
                            TextSpan(
                                style: lngLatTextStyle.copyWith(
                                    color: Colors.black87,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                                children: [
                                  TextSpan(
                                      text:
                                          "${widget.seekerLocation!.address!.lowestGeoLocation.coordinates.longitude}, ${widget.seekerLocation!.address!.lowestGeoLocation.coordinates.latitude}"),
                                  if (_mouseCircleCenter != null)
                                    TextSpan(
                                        text:
                                            " -> ${_mouseCircleCenter!.longitude.toStringAsFixed(5)}, ${_mouseCircleCenter!.latitude.toStringAsFixed(5)}",
                                        style: TextStyle(color: Colors.blue))
                                ]),
                          ),
                          Text.rich(TextSpan(
                              text:
                                  "${widget.seekerLocation!.address!.province.name} · ${widget.seekerLocation!.address!.city?.name}",
                              style: locationTextStyle,
                              children: [
                                if (widget.seekerLocation!.address!.area !=
                                    null)
                                  TextSpan(
                                    text:
                                        " · ${widget.seekerLocation!.address!.area!.name}",
                                    // style: locationTextStyle,
                                  ),
                                TextSpan(
                                    text: "（行政中心坐标）",
                                    style: locationTextStyle.copyWith(
                                        fontWeight: FontWeight.bold)),
                                // WidgetSpan(
                                //     child: )
                              ])),
                          // Text.rich(
                          //   TextSpan(text:"(行政中心坐标)",style: lngLatTextStyle.copyWith(color: Colors.black45)),
                          // )
                        ]),
                    InkWell(
                      radius: 16,
                      onTap: resetLocationCenterAsSeerLocation,
                      child: Icon(
                        Icons.my_location,
                        size: 16,
                      ),
                    )
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                      Text.rich(
                        TextSpan(
                            style: lngLatTextStyle.copyWith(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                            children: [
                              TextSpan(
                                  text:
                                      "${_newSeekerPointCenter!.longitude.toStringAsFixed(5)}, ${_newSeekerPointCenter!.latitude.toStringAsFixed(5)}")
                            ]),
                      ),
                      Text.rich(
                        TextSpan(
                            style: lngLatTextStyle.copyWith(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                            children: [TextSpan(text: "（千米内距离误差）")]),
                      ),
                    ]),
          actions: [
            TextButton(
                onPressed: _newSeekerPointCenter == null
                    ? null
                    : () {
                        Navigator.pop(
                            context,
                            Coordinates(
                                latitude: _newSeekerPointCenter!.latitude,
                                longitude: _newSeekerPointCenter!.longitude));
                      },
                child: Text("确定"))
          ],
        ),
        body: buildMap(widget.seerLocation?.coordinates ??
            widget.seekerLocation!.address!.coordinates));
  }

  void _buildTimeZonePolygons() {
    fetchTimezonesGeoJSONFromLocal().then((val) {
      GeoJSONFeatureCollection geoJSONFeatureCollection =
          (val as GeoJSONFeatureCollection);
      // geoJSONFeatureCollection.features.forEach((e) {
      //   print(e?.geometry?.type);
      // });
      List<GeoJSONFeature> list = geoJSONFeatureCollection.features
          .where((element) => element != null)
          .map((e) => e!)
          .toList();
      _l.d(list.length);
      List<Polygon> _tmpPolygon = [];
      for (var f in list) {
        // _l.d(f.geometry?.type);
        if (f.geometry!.type == GeoJSONType.polygon) {
          final coordinates =
              (f.geometry as GeoJSONPolygon).coordinates[0] as List<dynamic>;
          List<LatLng> points = [];
          coordinates.forEach((coord) {
            // 如果 lng 的大于 180.0则设置为180.0;
            final lng = coord[0] as double;
            final lat = coord[1] as double;
            points.add(LatLng(lat, lng));
          });
          _tmpPolygon.add(
            Polygon(
              points: points,
              color: Colors.blue.withValues(alpha: 0.3),
              borderColor: Colors.blue,
              borderStrokeWidth: 2,
            ),
          );
        } else if (f.geometry!.type == GeoJSONType.multiPolygon) {
          _l.d("type is MultiPolygon");
          final multiCoordinates =
              (f.geometry as GeoJSONMultiPolygon).coordinates as List<dynamic>;
          for (final polygonCoordinates in multiCoordinates) {
            for (final ringCoordinates in polygonCoordinates) {
              List<LatLng> points = [];
              ringCoordinates.forEach((coord) {
                final lng = coord[0] as double;
                final lat = coord[1] as double;
                points.add(LatLng(lat, lng));
              });
              _tmpPolygon.add(
                Polygon(
                  points: points,
                  color: Colors.blue.withAlpha(80),
                  borderColor: Colors.blue,
                  borderStrokeWidth: 2,
                ),
              );
            }
          }
        }
      }
      _polygons = _tmpPolygon;
      // _l.d(_polygons);
      //

      // _polygons = res;
      setState(() {});
    });
  }

  void _buildAreaPolygons() {
    fetchGeoJSONFromLocalStorage(widget.seekerLocation!.address!).then((val) {
      _polygons = val;
      _l.d(_polygons);
      setState(() {});
    });
  }

  // 生成圆形顶点（36个点，间隔10°）
  List<LatLng> _generateCirclePoints() {
    List<LatLng> points = [];
    LatLng center = centerMaker!.point;
    double latRadians = center.latitude * (pi / 180);
    double metersPerDegreeLat = 110570; // 纬度1度≈110,570米
    double metersPerDegreeLng = 111320 * cos(latRadians); // 经度1度对应米数

    for (int i = 0; i < 360; i += 10) {
      double angle = i * (pi / 180);
      double dx = 1000 * cos(angle) / metersPerDegreeLng;
      double dy = 1000 * sin(angle) / metersPerDegreeLat;
      points.add(LatLng(center.latitude + dy, center.longitude + dx));
    }
    return points;
  }

  LatLng? _mouseCircleCenter;
  double _circleRadius = 0;
  // LatLng? _newSeekerPointCenter;
  double _locationCenterCircleRadius = 0;
  // double _circledRadius = 0;
  void _updateRadius() {
    final zoom = mapController.camera.zoom;
    final lat = _mouseCircleCenter!.latitude;
    final metersPerPixel = 156543.03392 * cos(lat * pi / 180) / pow(2, zoom);
    _circleRadius = 1000 / metersPerPixel;
    _locationCenterCircleRadius = 100 / metersPerPixel;
    setState(() {});
  }

  // v8.1.1 正确坐标转换方法
  LatLng _screenToLatLng(Offset localPosition) {
    final camera = mapController.camera;
    final point = camera.screenOffsetToLatLng(localPosition);
    return point;
  }

  Widget buildMap(Coordinates initCoordinates) {
    // MapController mapController = MapController();
    // mapController.addMarkers(initLocation);

    // 区域范围
    if (_polygons == null && widget.seekerLocation != null) {
      _buildAreaPolygons();
    }

    return Listener(
      onPointerHover: (PointerHoverEvent event) {
        // _l.t(event.localPosition);
        // 鼠标移动
        _mouseCircleCenter = _screenToLatLng(event.localPosition);
        _updateRadius();
      },
      onPointerSignal: (event) {
        // 鼠标滚轮缩放地图
        // _l.t(event);
        _mouseCircleCenter = _screenToLatLng(event.localPosition);
        _updateRadius();
      },
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter:
              LatLng(initCoordinates.latitude, initCoordinates.longitude),
          initialZoom: 14.0,
          onTap: (tapPosition, point) {
            onMouseTap();
          },
          // onMapReady: () => _controller.forward(),
          // onMapReady: _startAnimation,
          // interactionOptions: const InteractionOptions(
          //   flags: InteractiveFlag.drag |
          //   InteractiveFlag.pinchZoom |
          //   InteractiveFlag.doubleTapZoom,
          // ),
        ),
        children: [
          // 瓦片图层（OpenStreetMap）
          // TileLayer(
          //   urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          //   subdomains: const ['a', 'b', 'c'], // 瓦片服务器子域名[5](@ref)
          //   userAgentPackageName: 'com.example.app',
          // ),
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
            // 替换为可取消的 TileProvider
            tileProvider: CancellableNetworkTileProvider(),
          ),

          // TileLayer(
          //   urlTemplate:
          //       'https://webrd02.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}',
          //   subdomains: ['a', 'b', 'c'],
          //   // 替换为可取消的 TileProvider
          //   tileProvider: CancellableNetworkTileProvider(),
          // ),
          _polygons == null
              ? const SizedBox()
              : PolygonLayer(polygons: _polygons!),

          CircleLayer(
            circles: [
              CircleMarker(
                point: locationCenterPoint,
                radius: _locationCenterCircleRadius,
                color: Colors.black38.withAlpha(80),
                borderColor: Colors.black38.withAlpha(120),
                borderStrokeWidth: 2,
              ),
              if (seerPoint != null)
                CircleMarker(
                  point: seerPoint!,
                  radius: _locationCenterCircleRadius,
                  color: Colors.blue.withAlpha(80),
                  borderColor: Colors.blue.withAlpha(120),
                  borderStrokeWidth: 2,
                ),
              if (_newSeekerPointCenter != null)
                CircleMarker(
                  point: _newSeekerPointCenter!,
                  radius: _circleRadius,
                  color: Colors.red.withAlpha(80),
                  borderColor: Colors.red.withAlpha(120),
                  borderStrokeWidth: 2,
                ),
              if (_mouseCircleCenter != null)
                CircleMarker(
                  point: _mouseCircleCenter!,
                  radius: _circleRadius,
                  color: Colors.red.withAlpha(50),
                  borderColor: Colors.red.withAlpha(80),
                  borderStrokeWidth: 2,
                ),
            ],
          ),
          MarkerLayer(markers: [
            if (seerMarker != null) seerMarker!,
            seekerAreaMarker,
            if (_mouseCircleCenter != null)
              buildMouseMarker(_mouseCircleCenter!),
            ..._markers
          ]),
        ],
      ),
    );
  }

  void onMouseTap() {
    // _newSeekerPointCenter = _mouseCircleCenter;
    // _circledRadius = _circleRadius;
    _newSeekerPointCenter = _mouseCircleCenter;

    if (_markers.isNotEmpty) {
      _markers.clear();
    }
    double iconSize = 48;

    _markers.add(Marker(
        width: iconSize,
        height: iconSize,
        alignment: Alignment.topCenter,
        point: _newSeekerPointCenter!,
        child: Transform.translate(
          offset: Offset(0, 0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 第一层模糊阴影
              Transform.translate(
                offset: Offset(1, 1),
                child: Icon(
                  Icons.location_pin,
                  color: Colors.black.withAlpha(100),
                  size: iconSize,
                ),
              ),
              // 主图标
              Icon(
                Icons.location_pin,
                color: Colors.red,
                size: iconSize,
              )
            ],
          ),
        )));
    setState(() {});
  }

  Future<GeoJSON> fetchTimezonesGeoJSONFromLocal() async {
    // _l.i("fetchGeoJSON for ${location.lowestGeoLocation.name} by it's code:${location.lowestGeoLocation.code}");
    // 从本地获取资源
    String geoJsonString = await rootBundle
        .loadString('assets/dataset/combined-with-oceans-now.json');
    // final geoJsonMap =topojson.TopoJson.fromJson(jsonDecode(geoJsonString));
    // final geoJsonMap = await topojson.parse(topoJsonString);
    final geoJSON = GeoJSON.fromJSON(geoJsonString);
    // _l.d(geoJSON);
    return geoJSON;
    // final geoJSON = GeoJson.fromMap(geoJsonMap);
    // final geoJsonData = json.decode(geoJsonString);

    // return convertTimeZonesGeoJSON2Points(geoJsonData);
  }

  Future<List<Polygon>> fetchGeoJSONFromLocalStorage(Address location) async {
    _l.i(
        "fetchGeoJSON for ${location.lowestGeoLocation.name} by it's code:${location.lowestGeoLocation.code}");
    // 从本地获取资源
    String geoJsonString = await rootBundle.loadString(
        'assets/dataset/geo/${location.lowestGeoLocation.code}.geojson');
    final geoJsonData = json.decode(geoJsonString);
    return convertGeoJSONToPoints(geoJsonData);
  }

  Future<List<Polygon>> fetchGeoJSONFromNetwork(Address location) async {
    _l.i(
        "fetchGeoJSON for ${location.lowestGeoLocation.name} by it's code:${location.lowestGeoLocation.code}");
    final String urlPath =
        'https://geo.datav.aliyun.com/areas_v3/bound/${location.lowestGeoLocation.code}.json';
    try {
      Dio dio = Dio();
      // 替换为 DataV.GeoAtlas 实际的 GeoJSON 数据链接
      Response response = await dio.get(urlPath);
      if (response.statusCode == 200) {
        _l.i(
            "fetchGeoJSON for ${location.lowestGeoLocation.name} by it's code:${location.lowestGeoLocation.code} success.");
        final geoJsonData = response.data;
        return convertGeoJSONToPoints(geoJsonData);
      } else {
        _l.e(
            "fetchGeoJSON for ${location.lowestGeoLocation.name} by it's code:${location.lowestGeoLocation.code} failed.");
        throw Exception('Failed to load GeoJSON');
      }
    } catch (e) {
      _l.e(e);
    }
    return [];
  }

  List<Polygon> convertTimeZonesGeoJSON2Points(
      Map<String, dynamic> geoJsonData) {
    _l.d(geoJsonData.keys);
    _l.d(geoJsonData["arcs"]);
    return [];
  }

  List<Polygon> convertGeoJSONToPoints(Map<String, dynamic> geoJsonData) {
    _l.t(geoJsonData.keys);
    final features = geoJsonData['features'] as List<dynamic>;
    _l.d("features:${features.length}");
    List<Polygon> _tmpPolygon = doConvert(features);
    _l.d("total: ${_tmpPolygon.length}");
    return _tmpPolygon;
  }

  List<Polygon> doGeoJSONConvert(List<GeoJSON> geoJsonList) {
    List<Polygon> _tmpPolygon = [];
    for (final geoJson in geoJsonList) {
      _l.d(geoJson.type);
      if (geoJson.type == GeoJSONType.polygon) {
        final coordinates =
            (geoJson as GeoJSONPolygon).coordinates[0] as List<dynamic>;
        List<LatLng> points = [];
        coordinates.forEach((coord) {
          // 如果 lng 的大于 180.0则设置为180.0;
          final lng = coord[0] as double;
          final lat = coord[1] as double;
          points.add(LatLng(lat, lng));
        });
        _tmpPolygon.add(
          Polygon(
            points: points,
            color: Colors.blue.withAlpha(40),
            borderColor: Colors.blue,
            borderStrokeWidth: 2,
          ),
        );
      } else if (geoJson.type == GeoJSONType.multiPolygon) {
        _l.d("type is MultiPolygon");
        final multiCoordinates =
            (geoJson as GeoJSONMultiPolygon).coordinates as List<dynamic>;
        for (final polygonCoordinates in multiCoordinates) {
          for (final ringCoordinates in polygonCoordinates) {
            List<LatLng> points = [];
            ringCoordinates.forEach((coord) {
              final lng = coord[0] as double;
              final lat = coord[1] as double;
              points.add(LatLng(lat, lng));
            });
            _tmpPolygon.add(
              Polygon(
                points: points,
                color: Colors.blue.withAlpha(40),
                borderColor: Colors.blue,
                borderStrokeWidth: 2,
              ),
            );
          }
        }
      }
    }
    return _tmpPolygon;
  }

  List<Polygon> doConvert(List<dynamic> features) {
    List<Polygon> _tmpPolygon = [];
    for (final feature in features) {
      final geometry = feature['geometry'];
      if (geometry['type'] == 'Polygon') {
        _l.d("type is Polygon");
        final coordinates = geometry['coordinates'][0] as List<dynamic>;
        List<LatLng> points = [];
        coordinates.forEach((coord) {
          final lng = coord[0] as double;
          final lat = coord[1] as double;
          // _l.d("lng:$lng,lat:$lat");
          points.add(LatLng(lat, lng));
        });
        _tmpPolygon.add(
          Polygon(
            points: points,
            color: Colors.blue.withAlpha(30),
            borderColor: Colors.blue,
            borderStrokeWidth: 2,
          ),
        );
      } else if (geometry['type'] == 'MultiPolygon') {
        _l.d("type is MultiPolygon");
        final multiCoordinates = geometry['coordinates'] as List<dynamic>;
        for (final polygonCoordinates in multiCoordinates) {
          for (final ringCoordinates in polygonCoordinates) {
            List<LatLng> points = [];
            ringCoordinates.forEach((coord) {
              final lng = coord[0] as double;
              final lat = coord[1] as double;
              // _l.d("lng:$lng,lat:$lat");
              points.add(LatLng(lat, lng));
            });
            _tmpPolygon.add(
              Polygon(
                points: points,
                color: Colors.blue.withAlpha(80),
                borderColor: Colors.blue,
                borderStrokeWidth: 2,
              ),
            );
          }
        }
      }
    }
    return _tmpPolygon;
  }
}
