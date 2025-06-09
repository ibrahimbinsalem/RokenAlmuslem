class ReportWorkOnModel {
  int? usersId;
  String? usersName;
  int? reportId;
  String? reportTitle;
  String? reportCreate;
  int? createdBy;
  String? reportDescription;
  String? reporttypeName;
  int? reporttypeId;
  String? servicetypeName;
  int? servicetypeId;
  int? statusId;
  String? statusName;

  ReportWorkOnModel(
      {this.usersId,
      this.usersName,
      this.reportId,
      this.reportTitle,
      this.reportCreate,
      this.createdBy,
      this.reportDescription,
      this.reporttypeName,
      this.reporttypeId,
      this.servicetypeName,
      this.servicetypeId,
      this.statusId,
      this.statusName});

  ReportWorkOnModel.fromJson(Map<String, dynamic> json) {
    usersId = json['users_id'];
    usersName = json['users_name'];
    reportId = json['report_id'];
    reportTitle = json['report_title'];
    reportCreate = json['report_create'];
    createdBy = json['created_by'];
    reportDescription = json['report_description'];
    reporttypeName = json['reporttype_name'];
    reporttypeId = json['reporttype_id'];
    servicetypeName = json['servicetype_name'];
    servicetypeId = json['servicetype_id'];
    statusId = json['status_id'];
    statusName = json['status_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['users_id'] = this.usersId;
    data['users_name'] = this.usersName;
    data['report_id'] = this.reportId;
    data['report_title'] = this.reportTitle;
    data['report_create'] = this.reportCreate;
    data['created_by'] = this.createdBy;
    data['report_description'] = this.reportDescription;
    data['reporttype_name'] = this.reporttypeName;
    data['reporttype_id'] = this.reporttypeId;
    data['servicetype_name'] = this.servicetypeName;
    data['servicetype_id'] = this.servicetypeId;
    data['status_id'] = this.statusId;
    data['status_name'] = this.statusName;
    return data;
  }
}