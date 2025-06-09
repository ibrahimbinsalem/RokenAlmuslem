class StatusModel {
  int? statusId;
  String? statusName;

  StatusModel({this.statusId, this.statusName});

  StatusModel.fromJson(Map<String, dynamic> json) {
    statusId = json['status_id'];
    statusName = json['status_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status_id'] = this.statusId;
    data['status_name'] = this.statusName;
    return data;
  }
}
