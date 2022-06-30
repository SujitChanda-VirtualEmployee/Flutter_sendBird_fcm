import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sendbird_fcm/constants.dart';
import 'package:flutter_sendbird_fcm/models/firebase_user.dart';
import 'package:flutter_sendbird_fcm/provider/chat_provider.dart';
import 'package:flutter_sendbird_fcm/screens/chat_screen/components/file_message_item.dart';
import 'package:flutter_sendbird_fcm/screens/chat_screen/components/message_input.dart';
import 'package:flutter_sendbird_fcm/screens/chat_screen/components/user_message_item.dart';
import 'package:flutter_sendbird_fcm/utility/avatar_view.dart';
import 'package:flutter_sendbird_fcm/utility/channel_title_text_view.dart';
import 'package:provider/provider.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'chat_screen/components/admin_message_item.dart';

class ChannelScreen extends StatefulWidget {
  final String channelUrl;
  final FirebaseUser user;

  ChannelScreen({required this.channelUrl, required this.user, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChannelScreenState();
}

class _ChannelScreenState extends State<ChannelScreen>
    with WidgetsBindingObserver {
  late ChatProvider model;
  bool channelLoaded = false;

  @override
  void initState() {
    model = ChatProvider(channelUrl: widget.channelUrl);
    model.loadChannel().then((value) {
      setState(() {
        channelLoaded = true;
      });
      model.loadMessages(reload: true);
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      model.loadMessages(reload: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChatProvider>(
      create: (context) => model,
      child: (!channelLoaded)
          ? Scaffold(
              body: Center(
                child: Container(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(),
                ),
              ),
            )
          : VisibilityDetector(
              onVisibilityChanged: (info) {
                // screenBecomeVisible(
                //   info.visibleFraction == 1,
                //   pop: PopType.replace,
                // );
              },
              key: Key('channel_key'),
              child: Scaffold(
                appBar: _buildNavigationBar(),
                body: SafeArea(
                  child: Column(
                    children: [
                      //TODO: message
                      // p.Selector<ChannelViewModel, List<BaseMessage>>(
                      //   selector: (_, model) => model.messages,
                      //   builder: (c, msgs, child) {
                      //     return _buildContent();
                      //   },
                      // ),
                      Consumer<ChatProvider>(
                        builder: (context, value, child) {
                          return _buildContent();
                        },
                      ),
                      Selector<ChatProvider, bool>(
                        selector: (_, model) => model.isEditing,
                        builder: (c, editing, child) {
                          return MessageInput(
                            onPressPlus: () {
                              model.showPlusMenu(context, widget.user.name!,
                                  widget.user.token!,widget.channelUrl);
                            },
                            onPressSend: (text) {
                              model.onSendUserMessage(text);
                            },
                            onEditing: (text) {
                              model.onUpdateMessage(text);
                            },
                            onChanged: (text) {
                              model.onTyping(text != '');
                            },
                            placeholder: model.selectedMessage?.message,
                            isEditing: editing,
                            peerName: widget.user.name!,
                            peerToken: widget.user.token!,
                            channelUrl: widget.channelUrl,
                          );
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // build helpers

  AppBar _buildNavigationBar() {
    final currentUser = model.currentUser;

    return AppBar(
      elevation: 1,
      automaticallyImplyLeading: false,
      toolbarHeight: 65,
      backgroundColor: primaryColor,
      leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          }),
      flexibleSpace: SafeArea(
        child: Container(
          child: Row(
            children: <Widget>[
              SizedBox(width: 40),
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 20,
                child: Padding(
                  padding: const EdgeInsets.all(0.5),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 19.5,
                    child: ClipRRect(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      borderRadius: BorderRadius.all(Radius.circular(500)),
                      child: CachedNetworkImage(
                        imageUrl: widget.user.profilePicUrl!,
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
              SizedBox(width: 12),
              Selector<ChatProvider, UserEngagementState>(
                selector: (_, model) => model.engagementState,
                builder: (context, value, child) {
                  return _buildTitle(value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(UserEngagementState ue) {
    List<Widget> headers = [
      ChannelTitleTextView(model.channel, model.currentUser!.userId)
    ];

    switch (ue) {
      case UserEngagementState.typing:
        headers.addAll([
          SizedBox(height: 3),
          Text(
            model.typersText,
            style: TextStyle(fontSize: 12, color: Colors.white),
          )
        ]);
        break;
      default:
        break;
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: headers,
      ),
    );
  }

  Widget _buildContent() {
    // return p.Consumer<ChannelViewModel>(builder: (context, value, child) {
    return Expanded(
      child: Container(
        color: Colors.white,
        child: ListView.builder(
          controller: model.lstController,
          itemCount: model.itemCount,
          shrinkWrap: true,
          reverse: true,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(top: 10, bottom: 10),
          itemBuilder: (context, index) {
            if (index == model.messages.length && model.hasNext) {
              return Center(
                child: Container(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final message = model.messages[index];
            final prev = (index < model.messages.length - 1)
                ? model.messages[index + 1]
                : null;
            final next = index == 0 ? null : model.messages[index - 1];

            if (message is FileMessage) {
              return FileMessageItem(
                user: widget.user,
                curr: message,
                prev: prev,
                next: next,
                model: model,
                isMyMessage: message.isMyMessage,
                onPress: (pos) {
                  //
                },
                onLongPress: (pos) {
                  model.showMessageMenu(
                    context: context,
                    message: message,
                    pos: pos,
                  );
                },
              );
            }
            // else if (message is AdminMessage) {
            //   return AdminMessageItem(curr: message, model: model);
            // }
            else if (message is UserMessage) {
              return UserMessageItem(
                user: widget.user,
                curr: message,
                prev: prev,
                next: next,
                model: model,
                isMyMessage: message.isMyMessage,
                onPress: (pos) {
                  //
                },
                onLongPress: (pos) {
                  model.showMessageMenu(
                    context: context,
                    message: message,
                    pos: pos,
                  );
                },
              );
            } else {
              //undefined message type
              return Container();
            }
          },
        ),
      ),
    );
    // });
    // );
  }
}
