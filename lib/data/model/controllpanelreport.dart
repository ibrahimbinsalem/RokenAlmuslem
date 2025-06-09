class ControllPanelReportModel {
  final int reportId;
  final String reportTitle;
  final String reportDescription;
  final String reportCreate;
  final String reportTypeName;
  final String serviceTypeName;
  final String statusName;
  final int statusId;
  final int userId;
  final String createdBy;

  ControllPanelReportModel({
    required this.reportId,
    required this.reportTitle,
    required this.reportDescription,
    required this.reportCreate,
    required this.reportTypeName,
    required this.serviceTypeName,
    required this.statusName,
    required this.statusId,
    required this.userId,
    required this.createdBy,
  });

  factory ControllPanelReportModel.fromJson(Map<String, dynamic> json) {
    return ControllPanelReportModel(
      reportId: int.tryParse(json['report_id'].toString()) ?? 0,
      reportTitle: json['report_title']?.toString() ?? '',
      reportDescription: json['report_description']?.toString() ?? '',
      reportCreate: json['report_create']?.toString() ?? '',
      reportTypeName: json['reporttype_name']?.toString() ?? '',
      serviceTypeName: json['servicetype_name']?.toString() ?? '',
      statusName: json['status_name']?.toString() ?? '',
      statusId: int.tryParse(json['status_id'].toString()) ?? 0,
      userId: int.tryParse(json['users_id'].toString()) ?? 0,
      createdBy: json['created_by']?.toString() ?? '',
    );
  }
}
