import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_sendbird_fcm/main.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

class ChatListProvider with ChangeNotifier, ChannelEventHandler {
  GroupChannelListQuery query = GroupChannelListQuery()..limit = 10;
  
  List<GroupChannel> groupChannels = [];
  String? destChannelUrl;
  bool isLoading = false;
  final ScrollController lstController = ScrollController();
  int get itemCount =>
      query.hasNext ? groupChannels.length + 1 : groupChannels.length;
  bool get hasNext => query.hasNext;
  ChatListProvider({this.destChannelUrl}) {
    sendbird.addChannelEventHandler('channel_list_view', this);
    lstController.addListener(_scrollListener);
  }

  _scrollListener() {
    if (lstController.offset >= lstController.position.maxScrollExtent &&
        !lstController.position.outOfRange &&
        !isLoading &&
        query.hasNext) {
      loadChannelList();
    }
  }
    @override
  void dispose() {
    super.dispose();
    sendbird.removeChannelEventHandler('channel_list_view');
  }

  Future<void> loadChannelList({bool reload = false}) async {
    isLoading = true;
    log('loading channels...');

    try {
      if (reload)
        query = GroupChannelListQuery()
          ..limit = 10
          ..order = GroupChannelListOrder.latestLastMessage;
      final res = await query.loadNext();
      isLoading = false;
      if (reload)
        groupChannels = res;
      else {
        groupChannels = [...groupChannels] + res;
      }
      //go to channel if exist
      notifyListeners();
    } catch (e) {
      isLoading = false;
       notifyListeners();
      log('channel_list_view: getGroupChannel: ERROR: $e');
    }
  }
}
