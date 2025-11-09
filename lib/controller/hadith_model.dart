class Hadith {
  int? id;
  String? text; // تم تغيير الاسم ليتوافق مع قاعدة البيانات
  String? source; // تم تغيير الاسم ليتوافق مع قاعدة البيانات

  Hadith({this.id, this.text, this.source});

  Hadith.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    text = json['hadith_text']; // اسم الحقل من الـ API
    source = json['date_added']; // اسم الحقل من الـ API
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['text'] = this.text; // اسم الحقل في قاعدة البيانات
    data['source'] = this.source; // اسم الحقل في قاعدة البيانات
    return data;
  }
}
