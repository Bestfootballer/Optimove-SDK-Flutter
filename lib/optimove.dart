import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

class Optimove {
  static const MethodChannel _methodChannel = MethodChannel('optimove_flutter_sdk');
  static const EventChannel _eventChannel = EventChannel('optimove_flutter_sdk_events');
  static StreamSubscription? _eventStream;

  static void Function(OptimovePushNotification)? _pushOpenedHandler;
  static void Function(OptimovePushNotification)? _pushReceivedHandler;
  static void Function(OptimoveDeepLinkOutcome)? _deepLinkHandler;

  static void setEventHandlers({void Function(OptimovePushNotification)? pushReceivedHandler,
    void Function(OptimovePushNotification)? pushOpenedHandler, void Function(OptimoveDeepLinkOutcome)? deepLinkHandler}){
    _pushOpenedHandler = pushOpenedHandler;
    _pushReceivedHandler = pushReceivedHandler;
    _deepLinkHandler = deepLinkHandler;
    if (pushOpenedHandler == null && pushReceivedHandler == null) {
      _eventStream?.cancel();
      _eventStream = null;
      return;
    }

    if (_eventStream != null) {
      return;
    }

    _eventStream = _eventChannel.receiveBroadcastStream().listen((event) {
      String type = event['type'];
      Map<String, dynamic> data = Map<String, dynamic>.from(event['data']);

      switch (type) {
        case 'push.opened':
          _pushOpenedHandler?.call(OptimovePushNotification.fromMap(data));
          return;
        case 'push.received':
          _pushReceivedHandler?.call(OptimovePushNotification.fromMap(data));
          return;
        case 'deep-linking.linkResolved':
          _deepLinkHandler?.call(OptimoveDeepLinkOutcome.fromMap(data));
          return;
      }
    });
  }

  static Future<void> registerUser({required String userId, required String email}) async {
    return _methodChannel.invokeMethod('registerUser', {'userId': userId, 'email': email});
  }

  static Future<void> setUserId({required String userId}) async {
    return _methodChannel.invokeMethod('setUserId', {'userId': userId});
  }

  static Future<void> setUserEmail({required String email}) async {
    return _methodChannel.invokeMethod('setUserEmail', {'email': email});
  }

  static Future<String> getVisitorId() async {
    String visitorId = await _methodChannel.invokeMethod('getVisitorId');
    return visitorId;
  }

  static Future<void> reportEvent({required String event, Map<String, dynamic>? parameters}) async {
    return _methodChannel.invokeMethod('reportEvent', {'event': event, 'parameters': parameters});
  }

  static Future<void> reportScreenVisit({required String screenName, String? screenCategory}) async {
    return _methodChannel.invokeMethod('reportScreenVisit', {'screenName': screenName, 'screenCategory': screenCategory});
  }

  static Future<String?> getCurrentUserIdentifier() async {
    String? userIdentifier = await _methodChannel.invokeMethod('getCurrentUserIdentifier');
    return userIdentifier;
  }

  static void pushRequestDeviceToken() {
    if (Platform.isIOS){
      _methodChannel.invokeMethod('pushRequestDeviceToken');
    }
  }

  static void enableStagingRemoteLogs() {
    if (Platform.isAndroid) {
      _methodChannel.invokeMethod('enableStagingRemoteLogs');
    }
  }

  static Future<bool> markAllInboxItemsAsRead() async {
    var result = await _methodChannel.invokeMethod<bool>('inAppMarkAllInboxItemsAsRead');

    return result ?? false;
  }

  static Future<OptimoveInAppInboxSummary?> getInboxSummary() async {
    Map<String, dynamic> result = Map<String, dynamic>.from(await _methodChannel.invokeMethod('inAppGetInboxSummary'));

    return OptimoveInAppInboxSummary(
        result['totalCount'], result['unreadCount']);
  }

}

class OptimoveInAppInboxSummary {
  final int totalCount;
  final int unreadCount;

  OptimoveInAppInboxSummary(this.totalCount, this.unreadCount);
}


class OptimovePushNotification {
  final String? title;
  final String? message;
  final Map<String, dynamic>? data;
  final String? url;
  final String? actionId;

  OptimovePushNotification(
      this.title, this.message, this.data, this.url, this.actionId);

  OptimovePushNotification.fromMap(Map<String, dynamic> map)
      : title = map['title'],
        message = map['message'],
        data =
        map['data'] != null ? Map<String, dynamic>.from(map['data']) : null,
        url = map['url'],
        actionId = map['actionId'];
}


enum OptimoveDeepLinkResolution {
  LookupFailed,
  LinkNotFound,
  LinkExpired,
  LimitExceeded,
  LinkMatched
}

class OptimoveDeepLinkContent {
  final String? title;
  final String? description;

  OptimoveDeepLinkContent(this.title, this.description);
}

class OptimoveDeepLinkOutcome {
  final OptimoveDeepLinkResolution resolution;
  final String url;
  final OptimoveDeepLinkContent? content;
  final Map<String, dynamic>? linkData;

  OptimoveDeepLinkOutcome(
      this.resolution, this.url, this.content, this.linkData);

  OptimoveDeepLinkOutcome.fromMap(Map<String, dynamic> map)
      : resolution = OptimoveDeepLinkResolution.values[map['resolution']],
        url = map['url'],
        content = map['link']['content'] != null
            ? OptimoveDeepLinkContent(map['link']['content']['title'],
            map['link']['content']['description'])
            : null,
        linkData = map['link']['data'] != null
            ? Map<String, dynamic>.from(map['link']['data'])
            : null;
}

