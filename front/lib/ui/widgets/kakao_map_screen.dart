import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:pingo_front/_core/utils/logger.dart';
import 'package:pingo_front/data/models/community_model/kakao_search.dart';

class KakaoMapScreen extends StatefulWidget {
  final KakaoSearch kakaoSearch;
  KakaoMapScreen(this.kakaoSearch, {super.key});

  @override
  State<KakaoMapScreen> createState() => _KakaoMapScreenState();
}

class _KakaoMapScreenState extends State<KakaoMapScreen> {
  KakaoMapController? mapController;
  LatLng? _latLng;
  List<Marker> markers = [];

  @override
  void initState() {
    super.initState();

    // 부모에서 받은 좌표를 가져와 _latLng 설정
    double lat = widget.kakaoSearch.latitude!;
    double lng = widget.kakaoSearch.longitude!;
    _latLng = LatLng(lat, lng);

    logger.i('검색한 위도: $lat, 경도: $lng');
  }

  @override
  Widget build(BuildContext context) {
    return KakaoMap(
      center: _latLng,
      onMapCreated: (controller) async {
        mapController = controller;

        // 마커 추가
        markers = [
          Marker(
            markerId: 'search_marker',
            latLng: _latLng!,
          ),
        ];

        // setCenter 및 마커 적용
        await mapController?.setCenter(_latLng!);
        await mapController?.addMarker(markers: markers);

        logger.i('setCenter 및 setMarkers 적용 완료');
      },
      markers: markers,
      currentLevel: 3,
    );
  }
}
