import 'package:flutter/material.dart';
import 'package:daum_postcode_search/daum_postcode_search.dart';
import 'package:pingo_front/ui/widgets/post_code_search.dart';

// step3 회원 기본 정보 입력
class UserBasicInfoStep extends StatefulWidget {
  final Function nextStep;
  final dynamic userData;
  final dynamic signupNotifier;

  const UserBasicInfoStep(this.nextStep, this.userData, this.signupNotifier,
      {super.key});

  @override
  State<UserBasicInfoStep> createState() => _UserBasicInfoStepState();
}

class _UserBasicInfoStepState extends State<UserBasicInfoStep> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userBirthController = TextEditingController();
  String? _selectedGender;
  final TextEditingController _userNickController = TextEditingController();
  final TextEditingController _userAddressController = TextEditingController();
  final TextEditingController _userHeightController = TextEditingController();

  String information = '';

  // 날짜 선택 함수
  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _userBirthController.text =
            "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
      });
    }
  }

  // 입력한 회원 기본 정보 유효성 검증 함수
  void checkValidation() async {
    String userName = _userNameController.text.trim();
    String userBirth = _userBirthController.text.trim();
    String? userGender = _selectedGender;
    String userNick = _userNickController.text.trim();
    String userAddress = _userAddressController.text.trim();
    String userHeight = _userHeightController.text.trim();

    if (userName.isEmpty ||
        userBirth.isEmpty ||
        userGender == null ||
        userNick.isEmpty ||
        userAddress.isEmpty ||
        userHeight.isEmpty) {
      setState(() {
        information = '모든 항목을 입력해주세요.';
      });
      return;
    }

    // userHeight가 String이면 int로 변환
    int? parsedHeight = int.tryParse(userHeight);
    if (parsedHeight == null) {
      setState(() {
        information = '신장은 숫자 형식으로 입력해야 합니다.';
      });
      return;
    }

    int result = await widget.signupNotifier.validationBasicInfo(
      userName,
      userBirth,
      userGender,
      userNick,
      userAddress,
      parsedHeight,
    );

    setState(() {
      switch (result) {
        case 1:
          information = '이름은 2~10자의 한글만 입력 가능합니다.';
          break;
        case 2:
          information = '생년월일은 현재 날짜보다 미래일 수 없습니다.';
          break;
        case 3:
          information = '유효한 날짜 형식이 아닙니다. (예: 2000-01-01)';
          break;
        case 4:
          information = '닉네임은 2~10자의 한글 또는 영어만 입력 가능합니다.';
          break;
        case 5:
          information = '이미 사용중인 닉네임입니다.';
          break;
        case 6:
          information = '서버 오류';
          break;
        case 7:
          information = '신장을 300cm이하인 XXXcm 형태로 입력해 주세요.';
          break;
        case 8:
          information = '';
          widget.nextStep();
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.0),
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _textInputBox('이름', '', false, _userNameController),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: _textInputBox(
                      '생년월일',
                      'YYYY-MM-DD',
                      false,
                      _userBirthController,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _selectSex('성별'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _textInputBox('닉네임', '', false, _userNickController),
          const SizedBox(height: 20),
          _textInputBox('신장', '', false, _userHeightController),
          const SizedBox(height: 20),
          _addressBox('주소', '', false, _userAddressController),
          const SizedBox(height: 20),
          information.isNotEmpty
              ? Text(
                  information,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold, color: Colors.red),
                )
              : SizedBox(),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF906FB7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              onPressed: _userNameController.text.trim() != '' &&
                      _userBirthController.text.trim() != '' &&
                      _selectedGender != null &&
                      _userNickController.text.trim() != '' &&
                      _userAddressController.text.trim() != ''
                  ? () => checkValidation()
                  : null,
              child: Text(
                '다음',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 회원 기본 정보 입력 위젯
  Widget _textInputBox(String title, String textHint, bool obscure,
      TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4.0),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            border:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            filled: true,
            fillColor: Colors.white,
            hintText: textHint,
            hintStyle: TextStyle(color: Colors.grey),
          ),
          obscureText: obscure,
        ),
      ],
    );
  }

  Widget _addressBox(String title, String textHint, bool obscure,
      TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4.0),
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
          decoration: const InputDecoration(
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            border:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            filled: true,
            fillColor: Colors.white,
            hintText: "주소를 설정해주세요.",
            hintStyle: TextStyle(color: Colors.grey),
          ),
          obscureText: obscure,
        ),
      ],
    );
  }

  // 성별
  Widget _selectSex(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4.0),
        SizedBox(
          height: 50,
          child: DropdownButtonFormField<String>(
            value: _selectedGender,
            decoration: InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(4.0),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(4.0),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            items: ['남성', '여성'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedGender = newValue;
              });
            },
          ),
        ),
      ],
    );
  }
}
