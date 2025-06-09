class TeamWorkInReportModel {
  final int usersId;
  final String usersName;
  final int reportId;
  final String reportTitle;

  TeamWorkInReportModel({
    required this.usersId,
    required this.usersName,
    required this.reportId,
    required this.reportTitle,
  });

  factory TeamWorkInReportModel.fromJson(Map<String, dynamic> json) {
    return TeamWorkInReportModel(
      usersId: json['users_id'] as int,
      usersName: json['users_name'] as String,
      reportId: json['report_id'] as int,
      reportTitle: json['report_title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'users_id': usersId,
      'users_name': usersName,
      'report_id': reportId,
      'report_title': reportTitle,
    };
  }
}
