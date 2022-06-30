import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sendbird_fcm/constants.dart';
import 'package:flutter_sendbird_fcm/models/firebase_user.dart';
import 'package:flutter_sendbird_fcm/provider/chat_provider.dart';
import 'package:flutter_sendbird_fcm/screens/chat_screen/components/message_item.dart';


import 'package:sendbird_sdk/sendbird_sdk.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class FileMessageItem extends MessageItem {
  FileMessageItem({
    required FileMessage curr,
    BaseMessage? prev,
    BaseMessage? next,
    required ChatProvider model,
    required FirebaseUser user,
    required bool isMyMessage,
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
          user: user
        );

  @override
  Widget get content => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ((curr as FileMessage).localFile != null && kIsWeb == false)
            ? Container(
                child: FittedBox(
                  child: Image.file((curr as FileMessage).localFile!),
                  fit: BoxFit.cover,
                ),
                height: 160,
                width: 240,
              )
            : CachedNetworkImage(
                height: 160,
                width: 240,
                fit: BoxFit.cover,
                imageUrl: (curr as FileMessage).secureUrl ??
                    (curr as FileMessage).url,
                placeholder: (context, url) => Container(
                 
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(secondaryColor),
                    ),
                  ),
                  width: 30,
                  height: 30,
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
      );
}
