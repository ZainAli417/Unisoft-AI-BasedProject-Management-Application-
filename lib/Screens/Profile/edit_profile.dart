// ignore_for_file: avoid_print

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unisoft/Screens/Onboarding/onboarding_carousel.dart';
import 'package:unisoft/Screens/Profile/my_profile.dart';
import 'package:unisoft/constants/app_constans.dart';
import 'package:unisoft/constants/back_constants.dart';
import 'package:unisoft/controllers/userController.dart';
import 'package:unisoft/models/User/User_model.dart';
import 'package:unisoft/services/auth_service.dart';
import 'package:unisoft/widgets/Buttons/primary_buttons.dart';
import 'package:unisoft/widgets/Snackbar/custom_snackber.dart';

import '../../Values/values.dart';
import '../../widgets/Buttons/primary_progress_button.dart';
import '../../widgets/DarkBackground/darkRadialBackground.dart';
import '../../widgets/Dashboard/dashboard_meeting_details.dart';
import '../../widgets/Forms/form_input_with _label.dart';
import '../../widgets/Navigation/app_header.dart';
import '../../widgets/dummy/profile_dummy.dart';

class EditProfilePage extends StatefulWidget {
  final UserModel? user;
  const EditProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String name = "";
  RegExp regExletters = RegExp(r"(?=.*[a-z])\w+");
  RegExp regExnumbers = RegExp(r"(?=.*[0-9])\w+");
  RegExp regExbigletters = RegExp(r"(?=.*[A-Z])\w+");

  RegExp regEx2 = RegExp(r'[^\w\d\u0600-\u06FF\s]');
  String password = "";
  String userName = "";
  String bio = "";
  String email = "";
  final nameController = TextEditingController();
  final userNameController = TextEditingController();
  final passController = TextEditingController();
  final emailController = TextEditingController();
  final bioController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    name = widget.user!.name!;
    nameController.text = widget.user!.name!;
    userName = widget.user!.userName ?? "";
    userNameController.text = widget.user!.userName ?? "";
    bio = widget.user!.bio ?? "";
    bioController.text = widget.user!.bio ?? "";
    email = widget.user!.email ?? "";
    emailController.text = widget.user!.email ?? "";
  }

  @override
  Widget build(BuildContext context) {
    const String tabSpace = "\t\t\t";

    return Scaffold(
      body: Stack(
        children: [
          DarkRadialBackground(
            color: HexColor.fromHex("#181a1f"),
            position: "topLeft",
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                  right: 10, // Adjust the percentage as needed
                  left: 10,
                  top: 10),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TaskezAppHeader(
                        title: "$tabSpace ${AppConstants.edit_profile_key.tr}",
                        widget: PrimaryProgressButton(
                          callback: () async {
                            try {
                              bool pop = false;
                              bool changes = false;
                              print(name.trim());
                              if (formKey.currentState!.validate()) {
                                showDialogMethod(context);

                                if (selectedImagePath != null) {
                                  showDialogMethod(context);
                                  print("start");
                                  final resOfUpload = await uploadImageToStorge(
                                      selectedImagePath: selectedImagePath!,
                                      imageName: AuthService.instance
                                          .firebaseAuth.currentUser!.uid,
                                      folder: "Users");
                                  resOfUpload.fold((left) {
                                    Get.key.currentState!.pop();
                                    CustomSnackBar.showError(
                                        "${left.toString()} ");
                                  }, (right) async {
                                    right.then((value) async {
                                      String imageNetWork = value!;
                                      await UserController().updateUser(
                                          id: AuthService.instance.firebaseAuth
                                              .currentUser!.uid,
                                          data: {imageUrlK: imageNetWork});
                                      Get.key.currentState!.pop();
                                    });
                                  });
                                }

                                if (name.trim() != widget.user!.name) {
                                  name = name.trim();
                                  await UserController().updateUser(
                                      data: {nameK: name}, id: widget.user!.id);
                                  changes = true;
                                }
                                if (userName.isNotEmpty &&
                                    userName.trim() != widget.user!.userName) {
                                  userName = userName.trim();
                                  await UserController().updateUser(
                                      data: {userNameK: userName},
                                      id: widget.user!.id);
                                  changes = true;
                                  // UserName field has been updated
                                  // Perform the necessary action
                                }

                                if (bio.isNotEmpty &&
                                    bio.trim() != widget.user!.bio) {
                                  bio = bio.trim();
                                  await UserController().updateUser(
                                      data: {bioK: bio}, id: widget.user!.id);
                                  changes = true;
                                  // Bio field has been updated
                                  // Perform the necessary action
                                }

                                if (email.isNotEmpty &&
                                    email.trim() != widget.user!.email) {
                                  email = email.trim();
                                  var emailupdate = await AuthService.instance
                                      .updateEmail(email: email);

                                  emailupdate.fold((left) async {
                                    CustomSnackBar.showError(left.toString());
                                  }, (right) async {
                                    print(email);
                                    print(emailController.text);
                                    print("email");
                                    await UserController().updateUser(
                                        data: {emailK: email},
                                        id: widget.user!.id);
                                    print("email2");
                                    pop = true;
                                    Navigator.of(context).pop();
                                    CustomSnackBar.showSuccess(AppConstants
                                        .email_updated_successfully_key.tr);
                                    AuthService.instance.logOut();
                                    changes = true;
                                    Get.offAll(
                                        () => const OnboardingCarousel());
                                    return;
                                  });

                                  // Email field has been updated
                                  // Perform the necessary action
                                }
                                if (!pop) {
                                  Navigator.of(context).pop();
                                  Get.off(
                                      () => ProfilePage(user: widget.user!));
                                }
                                if (changes) {
                                  CustomSnackBar.showSuccess(
                                      AppConstants.updated_successfully_key.tr);
                                }
                              }
                            } on Exception catch (e) {
                              Navigator.of(context).pop();
                              CustomSnackBar.showError(e.toString());
                            }
                          },
                          width: 20, // Adjust the percentage as needed
                          height: 20,
                          label: AppConstants.save_key.tr,
                          textStyle: GoogleFonts.lato(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Container(
                          constraints: const BoxConstraints(
                            maxWidth: 600,
                          ),
                          child: Column(
                            children: [
                              Builder(builder: (context) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          _showImagePickerDialog(context);
                                        },
                                        child: Stack(
                                          children: [
                                            ProfileDummy(
                                              imageType:
                                                  selectedImagePath == null
                                                      ? ImageType.Network
                                                      : ImageType.File,
                                              color: HexColor.fromHex("94F0F1"),
                                              dummyType: ProfileDummyType.Image,
                                              scale: 4.0,
                                              image: selectedImagePath ??
                                                  widget.user!.imageUrl,
                                            ),
                                            Visibility(
                                              visible:
                                                  selectedImagePath == null,
                                              child: Container(
                                                width: 70,
                                                height: 70,
                                                decoration: BoxDecoration(
                                                    color: AppColors
                                                        .primaryAccentColor
                                                        .withOpacity(0.45),
                                                    shape: BoxShape.circle),
                                                child: const Icon(
                                                    FeatherIcons.camera,
                                                    color: Colors.white,
                                                    size: 20),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                              AppSpaces.verticalSpace20,
                              LabelledFormInput(
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return AppConstants
                                          .name_can_not_be_empty_key.tr;
                                    }
                                    if (regExnumbers.hasMatch(value) ||
                                        regEx2.hasMatch(value)) {
                                      return AppConstants
                                          .the_name_can_not_contain_numbers_or_symbols_key
                                          .tr;
                                    }
                                    return null;
                                  },
                                  onChanged: (value) async {
                                    setState(() {
                                      name = value;
                                    });
                                  },
                                  onClear: () {
                                    setState(() {
                                      name = "";
                                      nameController.text = "";
                                    });
                                  },
                                  autovalidateMode: AutovalidateMode.always,
                                  readOnly: false,
                                  placeholder: widget.user!.name!,
                                  keyboardType: "text",
                                  controller: nameController,
                                  obscureText: false,
                                  label: AppConstants.your_name_key.tr),
                              AppSpaces.verticalSpace20,
                              Visibility(
                                visible: !AuthService.instance.firebaseAuth
                                    .currentUser!.isAnonymous,
                                child: LabelledFormInput(
                                    onChanged: (value) {
                                      setState(() {
                                        userName = value;
                                      });
                                    },
                                    onClear: () {
                                      setState(() {
                                        userName = "";
                                        userNameController.text = "";
                                      });
                                    },
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    readOnly: false,
                                    placeholder: widget.user!.userName == null
                                        ? ""
                                        : widget.user!.userName!,
                                    keyboardType: "text",
                                    controller: userNameController,
                                    obscureText: false,
                                    label: AppConstants.your_username_key.tr),
                              ),
                              AppSpaces.verticalSpace20,
                              Visibility(
                                visible: !AuthService.instance.firebaseAuth
                                    .currentUser!.isAnonymous,
                                child: LabelledFormInput(
                                    validator: (value) {
                                      if (!EmailValidator.validate(value!)) {
                                        return AppConstants
                                            .enter_valid_email_key.tr;
                                      } else {
                                        return null;
                                      }
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        email = value;
                                      });
                                    },
                                    onClear: () {
                                      setState(() {
                                        email = "";
                                        emailController.text = "";
                                      });
                                    },
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    readOnly: false,
                                    placeholder: widget.user!.email == null
                                        ? ""
                                        : widget.user!.email!,
                                    keyboardType: "text",
                                    controller: emailController,
                                    obscureText: false,
                                    label: AppConstants.your_email_key.tr),
                              ),
                              AppSpaces.verticalSpace20,
                              LabelledFormInput(
                                  onChanged: (value) {
                                    bio = value;
                                  },
                                  onClear: () {
                                    bio = "";
                                    bioController.text = "";
                                  },
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  readOnly: false,
                                  placeholder: widget.user!.bio == null
                                      ? ""
                                      : widget.user!.bio!,
                                  keyboardType: "text",
                                  controller: bioController,
                                  obscureText: false,
                                  label: AppConstants.bio_key.tr),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible: !AuthService
                            .instance.firebaseAuth.currentUser!.isAnonymous,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 25),
                          child: AppPrimaryButton(
                              callback: () {
                                CustomDialog.showPasswordDialog(context);
                              },
                              buttonText: AppConstants.change_password_key.tr,
                              buttonHeight: 50,
                              buttonWidth: 175),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  String? selectedImagePath;
  void _showImagePickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppConstants.choose_an_image_key.tr,
            //'Choose an Image'
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Text(AppConstants.camera_key.tr),
                  onTap: () {
                    _getImage(ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                ),
                const Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: Text(AppConstants.gallery_key.tr),
                  onTap: () {
                    _getImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  },
                ),
                const Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: Text(AppConstants.cancel_key.tr),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    ).then((value) {
      if (value == null) {
        // Handle the case where the user did not choose a photo
        // Display a message or perform any required actions
      }
    });
  }

  void _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        selectedImagePath = pickedFile.path;
      });
    }
  }
}
