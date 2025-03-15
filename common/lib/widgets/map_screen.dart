import 'package:common/datamodel/basic_person_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class MapScreen extends StatefulWidget {
  final Location location;
  const MapScreen(this.location);
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapController mapController;

  @override
  void initState() {
    super.initState();
    final initGeoPoint = GeoPoint(
        latitude: widget.location.coordinates.latitude,
        longitude: widget.location.coordinates.longitude);
    mapController = MapController(
      initPosition: initGeoPoint,
    );
  }

  @override
  void dispose() {
    mapController.listenerMapSingleTapping.removeListener(_handleMapTap);
    mapController.dispose();
    super.dispose();
  }

  GeoPoint? previousPosition;

  void _handleMapTap() {
    GeoPoint? point = mapController.listenerMapSingleTapping.value;
    if (previousPosition != null) {
      mapController.removeMarker(previousPosition!);
      mapController.removeCircle(previousPosition.toString());
    }
    if (point != null) {
      previousPosition = point;
      mapController.drawCircle(CircleOSM(
        key: point.toString(),
        centerPoint: point,
        radius: 50,
        color: Colors.blue.withAlpha(40),
        strokeWidth: 2,
        borderColor: Colors.blue.withAlpha(120),
      ));
      mapController.addMarker(point,
          markerIcon: MarkerIcon(
              icon: Icon(
            Icons.location_pin,
            color: Colors.red,
            size: 48,
          )));

      // 可以在这里更新UI或处理坐标
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.location;
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Text(
                '请选择精确地经纬度',
                style: TextStyle(fontSize: 24, color: Colors.black87),
              ),
              SizedBox(
                width: 36,
              ),
              Column(
                children: [
                  ValueListenableBuilder<GeoPoint?>(
                      valueListenable: mapController.listenerMapSingleTapping,
                      builder: (ctx, geoPoint, _) {
                        return Text.rich(TextSpan(
                          style: TextStyle(fontSize: 18, color: Colors.black87),
                          children: [
                            TextSpan(
                                text:
                                    "经度:${l.coordinates.latitude}, 纬度:${l.coordinates.longitude} ",
                                style: geoPoint != null
                                    ? TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        color: Colors.grey)
                                    : TextStyle(
                                        fontSize: 18, color: Colors.black87)),
                            if (geoPoint != null)
                              TextSpan(
                                  text:
                                      " → 经度:${geoPoint.latitude}, 纬度:${geoPoint.longitude} ",
                                  style: TextStyle(color: Colors.blue))
                          ],
                        ));
                      }),
                  Text(
                      '${l.province.name}>${l.city.name}>${l.area?.name ?? ""}',
                      style: TextStyle(fontSize: 14, color: Colors.black45)),
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    width: 88,
                    height: 42,
                    child: ElevatedButton(onPressed: () {}, child: Text("完成")),
                  ),
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.my_location))
                ],
              ),
            ],
          ),
        ),
        body: mapBody());
  }

  Widget mapBody() {
    return OSMFlutter(
      controller: mapController,
      onGeoPointClicked: (clickeGeoPoint) {},
      onMapIsReady: (isReady) {
        if (isReady) {
          mapController.listenerMapSingleTapping.addListener(_handleMapTap);
          mapController.addMarker(
              GeoPoint(
                  latitude: widget.location.coordinates.latitude,
                  longitude: widget.location.coordinates.longitude),
              markerIcon: MarkerIcon(
                  icon: Icon(
                Icons.location_city,
                color: Colors.red[900],
                size: 48,
              )));
        }
      },
      osmOption: OSMOption(
        userTrackingOption: UserTrackingOption(
          enableTracking: true,
          unFollowUser: false,
        ),
        zoomOption: ZoomOption(
          initZoom: 8,
          minZoomLevel: 3,
          maxZoomLevel: 19,
          stepZoom: 1.0,
        ),
        userLocationMarker: UserLocationMaker(
          personMarker: MarkerIcon(
            icon: Icon(
              Icons.location_history_rounded,
              color: Colors.red,
              size: 48,
            ),
          ),
          directionArrowMarker: MarkerIcon(
            icon: Icon(
              Icons.double_arrow,
              size: 48,
            ),
          ),
        ),
        roadConfiguration: RoadOption(
          roadColor: Colors.yellowAccent,
        ),
      ),
    );
  }
}
