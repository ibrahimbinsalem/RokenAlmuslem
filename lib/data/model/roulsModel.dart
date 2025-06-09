class RoulsModel {
  int? usersId;
  String? usersName;
  String? usersEmail;
  String? usersPassword;
  String? usersPhone;
  int? usersActive;
  String? usersImage;
  int? rolesId;
  String? rolesName;

  RoulsModel({
    this.usersId,
    this.usersName,
    this.usersEmail,
    this.usersPassword,
    this.usersPhone,
    this.usersActive,
    this.usersImage,
    this.rolesId,
    this.rolesName,
  });

  RoulsModel.fromJson(Map<String, dynamic> json) {
    usersId = json['users_id'];
    usersName = json['users_name'];
    usersEmail = json['users_email'];
    usersPassword = json['users_password'];
    usersPhone = json['users_phone'];
    usersActive = json['users_active'];
    usersImage = json['users_image'];
    rolesId = json['roles_id'];
    rolesName = json['roles_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['users_id'] = this.usersId;
    data['users_name'] = this.usersName;
    data['users_email'] = this.usersEmail;
    data['users_password'] = this.usersPassword;
    data['users_phone'] = this.usersPhone;
    data['users_active'] = this.usersActive;
    data['users_image'] = this.usersImage;
    data['roles_id'] = this.rolesId;
    data['roles_name'] = this.rolesName;
    return data;
  }
}
