import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../Values/values.dart';
import '../api/apis.dart';
import '../helper/my_date_util.dart';
import '../models/chat_user.dart';
import '../models/message.dart';
import '../screens/chat_screen.dart';
import 'dialogs/profile_dialog.dart';

//card to represent a single user in home screen
class ChatUserCard extends StatefulWidget {
  final ChatUser user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  late MediaQueryData mq;
  //last message info (if null --> no message)
  Message? _message;

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context);
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.size.width * .04, vertical: 4),
      // color: Colors.blue.shade100,
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
          onTap: () {
            //for navigating to chat screen
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatScreen(user: widget.user)));
          },
          child: StreamBuilder(
            stream: APIs.getLastMessage(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
              if (list.isNotEmpty) _message = list[0];

              return Container(
                  margin: EdgeInsets.symmetric(
                  horizontal: Utils.screenWidth * 0,
                  vertical: Utils.screenWidth * 0),
              width: double.infinity,
              height: 80,
              decoration: BoxDecoration(
              gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.pink, AppColors.lightMauveBackgroundColor],
              ),
              borderRadius: BorderRadius.circular(16)),
              child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: DecoratedBox(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: HexColor.fromHex("181A1F")),
                child: ListTile(
                  // User profile picture
                  leading: InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => ProfileDialog(user: widget.user),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(mq.size.height * .03),
                      child: CachedNetworkImage(
                        width: mq.size.height * .055,
                        height: mq.size.height * .055,
                        imageUrl: widget.user.image,
                        errorWidget: (context, url, error) => const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(CupertinoIcons.person), // Set background color of CircleAvatar to white
                        ),
                      ),
                    ),
                  ),

                  // User name
                  title: Text(
                    widget.user.name,
                    style: const TextStyle(color: Colors.white), // Set text color to white
                  ),

                  // Last message
                  subtitle: Text(
                    _message != null
                        ? _message!.type == Type.image
                        ? 'image'
                        : _message!.msg
                        : widget.user.about,
                    maxLines: 1,
                    style: const TextStyle(color: Colors.white), // Set text color to white
                  ),

                  // Last message time
                  trailing: _message == null
                      ? null // Show nothing when no message is sent
                      : _message!.read.isEmpty && _message!.fromId != APIs.user.uid
                      ? // Show for unread message
                  Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  )
                      : // Message sent time
                  Text(
                    MyDateUtil.getLastMessageTime(
                      context: context,
                      time: _message!.sent,
                    ),
                    style: const TextStyle(color: Colors.white), // Set text color to white
                  ),
                ),
              ),
              ),
              );

            },
          )),
    );
  }
}
