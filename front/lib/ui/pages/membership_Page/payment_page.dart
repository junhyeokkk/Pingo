import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pingo_front/data/models/membership_model/membership.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentPage extends StatefulWidget {
  final Membership? selectedMembership;
  const PaymentPage(this.selectedMembership, {super.key});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late final WebViewController _controller;
  final String successUrl = "https://your-success-url.com";
  final String failUrl = "https://your-fail-url.com";
  String paymentUrl = '';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            // toss 정상 연결
            if (request.url.startsWith("intent://")) {
              _launchExternalUrl(request.url);
              return NavigationDecision.prevent;
            }
            // 결제 성공
            if (request.url.contains(successUrl)) {
              Navigator.pop(context, {"status": "success"});
              return NavigationDecision.prevent;
            }
            // 결제 실패
            if (request.url.contains(failUrl)) {
              Navigator.pop(context, {"status": "fail"});
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );
    createFakePayment(); // 가짜 결제창 생성
  }

  /// `intent://` URL을 `https://`로 변경해 외부 브라우저에서 열기
  Future<void> _launchExternalUrl(String url) async {
    final fallbackUrl = url.replaceAll("intent://", "https://");
    if (await canLaunchUrl(Uri.parse(fallbackUrl))) {
      // await launchUrl(Uri.parse(fallbackUrl),
      //     mode: LaunchMode.externalApplication);
    } else {
      debugPrint("URL을 열 수 없음: $url");
    }
  }

  /// 토스 페이먼츠 테스트 결제 요청 (결제 없이 가짜 URL 반환)
  Future<void> createFakePayment() async {
    const String testClientKey =
        "test_sk_DpexMgkW36va5xDNgvGN3GbR5ozO"; // 토스 테스트용 클라이언트 키
    const String apiUrl = "https://api.tosspayments.com/v1/payments";

    String basicAuth = 'Basic ${base64Encode(utf8.encode('$testClientKey:'))}';

    Map<String, dynamic> requestData = {
      "orderId": "ORDER_FAKE_12345",
      "orderName": widget.selectedMembership?.title,
      "amount": widget.selectedMembership?.price,
      "currency": "KRW",
      "successUrl": successUrl,
      "failUrl": failUrl,
      "customerEmail": "test@example.com",
      "customerName": "홍길동",
      "method": "카드",
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": basicAuth,
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          paymentUrl = responseData["checkout"]["url"];
        });
      } else {
        debugPrint("결제 요청 실패: ${response.body}");
      }
    } catch (e) {
      debugPrint("에러 발생: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("토스 결제")),
      body: paymentUrl.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : WebViewWidget(
              controller: _controller..loadRequest(Uri.parse(paymentUrl)),
            ),
    );
  }
}
