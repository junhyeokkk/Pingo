import 'package:pingo_front/_core/utils/logger.dart';
import 'package:pingo_front/data/models/membership_model/membership.dart';
import 'package:pingo_front/data/models/membership_model/user_membership.dart';
import 'package:pingo_front/data/network/custom_dio.dart';
import 'package:tuple/tuple.dart';

class MembershipRepository {
  final CustomDio _customDio = CustomDio.instance;

  Future<Tuple2<UserMembership?, List<Membership>>> fetchSelectMemberShip(
      String userNo) async {
    final response =
        await _customDio.get('/membership', query: {'userNo': userNo});

    logger.i(response);

    UserMembership? userMembership = response['userMembership'] != null
        ? UserMembership.fromJson(response['userMembership'])
        : null;

    List<Membership> memberships = (response['membership'] as List)
        .map((item) => Membership.fromJson(item))
        .toList();

    return Tuple2(userMembership, memberships);
  }

  Future<String> fetchUpdateUserMembership(Map<String, dynamic> reqData) async {
    final response = await _customDio.post('/membership', data: reqData);
    return response.toString();
  }
}
