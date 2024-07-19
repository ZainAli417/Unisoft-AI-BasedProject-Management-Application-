import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unisoft/Screens/Auth/email_address.dart';
import 'package:unisoft/Screens/Auth/resetPassword.dart';
import 'package:unisoft/Screens/Auth/verify_email_address.dart';
import 'package:unisoft/Screens/Dashboard/timeline.dart';
import 'package:unisoft/constants/app_constans.dart';
import 'package:unisoft/services/auth_service.dart';
import 'package:unisoft/widgets/Snackbar/custom_snackber.dart';

import '../../Values/values.dart';
import '../../widgets/DarkBackground/darkRadialBackground.dart';
import '../../widgets/Forms/form_input_with _label.dart';
import '../../widgets/Navigation/back.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String email = "";
  String password = "";
  bool obscureText = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(children: [
        DarkRadialBackground(
          color: HexColor.fromHex("#181a1f"),
          position: "topLeft",
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const NavigationBack(),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text(
                              AppConstants.login_key.tr,
                              //'Login',
                              style: GoogleFonts.lato(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold),
                            ),
                            //say Hi
                            AppSpaces.verticalSpace20,
                            Text(
                              AppConstants.nice_to_see_you_key.tr,
                              // 'Nice to see You!',
                              style: GoogleFonts.laila(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    LabelledFormInput(
                      autovalidateMode: AutovalidateMode.disabled,
                      validator: (value) {
                        if (!EmailValidator.validate(value!)) {
                          return AppConstants.enter_valid_email_key.tr;
                          // "Enter Valid Email";
                        } else {
                          return null;
                        }
                      },
                      onClear: () {
                        setState(() {
                          email = "";
                          _emailController.text = "";
                        });
                      },
                      onChanged: (value) {
                        setState(() {
                          email = value;
                        });
                      },
                      readOnly: false,
                      placeholder: AppConstants.email_key.tr,
                      //"Email",
                      keyboardType: "text",
                      controller: _emailController,
                      obscureText: false,
                      label: AppConstants.your_email_key.tr,
                      //"Your Email"
                    ),
                    LabelledFormInput(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return AppConstants.password_can_not_be_empty_key.tr;
                          // "Password Can not be Empty";
                        }
                        return null;
                      },
                      onClear: () {
                        setState(() {
                          obscureText = !obscureText;
                          // password = "";
                          // _passController.text = "";
                        });
                      },
                      onChanged: (value) {
                        setState(() {
                          password = value;
                        });
                      },
                      autovalidateMode: AutovalidateMode.disabled,
                      readOnly: false,
                      placeholder: AppConstants.password_key.tr,
                      //"Password",
                      keyboardType: "text",
                      controller: _passController,
                      obscureText: obscureText,
                      label: AppConstants.your_password_key.tr,
                      //"Your Password"
                    ),
                    AppSpaces.verticalSpace20,
                    GestureDetector(
                      onTap: () {
                          Get.to(() => const ResetPasswordScreen());
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Text(
                              AppConstants.forget_Password_key.tr,
                              // 'Forget Password?',
                              style: TextStyle(
                                color: Colors.grey[300],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    AppSpaces.verticalSpace20,

                    // const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            try {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  });

                              UserCredential userCredential =
                                  await AuthService().sigInWithEmailAndPassword(
                                      email: email, password: password);
                              Navigator.of(context).pop();

                              // CustomSnackBar.showSuccess(
                              //     "Sign IN Successfully");
                              if (userCredential.user!.emailVerified) {
                                Get.offAll(() => const Timeline());
                              } else {
                                Get.to(() => const VerifyEmailAddressScreen());
                              }
                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'user-not-found') {
                                CustomSnackBar.showError(AppConstants
                                        .no_user_found_for_that_email_key.tr
                                    // "No user found for that email"
                                    );
                              }
                              if (e.code == 'wrong-password') {
                                CustomSnackBar.showError(AppConstants
                                        .wrong_password_provided_for_that_user_key
                                        .tr
                                    //  "Wrong password provided for that user"
                                    );
                              } else {
                                CustomSnackBar.showError(
                                    e.code.replaceAll(RegExp(r'-'), " "));
                              }
                              Navigator.of(context).pop();

                              return;
                            } catch (e) {
                              Navigator.of(context).pop();

                              CustomSnackBar.showError(e.toString());
                            }
                          }
                        },
                        style: ButtonStyles.blueRounded,
                        child: Text(
                          AppConstants.sign_in_key.tr,
//                          'Sign In',
                          style: GoogleFonts.lato(
                              fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ),
                    AppSpaces.verticalSpace20,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppConstants.dont_have_an_account_key.tr,
                          //     'Don\'t have an account? ',
                          style: const TextStyle(color: Colors.white),
                        ),
                        GestureDetector(
                          //onTap: widget.onTap,
                          onTap: () {
                            Get.to(() => const EmailAddressScreen());
                          },
                          child: Text(
                            AppConstants.make_one_key.tr,
                            // 'Make One!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryAccentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      ]),
    );
  }
}
