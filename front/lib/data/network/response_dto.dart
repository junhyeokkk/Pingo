// http 통신의 결과로 받은 ResponseDTO를 검증하는 클래스
// ResponseDTO의 resultCode가 '1'인 경우(성공) data 객체를 반환
class ResponseDTO {
  static dynamic validation(Map<String, dynamic> response) {
    String resultCode = response['resultCode'];

    if (resultCode == '1') {
      // 성공
      return response['data'];
    } else if (resultCode == '2') {
      // 통신은 성공했지만 결과값이 성공이 아닌 경우
      return throw Exception('Server Data Error');
    }
  }
}
