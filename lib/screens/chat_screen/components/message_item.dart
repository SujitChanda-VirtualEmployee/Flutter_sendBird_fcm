import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sendbird_fcm/constants.dart';
import 'package:flutter_sendbird_fcm/models/firebase_user.dart';
import 'package:flutter_sendbird_fcm/provider/chat_provider.dart';
import 'package:flutter_sendbird_fcm/utility/avatar_view.dart';
import 'package:intl/intl.dart';

import 'package:sendbird_sdk/sendbird_sdk.dart';

enum MessagePosition {
  continuous,
  normal,
}

enum MessageState {
  read,
  delivered,
  none,
}

class MessageItem extends StatelessWidget {
  final BaseMessage curr;
  final BaseMessage? prev;
  final BaseMessage? next;
  final bool? isMyMessage;
  final ChatProvider model;
  final FirebaseUser user;

  final Function(Offset)? onLongPress;
  final Function(Offset)? onPress;

  Widget get content => throw UnimplementedError();

  String get _currTime => DateFormat('kk:mm a')
      .format(DateTime.fromMillisecondsSinceEpoch(curr.createdAt));

  MessageItem({
    required this.curr,
    this.prev,
    this.next,
    this.isMyMessage,
    required this.model,
    this.onPress,
    this.onLongPress,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final isCenter = isMyMessage == null;
    return Container(
      padding: EdgeInsets.only(
        left: 14,
        right: 14,
        top: _isContinuous(prev, curr) ? 2 : 16,
      ),
      child: Align(
        alignment: isCenter
            ? Alignment.center
            : isMyMessage!
                ? Alignment.topRight
                : Alignment.topLeft,
        child: isCenter
            ? _buildCenterWidget()
            : isMyMessage!
                ? _bulidRightWidget(context)
                : _buildLeftWidget(context, user.profilePicUrl!),
      ),
    );
  }

  Widget _buildCenterWidget() {
    return Column(
      children: [
        if (!_isSameDate(prev, curr)) _dateWidget(curr),
        content,
      ],
    );
  }

  Widget _horzontalSpace() {
    return const SizedBox(
      width: 10,
    );
  }

  Widget _VerticalSpace() {
    return const SizedBox(
      height: 5,
    );
  }

  Widget _bulidRightWidget(BuildContext ctx) {
    final wrap = Container(
      child: GestureDetector(
          onLongPressStart: (details) {
            if (onLongPress != null) onLongPress!(details.globalPosition);
          },
          onTapDown: (details) {
            if (onPress != null) onPress!(details.globalPosition);
          },
          child: content),
      constraints: BoxConstraints(maxWidth: 240),
    );

    // List<Widget> children = _timestampDefaultWidget(curr) + [wrap];
    List<Widget> children = [
      wrap,
      _VerticalSpace(),
      _additionalWidgetsForRight(curr)
    ];

    return Column(
      children: [
        if (!_isSameDate(prev, curr)) _dateWidget(curr),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: children,
        ),
      ],
    );
  }

  Widget _buildLeftWidget(BuildContext ctx, String peerImage) {
    final wrap = Container(
      child: GestureDetector(
          onLongPressStart: (details) {
            if (onLongPress != null) onLongPress!(details.globalPosition);
          },
          onTapDown: (details) {
            if (onPress != null) onPress!(details.globalPosition);
          },
          child: content),
      constraints: BoxConstraints(maxWidth: 240),
    );

    List<Widget> userDetails = [
      Row(
          children: _avatarDefaultWidget(curr, ctx, peerImage) +
              _nameDefaultWidget(curr))
    ];

    List<Widget> children = [
      Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: userDetails + [wrap] + _timestampDefaultWidget(curr))
    ];

    return Column(
      children: [
        if (!_isSameDate(prev, curr)) _dateWidget(curr),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        )
      ],
    );
  }

  bool _isContinuous(BaseMessage? p, BaseMessage? c) {
    if (p == null || c == null) {
      return false;
    }

    if (p.sender?.userId != c.sender?.userId) {
      return false;
    }

    final pt = DateTime.fromMillisecondsSinceEpoch(p.createdAt);
    final ct = DateTime.fromMillisecondsSinceEpoch(c.createdAt);

    final diff = pt.difference(ct);
    if (diff.inMinutes.abs() < 1 && pt.minute == ct.minute) {
      return true;
    }
    return false;
  }

  bool _isSameDate(BaseMessage? p, BaseMessage? c) {
    if (p == null || c == null) {
      return false;
    }

    final pt = DateTime.fromMillisecondsSinceEpoch(p.createdAt);
    final ct = DateTime.fromMillisecondsSinceEpoch(c.createdAt);

    return pt.year == ct.year && pt.month == ct.month && pt.day == ct.day;
  }

  Widget _dateWidget(BaseMessage message) {
    final date = DateTime.fromMillisecondsSinceEpoch(message.createdAt);
    final format = DateFormat('E, MMM d').format(date);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      child: Text(
        '$format',
      ),
    );
  }

  Widget _additionalWidgetsForRight(BaseMessage message) {
    //status pending -> loader
    if (message.sendingStatus == MessageSendingStatus.pending) {
      return Container(
        width: 12,
        height: 12,
        margin: EdgeInsets.only(right: 3, bottom: 3),
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    //status failed -> error icon
    if (message.sendingStatus == MessageSendingStatus.failed) {
      return Container(
          width: 16,
          height: 16,
          margin: EdgeInsets.only(right: 2),
          child: Icon(Icons.error, color: Colors.red));
    }

    return _stateAndTimeWidget(message);
  }

  Widget _stateAndTimeWidget(BaseMessage message) {
    final state = model.getMessageState(message);
    final image = state == MessageState.read
        ? Icon(Icons.check_circle, color: Colors.green, size: 15)
        : state == MessageState.delivered
            ? Icon(Icons.check_circle, color: Colors.grey, size: 15)
            : Icon(Icons.check_circle, color: Colors.green, size: 15);

    return Container(
        margin: EdgeInsets.only(right: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: _timestampDefaultWidget(message) +
              [_horzontalSpace()] +
              <Widget>[Container(width: 16, height: 16, child: image)],
        ));
  }

  List<Widget> _timestampDefaultWidget(BaseMessage message) {
    final myMessage = isMyMessage;
    if (myMessage == null) return [];

    return !_isContinuous(curr, next)
        ? [
            if (!myMessage) SizedBox(width: 3),
            Text(
              "\n    " + _currTime,
            ),
            if (myMessage) SizedBox(width: 3)
          ]
        : [];
  }

  List<Widget> _nameDefaultWidget(BaseMessage message) {
    return !_isContinuous(prev, curr)
        ? [
            Text(message.sender?.nickname ?? '',
                style: TextStyle(fontSize: 10)),
            SizedBox(height: 4),
          ]
        : [];
  }

  List<Widget> _avatarDefaultWidget(
      BaseMessage message, BuildContext ctx, String peerImage) {
    return !_isContinuous(prev, curr)
        ? [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 10,
              child: Padding(
                padding: const EdgeInsets.all(0.5),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 9.5,
                  child: ClipRRect(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    borderRadius: BorderRadius.all(Radius.circular(500)),
                    child: CachedNetworkImage(
                      imageUrl: peerImage,
                      width: MediaQuery.of(ctx).size.width,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => CircularProgressIndicator(
                        color: Colors.blue,
                        strokeWidth: 0.5,
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
          ]
        : [SizedBox(width: 38, height: 26)];
  }
}
