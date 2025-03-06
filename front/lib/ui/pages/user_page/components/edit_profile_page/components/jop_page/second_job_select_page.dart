import 'package:flutter/material.dart';

import '../../../../../../../data/models/user_model/Job_model/JobLists.dart';

class SecondJobSelectPage extends StatelessWidget {
  final String firstJob;
  final Function(String) onSubJobSelected;

  SecondJobSelectPage(
      {Key? key, required this.firstJob, required this.onSubJobSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1차 직종에 해당하는 2차 직종 가져오기
    final selectedJob =
        JobLists.jobList1.firstWhere((job) => job.title == firstJob);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$firstJob - 2차 직종 선택',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: selectedJob.subJobs.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(selectedJob.subJobs[index]),
            onTap: () {
              onSubJobSelected(selectedJob.subJobs[index]); // 선택한 2차 직종 전달
              Navigator.pop(context); // 화면 닫기
            },
          );
        },
      ),
    );
  }
}
