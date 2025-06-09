class ServiceModel {
  int? servicetypeId;
  String? servicetypeName;

  ServiceModel({this.servicetypeId, this.servicetypeName});

  ServiceModel.fromJson(Map<String, dynamic> json) {
    servicetypeId = json['servicetype_id'];
    servicetypeName = json['servicetype_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['servicetype_id'] = this.servicetypeId;
    data['servicetype_name'] = this.servicetypeName;
    return data;
  }
}