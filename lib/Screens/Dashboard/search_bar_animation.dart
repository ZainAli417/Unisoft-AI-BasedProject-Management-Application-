import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unisoft/constants/app_constans.dart';
import 'package:searchbar_animation/searchbar_animation.dart';

import '../../Values/values.dart';

class MySearchBarWidget extends StatelessWidget {
  final TextEditingController editingController;
  final String searchWord;
  final Function? onChanged;
  const MySearchBarWidget(
      {required this.searchWord,
      Key? key,
      required this.editingController,
      required this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isArabic = Directionality.of(context) == TextDirection.rtl;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: SearchBarAnimation(
        hintText: "${AppConstants.search_in_key.tr} $searchWord",
        searchBoxColour: HexColor.fromHex("616575"),
        searchBoxWidth: Get.width * 0.5,
        // isSearchBoxOnRightSide: isArabic,
        textEditingController: editingController,
        isOriginalAnimation: true,
        enableKeyboardFocus: true,
        onExpansionComplete: () {
          debugPrint('do something just after searchbox is opened.');
        },
        onCollapseComplete: () {
          debugPrint('do something just after searchbox is closed.');
        },
        onPressButton: (isSearchBarOpens) {
          debugPrint(
              'do something before animation started. It\'s the ${isSearchBarOpens ? 'opening' : 'closing'} animation');
        },
        trailingWidget: InkWell(
          onTap: () {
            editingController.clear();
          },
          child: const Icon(
            Icons.clear,
            size: 20,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        secondaryButtonWidget: const Icon(
          Icons.close,
          size: 20,
          color: Colors.black,
        ),
        buttonWidget: const Icon(
          Icons.search,
          size: 20,
          color: Colors.black,
        ),
        // textAlignToRight: true,
        onChanged: onChanged,
      ),
    );
  }
}
