class Job {
  final String title;
  final List<String> subJobs; // 2차 직종 리스트 추가

  Job(this.title, [this.subJobs = const []]);
}
