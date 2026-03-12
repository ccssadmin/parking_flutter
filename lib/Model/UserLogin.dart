class UserLogin {
  UserLoginDataWrapper? data;

  UserLogin({this.data});

  UserLogin.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? UserLoginDataWrapper.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonData = {};
    if (data != null) {
      jsonData['data'] = data!.toJson();
    }
    return jsonData;
  }
}

class UserLoginDataWrapper {
  UserAppLogin? userAppLogin;

  UserLoginDataWrapper({this.userAppLogin});

  UserLoginDataWrapper.fromJson(Map<String, dynamic> json) {
    userAppLogin = json['userAppLogin'] != null
        ? UserAppLogin.fromJson(json['userAppLogin'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonData = {};
    if (userAppLogin != null) {
      jsonData['userAppLogin'] = userAppLogin!.toJson();
    }
    return jsonData;
  }
}

class UserAppLogin {
  String? message;
  bool? success;
  UserLoginDetails? data;

  UserAppLogin({this.message, this.success, this.data});

  UserAppLogin.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    success = json['success'];
    data = json['data'] != null ? UserLoginDetails.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonData = {};
    jsonData['message'] = message;
    jsonData['success'] = success;
    if (data != null) {
      jsonData['data'] = data!.toJson();
    }
    return jsonData;
  }
}

class UserLoginDetails {
  String? createdAt;
  String? expiresAt;
  bool? isUsed;
  String? otpCode;
  String? purpose;
  String? userMobile;
  int? userOtpId;

  UserLoginDetails({
    this.createdAt,
    this.expiresAt,
    this.isUsed,
    this.otpCode,
    this.purpose,
    this.userMobile,
    this.userOtpId,
  });

  UserLoginDetails.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    expiresAt = json['expiresAt'];
    isUsed = json['isUsed'];
    otpCode = json['otpCode'];
    purpose = json['purpose'];
    userMobile = json['userMobile'];
    userOtpId = json['userOtpId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonData = {};
    jsonData['createdAt'] = createdAt;
    jsonData['expiresAt'] = expiresAt;
    jsonData['isUsed'] = isUsed;
    jsonData['otpCode'] = otpCode;
    jsonData['purpose'] = purpose;
    jsonData['userMobile'] = userMobile;
    jsonData['userOtpId'] = userOtpId;
    return jsonData;
  }
}

class UserOtp {
  UserOtpDataWrapper? data;

  UserOtp({this.data});

  UserOtp.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? UserOtpDataWrapper.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonData = {};
    if (data != null) {
      jsonData['data'] = data!.toJson();
    }
    return jsonData;
  }
}

class UserOtpDataWrapper {
  VerifyUserOtp? verifyUserOtp;

  UserOtpDataWrapper({this.verifyUserOtp});

  UserOtpDataWrapper.fromJson(Map<String, dynamic> json) {
    verifyUserOtp = json['verifyUserOtp'] != null
        ? VerifyUserOtp.fromJson(json['verifyUserOtp'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonData = {};
    if (verifyUserOtp != null) {
      jsonData['verifyUserOtp'] = verifyUserOtp!.toJson();
    }
    return jsonData;
  }
}

class VerifyUserOtp {
  String? message;
  bool? success;
  OtpDetails? data;

  VerifyUserOtp({this.message, this.success, this.data});

  VerifyUserOtp.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    success = json['success'];
    data = json['data'] != null ? OtpDetails.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonData = {};
    jsonData['message'] = message;
    jsonData['success'] = success;
    if (data != null) {
      jsonData['data'] = data!.toJson();
    }
    return jsonData;
  }
}

class OtpDetails {
  String? createdAt;
  String? expiresAt;
  bool? isUsed;
  String? otpCode;
  String? purpose;
  String? userMobile;
  int? userOtpId;

  OtpDetails({
    this.createdAt,
    this.expiresAt,
    this.isUsed,
    this.otpCode,
    this.purpose,
    this.userMobile,
    this.userOtpId,
  });

  OtpDetails.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    expiresAt = json['expiresAt'];
    isUsed = json['isUsed'];
    otpCode = json['otpCode'];
    purpose = json['purpose'];
    userMobile = json['userMobile'];
    userOtpId = json['userOtpId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonData = {};
    jsonData['createdAt'] = createdAt;
    jsonData['expiresAt'] = expiresAt;
    jsonData['isUsed'] = isUsed;
    jsonData['otpCode'] = otpCode;
    jsonData['purpose'] = purpose;
    jsonData['userMobile'] = userMobile;
    jsonData['userOtpId'] = userOtpId;
    return jsonData;
  }
}
