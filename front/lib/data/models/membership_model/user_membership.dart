class UserMembership {
  String? umNo;
  String? userNo;
  String? msNo;
  DateTime? payDate;
  DateTime? expDate;
  String? state;

  @override
  String toString() {
    return 'UserMembership{umNo: $umNo, userNo: $userNo, msNo: $msNo, payDate: $payDate, expDate: $expDate, state: $state}';
  }

  UserMembership.fromJson(Map<String, dynamic> json)
      : umNo = json['umNo'],
        userNo = json['userNo'],
        msNo = json['msNo'],
        payDate = DateTime.parse(json['payDate']),
        expDate = DateTime.parse(json['expDate']),
        state = json['state'];
}
