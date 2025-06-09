class SecondStatusModel {
  final int usersId;
  final String usersName;
  final int reportId;
  final String reportTitle;
  final String reportCreate;
  final int createdBy;
  final String reportDescription;
  final String reporttypeName;
  final int reporttypeId;
  final String servicetypeName;
  final int servicetypeId;
  final String statusName;
  final int statusId;

  SecondStatusModel({
    required this.usersId,
    required this.usersName,
    required this.reportId,
    required this.reportTitle,
    required this.reportCreate,
    required this.createdBy,
    required this.reportDescription,
    required this.reporttypeName,
    required this.reporttypeId,
    required this.servicetypeName,
    required this.servicetypeId,
    required this.statusName,
    required this.statusId,
  });

  factory SecondStatusModel.fromJson(Map<String, dynamic> json) {
    return SecondStatusModel(
      usersId: json['users_id'] as int? ?? 0,
      usersName: json['users_name'] as String? ?? '',
      reportId: json['report_id'] as int? ?? 0,
      reportTitle: json['report_title'] as String? ?? '',
      reportCreate: json['report_create'] as String? ?? '',
      createdBy: json['created_by'] as int? ?? 0,
      reportDescription: json['report_description'] as String? ?? '',
      reporttypeName: json['reporttype_name'] as String? ?? '',
      reporttypeId: json['reporttype_id'] as int? ?? 0,
      servicetypeName: json['servicetype_name'] as String? ?? '',
      servicetypeId: json['servicetype_id'] as int? ?? 0,
      statusName: json['status_name'] as String? ?? '',
      statusId: json['status_id'] as int? ?? 0,
    );
  }
}