import 'package:decimal/decimal.dart';

class UserTicket {
  UserTicketDataWrapper? data;

  UserTicket({this.data});

  UserTicket.fromJson(Map<String, dynamic> json) {
    data =
        json['data'] != null
            ? UserTicketDataWrapper.fromJson(json['data'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonData = {};
    if (data != null) {
      jsonData['data'] = data!.toJson();
    }
    return jsonData;
  }
}

class UserTicketDataWrapper {
  List<UserTicketItem>? userTicket;

  UserTicketDataWrapper({this.userTicket});

  UserTicketDataWrapper.fromJson(Map<String, dynamic> json) {
    if (json['userTicket'] != null) {
      userTicket = <UserTicketItem>[];
      json['userTicket'].forEach((v) {
        userTicket!.add(UserTicketItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonData = {};
    if (userTicket != null) {
      jsonData['userTicket'] = userTicket!.map((v) => v.toJson()).toList();
    }
    return jsonData;
  }
}

class UserTicketItem {
  String? inDate;
  String? inTime;
  String? outDate;
  String? outTime;
  String? parkingLotName;
  String? paymentStatus;
  Decimal? totalAmount;
  String? totalHours;

  UserTicketItem({
    this.inDate,
    this.inTime,
    this.outDate,
    this.outTime,
    this.parkingLotName,
    this.paymentStatus,
    this.totalAmount,
    this.totalHours,
  });

  UserTicketItem.fromJson(Map<String, dynamic> json) {
    inDate = json['inDate'];
    inTime = json['inTime'];
    outDate = json['outDate'];
    outTime = json['outTime'];
    parkingLotName = json['parkingLotName'];
    paymentStatus = json['paymentStatus'];
    totalAmount =
        json['totalAmount'] != null
            ? Decimal.parse(json['totalAmount'].toString())
            : null;
    totalHours = json['totalHours'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonData = {};
    jsonData['inDate'] = inDate;
    jsonData['inTime'] = inTime;
    jsonData['outDate'] = outDate;
    jsonData['outTime'] = outTime;
    jsonData['parkingLotName'] = parkingLotName;
    jsonData['paymentStatus'] = paymentStatus;
    jsonData['totalAmount'] = totalAmount;
    jsonData['totalHours'] = totalHours;
    return jsonData;
  }
}
