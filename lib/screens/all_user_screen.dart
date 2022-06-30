import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sendbird_fcm/constants.dart';
import 'package:flutter_sendbird_fcm/models/firebase_user.dart';
import 'package:flutter_sendbird_fcm/provider/auth_provider.dart';
import 'package:flutter_sendbird_fcm/provider/chat_provider.dart';
import 'package:flutter_sendbird_fcm/screens/channel_screen.dart';
import 'package:flutter_sendbird_fcm/services/firebase_services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:sendbird_sdk/sendbird_sdk.dart';

class AllUserScreen extends StatefulWidget {
  AllUserScreen({Key? key}) : super(key: key);

  @override
  State<AllUserScreen> createState() => _AllUserScreenState();
}

class _AllUserScreenState extends State<AllUserScreen> {
  FirebaseServices _service = FirebaseServices();
  auth.User? user = auth.FirebaseAuth.instance.currentUser;
  List<GroupChannel>? channels;
  GroupChannel? achannel;

  Future<User> connect(String appId, String userId) async {
    // Init Sendbird SDK and connect with current user id
    try {
      final sendbird = SendbirdSdk(appId: appId);
      final user = await sendbird.connect(
        userId,
        nickname: prefs!.getString('_userName'),
      );
      return user;
    } catch (e) {
      print('login_view: connect: ERROR: $e');
      throw e;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    connect('05883CCA-2F39-46F2-9332-FD8B42944920', user!.uid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: primaryColor,
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              }),
          centerTitle: true,
          title: Text("All Users".toUpperCase(),
              style: TextStyle(color: Colors.white)),
        ),
        extendBody: false,
        body: StreamBuilder<QuerySnapshot>(
            stream: _service.user
                .where("id", isNotEqualTo: user!.uid)
                .where('name', isNotEqualTo: null)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }
              if (!snapshot.hasData) {
                return const SizedBox();
              }
              if (snapshot.data!.docs.isEmpty) {
                return const SizedBox();
              }

              return ListView(
                padding: EdgeInsets.only(top: 0),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  return Consumer<AuthProvider>(
                      builder: (context, provider, _) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 22,
                        child: Padding(
                          padding: const EdgeInsets.all(0.5),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 21.5,
                            child: ClipRRect(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(500)),
                              child: CachedNetworkImage(
                                imageUrl: document['profile_Pic_URL'],
                                width: MediaQuery.of(context).size.width,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    CircularProgressIndicator(
                                  color: Colors.blue,
                                  strokeWidth: 0.5,
                                ),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                            ),
                          ),
                        ),
                      ),
                      title: Text(document['name']),
                      subtitle: Text(document['email']),
                      onTap: () async {
                        try {
                          final sendbird = SendbirdSdk(
                              appId: "05883CCA-2F39-46F2-9332-FD8B42944920");

                          final users = sendbird.connect(
                            user!.uid,
                            nickname: prefs!.getString('_userName'),
                          );

                          try {
                            final query = GroupChannelListQuery()
                              ..userIdsExactlyIn = [document['id']]
                              ..limit = 1;
                            channels = await query.loadNext();
                          } catch (e) {
                            // Handle error.
                            log(e.toString() + "channel error");
                          }
                          if (channels == null) {
                            try {
                              //widget.otherUserIds?.add(widget.userId!);
                              final params = GroupChannelParams()
                                ..userIds = [user!.uid, document['id']];
                              //  ..isDistinct = true
                              //    ..channelUrl = user!.uid + "_" + document['id'];
                              achannel =
                                  await GroupChannel.createChannel(params);

                              setState(() {});
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChannelScreen(
                                    channelUrl: achannel!.channelUrl,
                                    user: firebaseUserFromJson(
                                        jsonEncode(document.data())),
                                  ),
                                ),
                              );
                              // Now you can work with the channel object.
                            } catch (e) {
                              // Handle error.
                              print(e.toString() + "channel Error ");
                            }
                          } else if (channels?.length == 0) {
                            try {
                              //widget.otherUserIds?.add(widget.userId!);
                              final params = GroupChannelParams()
                                ..userIds = [user!.uid, document['id']];
                              //  ..isDistinct = true
                              //    ..channelUrl = user!.uid + "_" + document['id'];
                              achannel =
                                  await GroupChannel.createChannel(params);

                              setState(() {});
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChannelScreen(
                                    channelUrl: achannel!.channelUrl,
                                    user: firebaseUserFromJson(
                                        jsonEncode(document.data())),
                                  ),
                                ),
                              );
                              // Now you can work with the channel object.
                            } catch (e) {
                              // Handle error.
                              print(e.toString() + "channel Error ");
                            }
                          } else {
                            achannel = channels![0];
                            setState(() {});
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChannelScreen(
                                  channelUrl: achannel!.channelUrl,
                                  user: firebaseUserFromJson(
                                      jsonEncode(document.data())),
                                ),
                              ),
                            );
                          }

                          // Retrieve any existing messages from the GroupChannel

                          // Update & prompt the UI to rebuild

                        } catch (e) {
                          log(e.toString());
                        }
                      },
                    );
                  });
                }).toList(),
              );
            }));
  }
}
