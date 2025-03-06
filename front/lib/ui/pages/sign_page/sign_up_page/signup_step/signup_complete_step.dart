import 'package:flutter/material.dart';

// 마지막 완료 페이지
class SignupCompleteStep extends StatefulWidget {
  final Function nextStep;
  final Function rollbackStep;
  final dynamic userData;
  final dynamic signupNotifier;

  const SignupCompleteStep(
      this.nextStep, this.rollbackStep, this.userData, this.signupNotifier,
      {super.key});

  @override
  State<SignupCompleteStep> createState() => _SignupCompleteStepState();
}

class _SignupCompleteStepState extends State<SignupCompleteStep> {
  late Future<bool> result;
  @override
  void initState() {
    super.initState();

    result = widget.signupNotifier.signupInfoToServer();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.0),
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      child: FutureBuilder<bool>(
        future: result,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 데이터 로딩 중 (대기 상태)
            return _buildWaiting();
          } else if (snapshot.hasError) {
            // 오류 발생 시 (네트워크 오류 - 요청에 서버에 도착하지 못함)
            return _buildError();
          } else if (snapshot.hasData && snapshot.data == true) {
            // 성공 시 (회원가입 완료)
            return _buildComplete();
          } else {
            // 실패 시 (서버에서 발생한 오류로 실패 - 입력한 정보에 이상이 있음)
            return _buildFailed();
          }
        },
      ),
    );
  }

  Widget _buildWaiting() {
    return Column(
      children: [
        Text(
          '대기중...',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 50),
        SizedBox(
          height: 100,
          width: 100,
          child: const CircularProgressIndicator(strokeWidth: 10),
        ),
      ],
    );
  }

  Widget _buildComplete() {
    return Column(
      children: [
        Icon(
          Icons.celebration,
          color: Color(0xFF906FB7),
          size: 100,
        ),
        const SizedBox(height: 20),
        Text(
          '${widget.userData.users.userName}님 회원가입이',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          '완료되었습니다.',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 20),
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
            onPressed: () {
              // 로그인 화면으로 이동
              Navigator.pop(context);
            },
            child: Text(
              '로그인 화면으로 이동',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFailed() {
    return Column(
      children: [
        Icon(
          Icons.cancel_presentation,
          size: 100,
          color: Colors.redAccent,
        ),
        const SizedBox(height: 20),
        Text(
          '회원가입 실패',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          '예상치 못한 오류로 회원가입에 실패했습니다.\n회원가입을 다시 진행해주세요.',
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
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
            onPressed: () {
              setState(() {
                // 회원가입 첫 페이지로
                widget.rollbackStep();
              });
            },
            child: Text(
              '처음으로',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Column(
      children: [
        Icon(
          Icons.sms_failed_outlined,
          size: 100,
          color: Colors.redAccent,
        ),
        const SizedBox(height: 20),
        Text(
          '네트워크 오류',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          '네트워크 오류로 회원가입에 실패했습니다.',
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
            onPressed: () {
              setState(() {
                result = widget.signupNotifier.signupInfoToServer();
              });
            },
            child: Text(
              '다시 시도',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
