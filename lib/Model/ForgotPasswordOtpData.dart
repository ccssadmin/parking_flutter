class ForgotPasswordOtpData {
  final String? otpcode;
  final int? userid;

  ForgotPasswordOtpData({this.otpcode, this.userid});

  factory ForgotPasswordOtpData.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordOtpData(
      otpcode: json['otpcode'],
      userid: json['userid'],
    );
  }
}
