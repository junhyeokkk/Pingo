import 'package:flutter/material.dart';
import 'package:pingo_front/data/models/user_model/Job_model/Job.dart';
import 'package:pingo_front/data/models/user_model/Job_model/JobLists.dart';

// 회원가입시 사용하는 직종 선택 클래스
class JobSelectionPage extends StatefulWidget {
  final String? selectedCategory;

  const JobSelectionPage({this.selectedCategory, Key? key}) : super(key: key);

  @override
  State<JobSelectionPage> createState() => _JobSelectionPageState();
}

class _JobSelectionPageState extends State<JobSelectionPage> {
  String? selectedCategory;
  List<String> subJobs = [];

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.selectedCategory;
    if (selectedCategory != null) {
      _updateSubJobs(selectedCategory!);
    }
  }

  // 1차 직종 선택 후 2차 직종 목록 필터링
  void _updateSubJobs(String category) {
    setState(() {
      selectedCategory = category;
      List<Job> filteredJobs =
          JobLists.jobList1.where((job) => job.title == category).toList();

      if (filteredJobs.isNotEmpty) {
        subJobs = filteredJobs.first.subJobs;
      } else {
        subJobs = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.selectedCategory == null ? "1차 직종 선택" : "2차 직종 선택",
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
      ),
      body: ListView.builder(
        itemCount: widget.selectedCategory == null
            ? JobLists.jobList1.length
            : subJobs.length,
        itemBuilder: (context, index) {
          String jobName = widget.selectedCategory == null
              ? JobLists.jobList1[index].title
              : subJobs[index];

          return ListTile(
            title: Text(jobName),
            onTap: () {
              Navigator.pop(context, jobName);
            },
          );
        },
      ),
    );
  }
}
