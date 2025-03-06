import 'package:flutter/material.dart';
import '../../../../../../../data/models/user_model/Job_model/JobLists.dart';

class FirstJobSelectPage extends StatelessWidget {
  final Function(String) onJobSelected;

  FirstJobSelectPage({Key? key, required this.onJobSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '1차 직종 선택',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: JobLists.jobList1.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              JobLists.jobList1[index].title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            onTap: () {
              onJobSelected(JobLists.jobList1[index].title); // 선택한 직종을 전달
              Navigator.pop(context); // 화면 닫기
            },
          );
        },
      ),
    );
  }
}
