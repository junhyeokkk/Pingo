import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:pingo_front/data/models/community_model/place_review.dart';
import 'package:pingo_front/data/view_models/community_view_model/place_review_search_view_model.dart';

class PlaceMap extends ConsumerStatefulWidget {
  final String placeName;
  final String placeAddress;
  const PlaceMap(
      {required this.placeName, required this.placeAddress, super.key});

  @override
  ConsumerState<PlaceMap> createState() => _PlaceMapState();
}

class _PlaceMapState extends ConsumerState<PlaceMap> {
  KakaoMapController? mapController;
  LatLng? latLng;
  List<Marker> markers = [];

  late PlaceReview placeReview;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initProcess();
  }

  void initProcess() async {
    placeReview = await ref
        .read(placeReviewSearchViewModelProvider.notifier)
        .searchPlaceForChat(widget.placeName, widget.placeAddress);
    latLng = LatLng(placeReview.latitude!, placeReview.longitude!);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '지도',
          style: TextStyle(fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: _kakaoMapBox(),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    width: double.infinity,
                    color: Colors.grey[400],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '장소 리뷰: ${placeReview.placeName}',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text('장소 리뷰: ${placeReview.addressName}'),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _kakaoMapBox() {
    return KakaoMap(
      center: latLng,
      onMapCreated: (controller) async {
        mapController = controller;

        // 마커 추가
        markers = [
          Marker(
            markerId: 'chat_marker',
            latLng: latLng!,
          ),
        ];

        // setCenter 및 마커 적용
        await mapController?.setCenter(latLng!);
        await mapController?.addMarker(markers: markers);
      },
      markers: markers,
      currentLevel: 4,
    );
  }
}
