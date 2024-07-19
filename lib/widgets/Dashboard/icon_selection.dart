import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unisoft/constants/app_constans.dart';

import '../../Values/values.dart';
import '../Buttons/primary_progress_button.dart';

class IconSelectionDialog extends StatefulWidget {
  final Function(IconData) onSelectedIconChanged;
  final IconData initialIcon;
  const IconSelectionDialog({
    Key? key,
    required this.onSelectedIconChanged,
    required this.initialIcon,
  }) : super(key: key);

  @override
  _IconSelectionDialogState createState() => _IconSelectionDialogState();
}

class _IconSelectionDialogState extends State<IconSelectionDialog> {
  late ValueNotifier<int> selectedIconIndex;

  @override
  void initState() {
    super.initState();
    selectedIconIndex = ValueNotifier<int>(0);
    setInitialIconIndex();
  }

  @override
  void dispose() {
    selectedIconIndex.dispose();
    super.dispose();
  }

  void setInitialIconIndex() {
    int initialIndex =
        iconList.indexWhere((icon) => icon == widget.initialIcon);
    if (initialIndex != -1) {
      selectedIconIndex.value = initialIndex;
    }
  }

  IconData getSelectedIcon() {
    return iconList[selectedIconIndex.value];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: HexColor.fromHex("#181a1f"),
      title: Text(
        AppConstants.choose_icon_key.tr,
        style: AppTextStyles.header2,
      ),
      content: SingleChildScrollView(
        child: Wrap(
          spacing: 8,
          children: List.generate(
            iconList.length,
            (index) => ValueListenableBuilder<int>(
              valueListenable: selectedIconIndex,
              builder: (context, value, child) {
                return GestureDetector(
                  onTap: () {
                    selectedIconIndex.value = index;
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selectedIconIndex.value == index
                            ? HexColor.fromHex("266FFE")
                            : HexColor.fromHex("181A1F"),
                        width: 2,
                      ),
                    ),
                    child: Icon(iconList[index], color: Colors.white),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text(
                AppConstants.close_key.tr,
                style: GoogleFonts.lato(
                  color: HexColor.fromHex("616575"),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            PrimaryProgressButton(
              width: Utils.screenWidth * 0.25,
              label: AppConstants.oK_key.tr,
              callback: () {
                // Do something with the selected icon
                widget.onSelectedIconChanged(getSelectedIcon());
                Get.back();
              },
            ),
          ],
        )
      ],
    );
  }
}

final List<IconData> iconList = [
  Icons.home,
  Icons.design_services,
  Icons.mark_unread_chat_alt,
  Icons.message,
  Icons.settings,
  Icons.account_circle,
  Icons.home,

];
