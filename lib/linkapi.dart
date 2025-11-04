class AppLink {
  static const String server = "https://tasks.arabwaredos.com/rouknalmuslam";

  // static const String test = "$server/test.php"; // Not used with new server

  // ============== Auth ==================

  static const String signUp = "$server/auth/signup.php";
  static const String verifycodesignup = "$server/auth/verifycode.php";
  static const String login = "$server/auth/login.php";
  static const String resend = "$server/auth/resendcode.php";
  static const String getrouls = "$server/auth/userroul.php";

  // ==============Forget Password================ :

  static const String checkemail = "$server/forgetpassword/checkemail.php";
  static const String sendverifycode =
      "$server/forgetpassword/forgetverify.php";
  static const String resetpassword =
      "$server/forgetpassword/resetpassword.php";

  // // ============== ImageLinks ================ :

  static const String imagestatus =
      "https://newbalignearab.arabwaredos.com/baligneback/upload";
  static const String profileimage = "$imagestatus/profile/";
  static const String imageitems = "$imagestatus/items/";
  static const String panelimage = "$imagestatus/panel";

  // static const String imagestatus =
  //     "https://apptest.arabwaredos.com/ecoapp/upload";
  // static const String imagecategories = "$imagestatus/categories/";
  // static const String imageitems = "$imagestatus/items";

  // ============== Reports Links =========================== :

  static const String createReport = "$server/reports/create.php";
  static const String getservices = "$server/reports/services.php";
  static const String getreporttype = "$server/reports/reporttype.php";
  static const String getmyreport = "$server/reports/getmyreport.php";

  // =============== Status Links ============================
  static const String status = "$server/status/statusall.php";
  static const String userReportall = "$server/status/alluserreport.php";
  // =============== Home Page :  ============================
  static const String myreports = "$server/reports/getmyreport.php";
  static const String workonit = "$server/reports/workonit.php";
  static const String editeprofile = "$server/profile/editeprofile.php";

  // =============== Profile Links ============================
  static const String changepassword = "$server/profile/changepassword.php";

  // ================ FQA Links ===============================

  static const String addfqa = "$server/FAQ/add.php";

  static const String getfqa = "$server/FAQ/getallFQA.php";

  static const String updatefqa = "$server/FAQ/edite.php";

  static const String deletefqa = "$server/FAQ/delete.php";

  // =============== Controll Panel Links ============================

  static const String getAllReports =
      "$server/controlpanel/reports/allreports.php";

  static const String getAllTeam = "$server/controlpanel/addteam/getteam.php";

  static const String addTeam = "$server/controlpanel/addteam/addteam.php";

  static const String workreport =
      "$server/controlpanel/addteam/teamworkinreport.php";

  static const String getallService = "$server/controlpanel/service/view.php";

  static const String addService = "$server/controlpanel/service/add.php";
  static const String editService = "$server/controlpanel/service/edite.php";
  static const String deleteService = "$server/controlpanel/service/delete.php";
}
