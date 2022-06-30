import 'dart:convert';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_sendbird_fcm/constants.dart';
import 'package:flutter_sendbird_fcm/main.dart';
import 'package:flutter_sendbird_fcm/models/firebase_user.dart';
import 'package:flutter_sendbird_fcm/provider/chat_list_provider.dart';
import 'package:flutter_sendbird_fcm/screens/channel_screen.dart';
import 'package:flutter_sendbird_fcm/screens/my_profile_screen.dart';
import 'package:flutter_sendbird_fcm/services/firebase_services.dart';
import 'package:flutter_sendbird_fcm/services/push_notification_service.dart';
import 'package:flutter_sendbird_fcm/utility/channel_title_text_view.dart';
import 'package:flutter_sendbird_fcm/utility/extensions.dart';
import 'package:provider/provider.dart';

import 'package:sendbird_sdk/sendbird_sdk.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LandingScreen extends StatefulWidget {
  LandingScreen({Key? key}) : super(key: key);

  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with ChannelEventHandler, WidgetsBindingObserver {
  late FirebaseNotifcation firebase;
  late WebViewController controller;
  double containerHeight = 0;
  var containerMaxHeight;

  String greetingText = "";
  FirebaseServices _service = FirebaseServices();
  auth.User? user = auth.FirebaseAuth.instance.currentUser;
  ChatListProvider model = ChatListProvider();

  Future<List<GroupChannel>> getGroupChannels() async {
    try {
      final query = GroupChannelListQuery()
        ..includeEmptyChannel = true
        ..order = GroupChannelListOrder.latestLastMessage
        ..userIdsIncludeIn = [user!.uid]
        ..limit = 15;
      return await query.loadNext();
    } catch (e) {
      print('getGroupChannels: ERROR: $e');
      return [];
    }
  }

  Future<User> connect(String appId, String userId) async {
    try {
      final sendbird = SendbirdSdk(appId: appId);
      final user = await sendbird.connect(
        userId,
        nickname: prefs!.getString('_userName'),
      );
      //print(jsonDecode(user.toString()));
      return user;
    } catch (e) {
      print('connect: ERROR: $e');
      throw e;
    }
  }

  String greeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      greetingText = 'Good Morning';

      return greetingText;
    }
    if (hour < 20) {
      greetingText = 'Good Afternoon';

      return greetingText;
    } else {
      greetingText = 'Good Evening';

      return greetingText;
    }
  }

  handleAsync() async {
    await firebase.initialize(context);
    await firebase.subscribeToTopic('user');
    await firebase.getToken();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    greeting();
    SendbirdSdk().addChannelEventHandler('channel_list_view', this);

    connect('05883CCA-2F39-46F2-9332-FD8B42944920', user!.uid).then((value) {
      model.loadChannelList();
    });
    firebase = FirebaseNotifcation(context: context);
    handleAsync();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      model.loadChannelList(reload: true);
    }
  }

  @override
  void dispose() {
    SendbirdSdk().removeChannelEventHandler("channel_list_view");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    containerMaxHeight = MediaQuery.of(context).size.height -
        (kToolbarHeight + MediaQuery.of(context).padding.top);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MyProfileScreen(
                          appBarVisibility: true,
                        ))).whenComplete(() {
              if (mounted) model.loadChannelList(reload: true);
              ;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 22,
                child: Padding(
                  padding: const EdgeInsets.all(0.5),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 21.5,
                    child: ClipRRect(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      borderRadius: BorderRadius.all(Radius.circular(500)),
                      child: CachedNetworkImage(
                        imageUrl: prefs!.getString('_userPicURL')!,
                        width: MediaQuery.of(context).size.width,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            CircularProgressIndicator(
                          color: Colors.blue,
                          strokeWidth: 0.5,
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Container(
                  height: 30,
                  width: 1,
                  color: Colors.white,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(greeting(),
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                          backgroundColor: primaryColor,
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          letterSpacing: 1)),
                  Text(prefs!.getString('_userName')!,
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            fontSize: 16,
                            color: Colors.white,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.bold,
                          ))
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/alluser-screen')
                    .whenComplete(() {
                  if (mounted) model.loadChannelList(reload: true);
                });
              },
              icon: Icon(
                Icons.person_add_alt,
                color: Colors.white,
              ))
        ],
      ),
      extendBody: false,
      body: ChangeNotifierProvider<ChatListProvider>(
        create: (context) => model,
        child: Consumer<ChatListProvider>(
          builder: (context, value, child) {
            return _buildList(value);
          },
        ),
      ),
    );
  }

  Widget _buildList(ChatListProvider model) {
    if (model.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () async {
        await model.loadChannelList(reload: true);
      },
      child: model.itemCount == 0
          ? Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "No Messages!",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(height: 20),
                  TextButton.icon(
                      style: TextButton.styleFrom(
                          side: BorderSide(width: 1.5, color: kSecondaryColor)),
                      onPressed: () {
                        Navigator.pushNamed(context, '/alluser-screen')
                            .whenComplete(() {
                          if (mounted) model.loadChannelList(reload: true);
                        });
                      },
                      icon: Icon(Icons.person_add_alt_1, color: primaryColor),
                      label: Text(
                        "Add new Friend",
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            color: primaryColor, fontWeight: FontWeight.bold),
                      ))
                ],
              ),
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: model.lstController,
              itemCount: model.itemCount,
              separatorBuilder: (context, index) {
                return Container(
                    margin: EdgeInsets.only(left: 88),
                    height: 1,
                    color: Colors.grey);
              },
              itemBuilder: (context, index) {
                if (index == model.groupChannels.length && model.hasNext) {
                  return LinearProgressIndicator(
                    color: secondaryColor,
                  );
                }

                final channel = model.groupChannels[index];
                List<String> namesList = [
                  for (final member in channel.members)
                    if (member.userId != sendbird.currentUser?.userId)
                      member.userId
                ];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
                  child: InkWell(
                    child: ChannelListItem(channel: channel),
                    onTap: () {
                      EasyLoading.show(status: "Loading...");
                      _service.user.doc(namesList[0]).get().then((value) {
                        EasyLoading.dismiss();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChannelScreen(
                                channelUrl: channel.channelUrl,
                                user: firebaseUserFromJson(
                                    jsonEncode(value.data()))),
                          ),
                        ).whenComplete(() {
                          if (mounted) model.loadChannelList(reload: true);
                        });
                      });
                    },
                  ),
                );
              },
            ),
    );
  }
}

class ChannelListItem extends StatelessWidget {
  final GroupChannel channel;
  final currentUserId = sendbird.currentUser?.userId;

  ChannelListItem({required this.channel});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 50,
            width: 50,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(50)),
            child: Image.network(channel.coverUrl!),
          ),
          // AvatarView(
          //   channel: channel,
          //   currentUserId: currentUserId,
          //   width: 56,
          //   height: 56,
          // ),
          _buildContent(context),
          _buildTailing(context),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    BaseMessage? lastMessage = channel.lastMessage;
    String message;
    if (lastMessage is FileMessage) {
      message = lastMessage.name ?? '';
    } else {
      message = lastMessage?.message ?? '';
    }
    List<String> namesList = [
      for (final member in channel.members)
        if (member.userId != currentUserId) member.nickname
    ];
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(left: 16, right: 16, top: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ChannelTitleTextView(this.channel, currentUserId),

            Text(namesList[0],
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            SizedBox(height: 2),
            Text(
              message,
              maxLines: 2,
              style: Theme.of(context).textTheme.bodyText2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTailing(BuildContext context) {
    int lastDate = channel.lastMessage?.createdAt ?? 0;
    String lastMessageDateString = lastDate.readableTimestamp();
    final count = channel.unreadMessageCount <= 99
        ? '${channel.unreadMessageCount}'
        : '99+';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          lastMessageDateString,
          style: Theme.of(context).textTheme.bodyText1,
        ),
        SizedBox(height: 10),
        if (channel.unreadMessageCount != 0)
          Container(
            decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(offset: Offset(0.5, 0.5), color: Colors.black45)
                ],
                borderRadius: BorderRadius.circular(12),
                color: Colors.redAccent),
            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 6),
            child: Text("$count",
                style: Theme.of(context).textTheme.bodyText2!.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    shadows: [
                      Shadow(offset: Offset(0.5, 0.5), color: Colors.white)
                    ])),
          ),
      ],
    );
  }
}
