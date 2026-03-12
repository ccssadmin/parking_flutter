import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Model/TicketModel.dart';
import '../Model/UserLogin.dart';
import '../Service/GraphqlService/Graphql_Service.dart';

class UserController extends GetxController {
  final GraphQLService graphqlService;

  UserController(this.graphqlService);

  Map<String, dynamic>? lastResponseData;

  var userData = UserLoginDetails().obs;

  void setUserData(UserLoginDetails data) {
    userData.value = data;
  }


  Future<UserLogin?> loginWithPhone(String phoneNumber) async {
    try {
      final mutation = '''
        mutation {
          userAppLogin(phonenumber: "$phoneNumber") {
            message
            success
            data {
              createdAt
              expiresAt
              isUsed
              otpCode
              purpose
              userMobile
              userOtpId
            }
          }
        }
      ''';

      final result = await graphqlService.performMutation(mutation);

      if (result.hasException) {
        print("Login Error: ${result.exception.toString()}");
        return null;
      }

      final data = result.data;
      if (data == null || data['userAppLogin'] == null) {
        print("Login response is empty.");
        return null;
      }

      final login = UserLogin(
        data: UserLoginDataWrapper(
          userAppLogin: UserAppLogin.fromJson(data['userAppLogin']),
        ),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'userMobile',
        login.data?.userAppLogin?.data?.userMobile ?? '',
      );

      await prefs.setInt(
        'userOtpId',
        login.data?.userAppLogin?.data?.userOtpId ?? 0,
      );

      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userLoginData', jsonEncode(login.toJson()));

      return login;
    } catch (e) {
      print("Exception during userAppLogin: $e");
      return null;
    }
  }

  // ✅ OTP verification function
  Future<UserOtp?> verifyOtp({
    required String phoneNumber,
    required String enteredOtp,
  }) async {
    try {
      final mutation = '''
        mutation {
          verifyUserOtp(phonenumber: "$phoneNumber", enteredOtp: "$enteredOtp") {
            message
            success
            data {
              createdAt
              expiresAt
              isUsed
              otpCode
              purpose
              userMobile
              userOtpId
            }
          }
        }
      ''';

      final result = await graphqlService.performMutation(mutation);

      if (result.hasException) {
        print("OTP Verification Error: ${result.exception.toString()}");
        return null;
      }

      final data = result.data;
      if (data == null || data['verifyUserOtp'] == null) {
        print("OTP Verification response is empty.");
        return null;
      }

      final otpResponse = UserOtp(
        data: UserOtpDataWrapper(
          verifyUserOtp: VerifyUserOtp.fromJson(data['verifyUserOtp']),
        ),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('otpVerified', otpResponse.data?.verifyUserOtp?.success ?? false);
      await prefs.setString('otpResponseData', jsonEncode(otpResponse.toJson()));

      return otpResponse;
    } catch (e) {
      print("Exception during verifyUserOtp: $e");
      return null;
    }
  }

  Future<List<UserTicketItem>> getUserTickets(String phoneNumber) async {
    try {
      final query = '''
      query {
        userTicket(phonenumber: "$phoneNumber") {
          inDate
          inTime
          outDate
          outTime
          parkingLotName
          paymentStatus
          totalAmount
          totalHours
        }
      }
    ''';

      final result = await graphqlService.performQuery(query);

      if (result.hasException) {
        print("Get Tickets Error: ${result.exception.toString()}");
        return [];
      }

      final data = result.data;

      if (data == null || data['userTicket'] == null) {
        print("UserTicket response is empty.");
        return [];
      }

      // Deserialize directly into a list of UserTicketItem
      List<UserTicketItem> tickets = (data['userTicket'] as List)
          .map((e) => UserTicketItem.fromJson(e))
          .toList();

      return tickets;
    } catch (e) {
      print("Exception during getUserTickets: $e");
      return [];
    }
  }


}
