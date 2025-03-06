import 'dart:convert';
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:dio/dio.dart';
import 'package:pingo_front/_core/utils/logger.dart';
import 'package:pingo_front/data/models/community_model/dating_guide.dart';
import 'package:pingo_front/data/models/community_model/dating_guide_search.dart';
import 'package:pingo_front/data/network/custom_dio.dart';

class DatingGuideRepository {
  final CustomDio _customDio = CustomDio.instance;

  // 게시글 최초 조회
  Future<Map<String, DatingGuideSearch>> fetchSelectDatingGuideForInit() async {
    final response = await _customDio.get('/community/guide/init');

    Map<String, DatingGuideSearch> resultMap = {};
    for (var key in response.keys) {
      resultMap.addAll({key: DatingGuideSearch.formJson(response[key])});
    }

    return resultMap;
  }

  // 정렬로 게시글 조회
  Future<List<DatingGuide>> fetchSelectDatingGuideWithSort(
      String newSort, int category) async {
    List<dynamic> response = await _customDio.get('/community/guide/sort',
        query: {'cate': category, 'sort': newSort});

    List<DatingGuide> result =
        response.map((json) => DatingGuide.fromJson(json)).toList();

    return result;
  }

  // 게시글 작성
  Future<bool> fetchInsertDatingGuide(
      Map<String, dynamic> data, File guideImage) async {
    String? mimeType = lookupMimeType(guideImage.path) ?? 'image/jpeg';

    FormData formData = FormData.fromMap({
      "datingGuide": MultipartFile.fromString(
        jsonEncode(data),
        contentType: DioMediaType("application", "json"),
      ),
      "guideImage": await MultipartFile.fromFile(
        guideImage.path,
        filename: "guideImage.jpg",
        contentType: DioMediaType.parse(mimeType),
      )
    });

    final response = await _customDio.post(
      '/community/guide',
      data: formData,
    );

    return response;
  }

  // 게시글 좋아요
  Future<String> fetchClickThumbUp(String userNo, String dgNo) async {
    final response = await _customDio.post(
      '/community/guide/heart',
      data: {
        'userNo': userNo,
        'dgNo': dgNo,
      },
    );
    return response;
  }
}
