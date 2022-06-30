import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_1.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_4.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_5.dart';
import 'package:flutter_sendbird_fcm/models/firebase_user.dart';
import 'package:flutter_sendbird_fcm/provider/chat_provider.dart';
import 'package:flutter_sendbird_fcm/screens/chat_screen/components/message_item.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

class UserMessageItem extends MessageItem {
  UserMessageItem({
    required UserMessage curr,
    BaseMessage? prev,
    BaseMessage? next,
    required ChatProvider model,
    required FirebaseUser user,
    bool? isMyMessage,
    Function(Offset)? onPress,
    Function(Offset)? onLongPress,
  }) : super(
          curr: curr,
          prev: prev,
          next: next,
          model: model,
          isMyMessage: isMyMessage,
          onPress: onPress,
          onLongPress: onLongPress,
          user: user,
        );

  @override
  Widget get content => ChatBubble(
        clipper: ChatBubbleClipper5(
            secondRadius: 0,
            radius: 20,
            type: (isMyMessage ?? false)
                ? BubbleType.sendBubble
                : BubbleType.receiverBubble),
        alignment:
            (isMyMessage ?? false) ? Alignment.topRight : Alignment.topLeft,
        margin: EdgeInsets.only(top: 10),
        backGroundColor: (isMyMessage ?? false) ? Colors.blueGrey : Colors.blue,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Text(
            curr.message,
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
        ),
      );
}
