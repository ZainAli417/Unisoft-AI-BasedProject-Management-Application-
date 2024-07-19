import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../Values/values.dart';
import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../models/chat_user.dart';
import '../widgets/chat_user_card.dart';
class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({super.key});
  @override
  State<ChatHomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<ChatHomeScreen> {
  late MediaQueryData mq;
  // for storing all users
  List<ChatUser> _list = [];
  // for storing searched items
  final List<ChatUser> _searchList = [];
  // for storing search status
  bool _isSearching = false;
  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
    //for updating user active status according to lifecycle events
    //resume -- active or online
    //pause  -- inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');

      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });
  }
  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context);
    return GestureDetector(
      // for hiding keyboard when a tap is detected on the screen
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: HexColor.fromHex("#181a1f"),

        // app bar
        appBar: kIsWeb ? null : AppBar(
          backgroundColor: HexColor.fromHex("#181a1f"),

          title: _isSearching
              ? TextField(
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Search By Name',
            ),
            autofocus: true,
            style: const TextStyle(
                fontSize: 17, letterSpacing: 0.5, color: Colors.white),
            onChanged: (val) {
              _searchList.clear();

              for (var i in _list) {
                if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                    i.email.toLowerCase().contains(val.toLowerCase())) {
                  _searchList.add(i);
                  setState(() {
                    _searchList;
                  });
                }
              }
            },
          )
              : const Text(
            'Brain Storming ',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            // Search user button
            IconButton(
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                });
              },
              icon: Icon(
                _isSearching
                    ? CupertinoIcons.clear_circled_solid
                    : Icons.search,
                color: Colors.white,
              ),
            ),

            // More features button

          ],
          leading: IconButton(
            onPressed: () {
              // Handle the action for the leading button
            },
            icon: const Icon(
              Icons.chat_outlined,
              color: Colors.white,
            ),
          ),
        ),

        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton(
            onPressed: () {
              _addChatUserDialog();
            },
            child: const Icon(Icons.add_comment_rounded),
          ),
        ),
        // body
        body: StreamBuilder(
          stream: APIs.getMyUsersId(),
          // get id of only known users
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
            // if data is loading
              case ConnectionState.waiting:
              case ConnectionState.none:
                return const Center(child: CircularProgressIndicator());
            // if some or all data is loaded then show it
              case ConnectionState.active:
              case ConnectionState.done:
                return StreamBuilder(
                  stream: APIs.getAllUsers(
                    snapshot.data?.docs.map((e) => e.id).toList() ?? [],
                  ),
                  // get only those users whose ids are provided
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                    // if data is loading
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                    // if some or all data is loaded then show it
                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data = snapshot.data?.docs;
                        _list = data
                            ?.map((e) => ChatUser.fromJson(e.data()))
                            .toList() ??
                            [];
                        if (_list.isNotEmpty) {
                          return ListView.builder(
                            itemCount: _isSearching
                                ? _searchList.length
                                : _list.length,
                            padding: EdgeInsets.only(top: mq.size.height * .01),
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return ChatUserCard(
                                user: _isSearching
                                    ? _searchList[index]
                                    : _list[index],
                              );
                            },
                          );
                        } else {
                          return const Center(
                            child: Text(
                              'No Connections Found!',
                              style: TextStyle(fontSize: 20),
                            ),
                          );
                        }
                    }
                  },
                );
            }
          },
        ),
      ),
    );
  }

  // for adding new chat user
  void _addChatUserDialog() {
    String email = '';
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          contentPadding: const EdgeInsets.only(
              left: 24, right: 24, top: 20, bottom: 10),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          //title
          title: Row(
            children:  [
              Icon(
                Icons.person_add,
                color: Colors.indigo[800],
                size: 28,
              ),
              const Text('  Add User')
            ],
          ),
          //content
          content: TextFormField(
            maxLines: null,
            onChanged: (value) => email = value,
            decoration: InputDecoration(
                hintText: 'Email Id',
                prefixIcon:  Icon(Icons.email, color: Colors.indigo[800]),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15))),
          ),
          //actions
          actions: [
            //cancel button
            MaterialButton(
                onPressed: () {
                  //hide alert dialog
                  Navigator.pop(context);
                },
                child:  Text('Cancel',
                    style: TextStyle(color: Colors.indigo[800], fontSize: 16))),
            //add button
            MaterialButton(
                onPressed: () async {
                  //hide alert dialog
                  Navigator.pop(context);
                  if (email.isNotEmpty) {
                    await APIs.addChatUser(email).then((value) {
                      if (!value) {
                        Dialogs.showSnackbar(
                            context, 'User does not Exists!');
                      }
                    });
                  }
                },
                child:  Text(
                  'Add',
                  style: TextStyle(color: Colors.indigo[800], fontSize: 16),
                ))
          ],
        ));
  }
}
