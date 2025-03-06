import 'package:daum_postcode_search/data_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pingo_front/_core/utils/logger.dart';
import 'package:pingo_front/data/models/user_model/user_info.dart';
import 'package:pingo_front/ui/widgets/post_code_search.dart';
import 'jop_page/first_job_select_page.dart';
import 'jop_page/second_job_select_page.dart';

class EditPersonalInformationBox extends ConsumerStatefulWidget {
  final UserInfo copyUserInfo;
  const EditPersonalInformationBox(this.copyUserInfo, {super.key});

  @override
  ConsumerState<EditPersonalInformationBox> createState() =>
      _EditPersonalInformationBoxState();
}

class _EditPersonalInformationBoxState
    extends ConsumerState<EditPersonalInformationBox> {
  // 신장
  final TextEditingController _heightController = TextEditingController();
  String? errorMessage;

  // 주소
  final TextEditingController _userAddressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userAddressController.text = widget.copyUserInfo.userAddress ?? '';
    _heightController.text = widget.copyUserInfo.userHeight?.toString() ?? '';

    // 변경 감지를 위한 리스너 추가
    _heightController.addListener(() {
      String text = _heightController.text;

      // 신장 입력값 검증
      _validateHeight(text);

      // 300 이하의 값만 userInfo에 저장
      int? height = int.tryParse(text);
      if (height != null && height <= 300) {
        widget.copyUserInfo.userHeight = height;
      }
    });

    _userAddressController.addListener(() {
      widget.copyUserInfo.userAddress = _userAddressController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userInfo = widget.copyUserInfo;

    logger.i(userInfo);

    return Card(
      elevation: 0.5,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '인적사항',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 6),
            _buildInformationBox(context, '생년월일', _buildBirthInfo(userInfo)),
            _buildInformationBox(context, '신장', _buildHeightInfo(userInfo)),
            _buildInformationBox(context, '1차 직종', _build1stJobInfo(userInfo)),
            _buildInformationBox(context, '2차 직종', _build2ndJobInfo(userInfo)),
            _buildInformationBox(
                context,
                '거주지',
                _buildAddressInfo(
                    userInfo.userAddress, '', false, _userAddressController)),
            _buildInformationBox(
              context,
              '종교',
              Wrap(
                spacing: 4.0,
                children: [
                  _buildSelectedButton(
                    widget.copyUserInfo.userReligion,
                    "무교",
                    "무교",
                    (selected) => widget.copyUserInfo.userReligion = selected,
                  ),
                  _buildSelectedButton(
                    widget.copyUserInfo.userReligion,
                    "천주교",
                    "천주교",
                    (selected) => widget.copyUserInfo.userReligion = selected,
                  ),
                  _buildSelectedButton(
                    widget.copyUserInfo.userReligion,
                    "불교",
                    "불교",
                    (selected) => widget.copyUserInfo.userReligion = selected,
                  ),
                  _buildSelectedButton(
                    widget.copyUserInfo.userReligion,
                    "기독교",
                    "기독교",
                    (selected) => widget.copyUserInfo.userReligion = selected,
                  ),
                  _buildSelectedButton(
                    widget.copyUserInfo.userReligion,
                    "기타",
                    "기타",
                    (selected) => widget.copyUserInfo.userReligion = selected,
                  ),
                ],
              ),
            ),
            _buildInformationBox(
              context,
              '흡연여부',
              Wrap(
                spacing: 4.0,
                children: [
                  _buildSelectedButton(
                    widget.copyUserInfo.userSmoking,
                    "F",
                    "비흡연",
                    (selected) => widget.copyUserInfo.userSmoking = selected,
                  ),
                  _buildSelectedButton(
                    widget.copyUserInfo.userSmoking,
                    "T",
                    "흡연",
                    (selected) => widget.copyUserInfo.userSmoking = selected,
                  ),
                ],
              ),
            ),
            _buildInformationBox(
              context,
              '음주여부',
              Wrap(
                spacing: 4.0,
                children: [
                  _buildSelectedButton(
                    widget.copyUserInfo.userDrinking,
                    "N",
                    "비음주",
                    (selected) => widget.copyUserInfo.userDrinking = selected,
                  ),
                  _buildSelectedButton(
                    widget.copyUserInfo.userDrinking,
                    "O",
                    "가끔 음주",
                    (selected) => widget.copyUserInfo.userDrinking = selected,
                  ),
                  _buildSelectedButton(
                    widget.copyUserInfo.userDrinking,
                    "F",
                    "잦은 음주",
                    (selected) => widget.copyUserInfo.userDrinking = selected,
                  ),
                ],
              ),
            ),
            _buildInformationBox(
              context,
              '혈액형',
              Wrap(
                spacing: 4.0,
                children: [
                  _buildSelectedButton(
                    widget.copyUserInfo.userBloodType,
                    "A",
                    "A형",
                    (selected) => widget.copyUserInfo.userBloodType = selected,
                  ),
                  _buildSelectedButton(
                    widget.copyUserInfo.userBloodType,
                    "B",
                    "B형",
                    (selected) => widget.copyUserInfo.userBloodType = selected,
                  ),
                  _buildSelectedButton(
                    widget.copyUserInfo.userBloodType,
                    "O",
                    "O형",
                    (selected) => widget.copyUserInfo.userBloodType = selected,
                  ),
                  _buildSelectedButton(
                    widget.copyUserInfo.userBloodType,
                    "AB",
                    "AB형",
                    (selected) => widget.copyUserInfo.userBloodType = selected,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 인적사항 요소
  Widget _buildInformationBox(
      BuildContext context, String title, Widget widgetDetail) {
    double cntWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: (cntWidth - 32) / 4,
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: Colors.black54,
                  ),
            ),
          ),
          SizedBox(
            width: ((cntWidth - 32) * 3 / 4) - 10,
            child: widgetDetail,
          ),
        ],
      ),
    );
  }

  // 생년월일
  Widget _buildBirthInfo(userInfo) {
    return GestureDetector(
      onTap: () {
        _selectDate(userInfo);
      },
      child: Row(
        children: [
          Text(
            '${userInfo.userBirth.toLocal()}'.split(' ')[0],
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Icon(
            Icons.calendar_today,
            color: Color(0xFF906FB7),
            size: 20,
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(userInfo) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: userInfo.userBirth,
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != userInfo.userBirth) {
      setState(() {
        userInfo.userBirth = picked;
      });
    }
  }

  // 신장
  Widget _buildHeightInfo(userInfo) {
    return TextSelectionTheme(
      data: TextSelectionThemeData(
        cursorColor: Color(0xFF906FB7), // 커서 색상
        selectionColor: Color(0xFF906FB7).withOpacity(0.4), // 선택된 영역 색상
        selectionHandleColor: Color(0xFF906FB7), // 둥근 핸들러 색상
      ),
      child: TextField(
        controller: _heightController,
        style: Theme.of(context).textTheme.headlineSmall,
        cursorColor: Color(0xFF906FB7), // 커서 색상
        decoration: InputDecoration(
          border: OutlineInputBorder(), // 기본 테두리
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF906FB7), width: 2.0),
          ),
          hintText: '신장을 입력하세요',
          errorText: errorMessage, // 오류 메시지 적용
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly, // 숫자만 입력 가능
          LengthLimitingTextInputFormatter(3), // 3자리까지만 입력 가능
        ],
      ),
    );
  }

  void _validateHeight(String value) {
    final regex = RegExp(r'^(?:[1-9]?\d|[12]\d{2}|300)$');
    setState(() {
      if (!regex.hasMatch(value)) {
        errorMessage = '신장 정보를 300cm이하인 XXXcm 형태로 입력해 주세요.';
      } else {
        errorMessage = null;
      }
    });
  }

  // 1차 직종
  Widget _build1stJobInfo(userInfo) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FirstJobSelectPage(
              onJobSelected: (selectedJob) {
                setState(() {
                  userInfo.user1stJob = selectedJob;
                  userInfo.user2ndJob = null; // 1차 직종 변경 시 2차 직종 초기화
                });
              },
            ),
          ),
        );
      },
      child: Text(
        userInfo.user1stJob ?? '1차 직종을 선택하세요',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }

  // 2차 직종
  Widget _build2ndJobInfo(userInfo) {
    return GestureDetector(
      onTap: () {
        if (userInfo.user1stJob != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SecondJobSelectPage(
                firstJob: userInfo.user1stJob!,
                onSubJobSelected: (selectedSubJob) {
                  setState(() {
                    userInfo.user2ndJob = selectedSubJob;
                  });
                },
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('먼저 1차 직종을 선택하세요.')),
          );
        }
      },
      child: Text(
        userInfo.user2ndJob ?? '2차 직종을 선택하세요',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }

  // 거주지
  Widget _buildAddressInfo(userAddress, textHint, obscure, controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onTap: () async {
            final selectedAddress = await Navigator.push<DataModel>(
              context,
              MaterialPageRoute(
                builder: (context) => PostCodeSearchScreen(
                  onSelected: (address) {
                    Navigator.pop(context, address); // 선택된 주소 반환
                  },
                ),
              ),
            );

            if (selectedAddress != null) {
              controller.text = selectedAddress.roadAddress;
            }
            setState(() {});
          },
          readOnly: true,
          controller: controller,
          style: Theme.of(context).textTheme.headlineSmall,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: '주소를 입력하세요',
            contentPadding: EdgeInsets.zero,
            isDense: true,
          ),
          obscureText: obscure,
        ),
      ],
    );
  }

  // 버튼 위젯(종교, 흡연여부, 음주여부)
  Widget _buildSelectedButton(String? userValue, String btnValue,
      String btnText, Function(String) onSelected) {
    bool isSelected = userValue == btnValue;

    return InkWell(
      onTap: () {
        setState(() {
          onSelected(btnValue); // 선택한 값 업데이트
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF906FB7) : Colors.white,
          border: Border.all(
            color: isSelected ? Color(0xFF906FB7) : Colors.black12,
          ),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Text(
          btnText,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  // 음주여부
  String _buildUserDrinkingParse(drinking) {
    switch (drinking) {
      case 'N':
        return '비음주';
      case 'O':
        return '가끔 음주';
      case 'F':
        return '잦은 음주';
      default:
        return '';
    }
  }

  String _buildUserSmokingParse(smoking) {
    switch (smoking) {
      case 'F':
        return '비흡연';
      case 'T':
        return '흡연';
      default:
        return '';
    }
  }

  String _buildUserBloodTypeParse(bloodType) {
    switch (bloodType) {
      case 'A':
        return 'A형';
      case 'B':
        return 'B형';
      case 'O':
        return 'O형';
      case 'AB':
        return 'AB형';
      default:
        return '';
    }
  }
}
