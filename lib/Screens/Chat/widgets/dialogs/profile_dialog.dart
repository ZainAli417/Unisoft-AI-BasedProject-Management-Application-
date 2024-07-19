import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/chat_user.dart';

class ProfileDialog extends StatelessWidget {
  
   ProfileDialog({super.key, required this.user});
  late MediaQueryData mq;

  final ChatUser user;

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context);

    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white.withOpacity(.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
          width: mq.size.width * .6,
          height: mq.size.height * .35,
          child: Stack(
            children: [
              //user profile picture
              Positioned(
                top: mq.size.height * .075,
                left: mq.size.width * .1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(mq.size.height * .25),
                  child: CachedNetworkImage(
                    width: mq.size.width * .5,
                    fit: BoxFit.cover,
                    imageUrl: user.image,
                    errorWidget: (context, url, error) =>
                        const CircleAvatar(child: Icon(CupertinoIcons.person)),
                  ),
                ),
              ),

              //user name
              Positioned(
                left: mq.size.width * .04,
                top: mq.size.height * .02,
                width: mq.size.width * .55,
                child: Text(user.name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w500)),
              ),

            ],
          )),
    );
  }
}
