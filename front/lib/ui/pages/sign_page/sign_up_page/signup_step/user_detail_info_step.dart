import 'package:flutter/material.dart';
import 'package:pingo_front/ui/pages/sign_page/sign_up_page/component/job_selection_page.dart';

// step5 회원 디테일 정보 입력
class UserDetailInfoStep extends StatefulWidget {
  final Function nextStep;
  final dynamic userData;
  final dynamic signupNotifier;

  const UserDetailInfoStep(this.nextStep, this.userData, this.signupNotifier,
      {super.key});

  @override
  State<UserDetailInfoStep> createState() => _UserDetailInfoStepState();
}

class _UserDetailInfoStepState extends State<UserDetailInfoStep> {
  String? _selected1stJob;
  String? _selected2ndJob;
  String? _selectedReligion;
  String? _selectedDrinking;
  String? _selectedSmoking;
  String? _selectedBloodType;

  String information = '';

  // 직업 선택 함수 -> JobSelectionPage 페이지 호출
  Future<void> _selectJob() async {
    final job1 = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => JobSelectionPage()),
    );

    if (job1 != null) {
      final job2 = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => JobSelectionPage(selectedCategory: job1)),
      );

      if (job2 != null) {
        setState(() {
          _selected1stJob = job1;
          _selected2ndJob = job2;
        });
      }
    }
  }

  // 입력한 디테일 정보 검증 함수
  void checkValidation() async {
    String? user1stJob = _selected1stJob;
    String? user2ndJob = _selected2ndJob;
    String? userReligion = _selectedReligion;
    String? userDrinking = _selectedDrinking;
    String? userSmoking = _selectedSmoking;
    String? userBloodType = _selectedBloodType;

    if (user1stJob == null ||
        user2ndJob == null ||
        userReligion == null ||
        userDrinking == null ||
        userSmoking == null ||
        userBloodType == null) {
      setState(() {
        information = '모든 항목을 선택해주세요.';
      });
      return;
    }

    int result = await widget.signupNotifier.validationDetailInfo(user1stJob,
        user2ndJob, userReligion, userDrinking, userSmoking, userBloodType);

    if (result == 1) {
      setState(() {
        widget.nextStep();
      });
    }
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
          _jobSelectedBox(),
          const SizedBox(height: 16),
          _buildSelectionBox(
            '종교',
            ['천주교', '기독교', '불교', '기타', '무교'],
            _selectedReligion,
            (val) => setState(() => _selectedReligion = val),
          ),
          const SizedBox(height: 16),
          _buildSelectionBox('음주', ['안 마심', '가끔', '자주'], _selectedDrinking,
              (val) => setState(() => _selectedDrinking = val)),
          const SizedBox(height: 16),
          _buildSelectionBox(
            '흡연',
            ['비흡연', '흡연'],
            _selectedSmoking,
            (val) => setState(() => _selectedSmoking = val),
          ),
          const SizedBox(height: 16),
          _buildSelectionBox(
            '혈액형',
            ['A형', 'B형', 'O형', 'AB형'],
            _selectedBloodType,
            (val) => setState(() => _selectedBloodType = val),
          ),
          const SizedBox(height: 16),
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
              onPressed: _selected1stJob != null &&
                      _selected2ndJob != null &&
                      _selectedReligion != null &&
                      _selectedDrinking != null &&
                      _selectedSmoking != null &&
                      _selectedBloodType != null
                  ? () => checkValidation()
                  : null,
              child: Text(
                '다음',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }

  // 직업 선택 위젯 (선택한 직업 화면에 표시 / 클릭시 _selectJob함수를 호출해 화면 이동)
  Widget _jobSelectedBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '직업',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4.0),
        GestureDetector(
          onTap: _selectJob,
          child: AbsorbPointer(
            child: TextField(
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: _selected1stJob != null && _selected2ndJob != null
                          ? Color(0xFF906FB7)
                          : Colors.grey),
                ),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)),
                filled: true,
                fillColor: Colors.white,
                hintText: "직업 선택 (ex. 개발 - 프론트엔드)",
                hintStyle: TextStyle(color: Colors.grey),
              ),
              controller: TextEditingController(
                text: _selected1stJob != null && _selected2ndJob != null
                    ? "$_selected1stJob - $_selected2ndJob"
                    : "",
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 종교, 음주, 흡연, 혈액형 선택 박스 위젯
  Widget _buildSelectionBox(String title, List<String> options,
      String? selectedValue, Function(String) onSelect) {
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
        Row(
          children: options.map((option) {
            bool isSelected = selectedValue == option;
            return Expanded(
              child: GestureDetector(
                onTap: () => onSelect(option),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  margin: EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: isSelected ? Color(0xFF906FB7) : Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                    color: isSelected ? Color(0xFF906FB7) : Colors.white,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    option,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
