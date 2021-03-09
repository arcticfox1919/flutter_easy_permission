import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'constants.dart';

typedef OnGranted = void Function(int requestCode,List<Permissions> perms);
///
/// [isPermanentlyDenied] 是否有一个权限被永久拒绝
///
typedef OnDenied = void Function(int requestCode,List<Permissions> perms,bool isPermanentlyDenied);
typedef OnSettingsReturned = void Function();

class FlutterEasyPermission {
  static const MethodChannel _channel =
      const MethodChannel('xyz.bczl.flutter_easy_permission/permissions');
  static const _callback_channel_name = 'xyz.bczl.flutter_easy_permission/callback';

  MethodChannel _callbackChannel ;

  ///
  /// 检查权限
  ///
  /// [perms] 一组要检查的权限
  /// 已获得授权时返回：true，否则返回：false
  ///
  static Future<bool> has(List<Permissions> perms) async {
    try {
      var list = _getPermissionsIndex(perms);
      return await _channel.invokeMethod('hasPermissions', {"perms": list});
    }catch(e){
      debugPrint(e.message);
    }
    return false;
  }

  ///
  /// 请求权限
  ///
  /// [perms] 一组要请求的权限
  /// [rationale] 解释为什么应用程序需要这组权限；如果用户第一次拒绝请求，将显示该信息。
  /// [requestCode] 追踪此请求的请求码，必须是小于256的整数，将在[OnGranted]、[OnDenied]中返回
  ///
  static void request(List<Permissions> perms,{String rationale,int requestCode=DefaultRequestCode}) async {
    try{
      var list = _getPermissionsIndex(perms);
      await _channel.invokeMethod('requestPermissions',
          {"perms":list,"rationale":rationale,"requestCode":requestCode});
    }catch(e){
      debugPrint(e.message);
    }
  }

  FlutterEasyPermission(){
    _callbackChannel = MethodChannel(_callback_channel_name);
  }

  ///
  /// 设置用户授权结果的回调
  ///
  /// [onGranted] 成功授权时回调
  /// [onDenied]  拒绝授权时回调
  /// [onSettingsReturned] 调用[showAppSettingsDialog]后的回调
  ///
  void addPermissionCallback({
    @required OnGranted onGranted,
    @required OnDenied onDenied,
    OnSettingsReturned onSettingsReturned
  }){
    _callbackChannel.setMethodCallHandler((call){
      try {
        switch (call.method) {
          case "onGranted":
            int requestCode = call.arguments["requestCode"];
            List<int> perms = call.arguments["perms"].cast<int>();
            onGranted.call(requestCode, _getPermissions(perms));
            break;
          case "onDenied":
            int requestCode = call.arguments["requestCode"];
            List<int> perms = call.arguments["perms"].cast<int>();
            bool isPermanentlyDenied = call.arguments["permanently"];
            onDenied.call(requestCode, _getPermissions(perms), isPermanentlyDenied);
            break;
          case "onSettingsReturned":
            onSettingsReturned.call();
            break;
        }
      }catch(e){
        debugPrint(e.message);
      }
      return null;
    });
  }

  static List<int> _getPermissionsIndex(List<Permissions> perms){
    if(perms !=null && perms.isNotEmpty){
      return perms.map((e) => e.index).toList();
    }
    throw Exception("_getPermissionsIndex: parameter 'perms' cannot be null or empty");
  }

  static List<Permissions> _getPermissions(List<int> perms){
    if(perms !=null && perms.isNotEmpty){
      return perms.map((e) => Permissions.values[e]).toList();
    }
    throw Exception("_getPermissions: parameter 'perms' cannot be null or empty");
  }

  ///
  /// 提示用户进入应用的设置界面并启用权限的对话框。
  /// 如果用户在对话框中点击 "确定"，就会被发送到设置界面。
  /// 接收设置页面返回的通知，在[addPermissionCallback]中实现[onSettingsReturned]
  ///
  static void showAppSettingsDialog({
    title=SettingsDialogTitle,
    rationale=SettingsDialogRationale,
    positiveButtonText=SettingsDialogPositiveButton,
    negativeButtonText=SettingsDialogNegativeButton}) async{
    try{
      await _channel.invokeMethod('showSettingsDialog',
          {"title":title,"rationale":rationale,
            "positiveButtonText":positiveButtonText,
            "negativeButtonText":negativeButtonText
          });
    }catch(e){
      debugPrint(e.message);
    }
  }

  void dispose(){
    _callbackChannel?.setMethodCallHandler(null);
  }
}
