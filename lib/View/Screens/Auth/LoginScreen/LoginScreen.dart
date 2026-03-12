import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../../Components/Utills/TextformFiled.dart';
import '../../../../Controller/UserController.dart';
import '../../../../Service/GraphqlService/Graphql_Service.dart';
import 'OtpVerificationScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController contactController = TextEditingController();
  late GraphQLClient _client;
  late UserController userController;

  @override
  void initState() {
    super.initState();
    contactController.addListener(_handleInputChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _client = GraphQLProvider.of(context).value;
    userController = UserController(GraphQLService(_client));
  }

  void _handleInputChange() {
    final value = contactController.text;
    if (RegExp(r'^\d*$').hasMatch(value) && value.length > 10) {
      contactController.text = value.substring(0, 10);
      contactController.selection = TextSelection.fromPosition(
        TextPosition(offset: contactController.text.length),
      );
    }
  }

  @override
  void dispose() {
    contactController.dispose();
    super.dispose();
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
                        SizedBox(height: height * 0.07),

                        // Logo
                        Padding(
                          padding: const EdgeInsets.only(top: 80.0),
                          child: Image.asset(
                            'assets/Png/LoginLogo.png',
                            width: width * 0.5,
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Tagline
                        Text(
                          "Find your spot, park with ease your",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF282727),
                          ),
                        ),
                        Text(
                          "parking journey starts here",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF282727),
                          ),
                        ),

                        const SizedBox(height: 40),

                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Phone No",
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Phone input
                              CustomTextFormField(
                                hintText: "Enter your phone number",
                                controller: contactController,
                                keyboardType: TextInputType.phone,
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Phone number is required';
                                  }
                                  if (!RegExp(
                                    r'^[6-9]\d{9}$',
                                  ).hasMatch(value)) {
                                    return 'Enter a valid 10-digit phone number';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 24),

                              // Get OTP Button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      final phone =
                                          contactController.text.trim();

                                      final loginResponse = await userController
                                          .loginWithPhone(phone);

                                      if (loginResponse != null &&
                                          loginResponse
                                                  .data
                                                  ?.userAppLogin
                                                  ?.success ==
                                              true) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => OtpVerificationScreen(
                                                  phoneNumber: phone,
                                                ),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              loginResponse
                                                      ?.data
                                                      ?.userAppLogin
                                                      ?.message ??
                                                  'Login failed',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },

                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00448C),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  child: Text(
                                    "Get OTP",
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: height * 0.2),
                      ],
                    ),
                  ),
                ),

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
