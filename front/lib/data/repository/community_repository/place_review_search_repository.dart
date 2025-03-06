import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:pingo_front/_core/utils/logger.dart';
import 'package:pingo_front/data/models/community_model/place_review.dart';
import 'package:pingo_front/data/network/custom_dio.dart';
import 'package:mime/mime.dart';

class PlaceReviewSearchRepository {
  final Dio _dio = Dio();
  final CustomDio _customDio = CustomDio.instance;
  final String _baseUrl = "https://dapi.kakao.com/v2/local/search/keyword.json";
  final String _apiKey = "KakaoAK 1e94dca04a49847a5688820f39327f7e";

  // placeReview 작성
  Future<bool> fetchInsertPlaceReview(Map<String, dynamic> data) async {
    String? mimeType = lookupMimeType(data['placeImage'].path) ?? 'image/jpeg';

    FormData formData = FormData.fromMap({
      "placeReview": MultipartFile.fromString(
        jsonEncode(data['placeReview'].toJson()),
        contentType: DioMediaType("application", "json"),
      ),
      "placeImage": await MultipartFile.fromFile(
        data['placeImage'].path,
        filename: "placeImage.jpg",
        contentType: DioMediaType.parse(mimeType),
      )
    });

    final response = await _customDio.post(
      '/community/place',
      data: formData,
      contentType: 'multipart/form-data',
    );

    return response;
  }

  // 게시글 좋아요
  Future<String> fetchClickThumbUp(String userNo, String prNo) async {
    final response = await _customDio.post(
      '/community/place/heart',
      data: {
        'userNo': userNo,
        'prNo': prNo,
      },
    );
    return response;
  }

  // 서버에서 장소 리뷰 조회
  Future<List<PlaceReview>> fetchSearchPlaceReview(
      {required String? cateSort,
      required String? searchSort,
      String? keyword}) async {
    List<dynamic> response = await _customDio.get('/community/place', query: {
      'cateSort': cateSort,
      'searchSort': searchSort,
      'keyword': keyword
    });

    return response.map((json) => PlaceReview.fromJson(json)).toList();
  }

  // 서버에서 장소 리뷰 조회 with location
  Future<List<PlaceReview>> fetchSearchPlaceReviewWithLocation(
      {required String? cateSort,
      required double latitude,
      required double longitude}) async {
    List<dynamic> response = await _customDio.get('/community/place/location',
        query: {
          'cateSort': cateSort,
          'latitude': latitude,
          'longitude': longitude
        });

    return response.map((json) => PlaceReview.fromJson(json)).toList();
  }

  // 카카오 API 검색
  Future<Map<String, dynamic>> fetchSearchKaKaoLocation(String keyword,
      {int page = 1, int size = 10}) async {
    try {
      Response response = await _dio.get(
        _baseUrl,
        queryParameters: {"query": keyword, "page": page, "size": size},
        options: Options(
          headers: {
            "Authorization": _apiKey, // 카카오 API 인증 헤더 추가
          },
        ),
      );

      logger.i(response);

      if (response.statusCode == 200) {
        return response.data; // JSON 데이터를 그대로 반환
      } else {
        throw Exception("카카오 API 요청 실패: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("카카오 API 요청 실패: ${e.toString()}");
    }
  }

  // 카카오 주소 기반 장소 이미지 크롤링
  Future<dynamic> fetchCrawlingPlaceImage(String placeUrl) async {
    dynamic response = await _customDio
        .post('/community/place/crawling', data: {'placeUrl': placeUrl});

    print(response.runtimeType);

    return response;
  }

  // 장소 공유 채팅 조회
  Future<PlaceReview> fetchSearchPlaceForChat(
      String placeName, String placeAddress) async {
    dynamic response = await _customDio.get(
      '/community/chat',
      query: {'placeName': placeName, 'placeAddress': placeAddress},
    );

    return PlaceReview.fromJson(response);
  }
}
