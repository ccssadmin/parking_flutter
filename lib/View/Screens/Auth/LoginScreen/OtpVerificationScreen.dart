import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_parking/View/Screens/HomeScreen/HomeScreen.dart';
import '../../../../Configuration/Graphql_Config.dart';
import '../../../../Controller/UserController.dart';
import '../../../../Model/ForgotPasswordOtpData.dart';
import '../../../../Service/GraphqlService/Graphql_Service.dart';
import 'ResetPasswordScreen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final ForgotPasswordOtpData? otpData;
  final String phoneNumber;

  const OtpVerificationScreen({
    super.key,

    this.otpData,
    required this.phoneNumber,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  late List<String> otpDigits;
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;
  late UserController userController;

  @override
  void initState() {
    super.initState();

    final graphqlService = GraphQLService(GraphQLConfig().client.value);
    userController = UserController(graphqlService);
    userController = Get.find<UserController>();

    // Initialize OTP digits from the otpcode if available
    final otp = widget.otpData?.otpcode ?? '';
    otpDigits = List<String>.filled(4, '');

    for (int i = 0; i < otp.length && i < 4; i++) {
      otpDigits[i] = otp[i];
    }

    otpController.text = otp;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: width * 0.07,
                      right: width * 0.07,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: height * 0.15),

                        // Logo
                        Center(
                          child: Image.asset(
                            'assets/Png/LoginLogo.png',
                            width: width * 0.5,
                            fit: BoxFit.contain,
                          ),
                        ),

                        SizedBox(height: 26),

                        // Tagline
                        Text(
                          "Please enter the OTP sent to your Number",
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF282727),
                          ),
                        ),
                        SizedBox(height: 26),

                        // Phone Number & Edit
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.phoneNumber,
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                  color: const Color(0xFF0A0101),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 4),
                                    Text(
                                      "Edit",
                                      style: GoogleFonts.roboto(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF0052B0),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: height * 0.04),

                        // OTP Display Boxes
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(4, (index) {
                            return SizedBox(
                              width: 60,
                              child: TextFormField(
                                autofocus: index == 0,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                maxLength: 1,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: const InputDecoration(
                                  counterText: "",
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black54,
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black87,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                onChanged: (value) {
                                  if (value.isNotEmpty && index < 3) {
                                    FocusScope.of(
                                      context,
                                    ).nextFocus(); // Move to next field
                                  } else if (value.isEmpty && index > 0) {
                                    FocusScope.of(
                                      context,
                                    ).previousFocus(); // Go back
                                  }
                                  otpDigits[index] = value;
                                  otpController.text = otpDigits.join();
                                },
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 20),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "30 Sec",
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  color: const Color(0xFF606060),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // Resend OTP logic
                                },
                                child: Text(
                                  "Resend OTP",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    color: const Color(0xFF0052B0),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: height * 0.05),

                        // Confirm OTP Button
                        SizedBox(
                          width: 300,
                          height: 50,
                          child: ElevatedButton(
                            onPressed:
                                isLoading
                                    ? null
                                    : () async {
                                      final enteredOtp =
                                          otpController.text.trim();

                                      if (enteredOtp.isEmpty ||
                                          enteredOtp.length != 4) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Please enter the 4-digit OTP",
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      setState(() => isLoading = true);

                                      final otpResponse = await userController
                                          .verifyOtp(
                                            phoneNumber: widget.phoneNumber,
                                            enteredOtp: enteredOtp,
                                          );

                                      setState(() => isLoading = false);

                                      if (otpResponse == null ||
                                          otpResponse
                                                  .data
                                                  ?.verifyUserOtp
                                                  ?.success !=
                                              true) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Invalid OTP or verification failed",
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.setBool('isLoggedIn', true);

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "OTP verified successfully",
                                            style: GoogleFonts.montserrat(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      );

                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => HomeScreen(),
                                        ),
                                      );
                                    },

                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00448C),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child:
                                isLoading
                                    ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    )
                                    : Text(
                                      "Log in",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                          ),
                        ),

                        SizedBox(height: height * 0.2),
                      ],
                    ),
                  ),
                ),

                // Bottom Illustration (fixed)
                Image.asset(
                  'assets/Png/LoginParking.png',
                  width: width,
                  fit: BoxFit.contain,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
