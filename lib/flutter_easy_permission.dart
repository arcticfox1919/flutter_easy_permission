import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'constants.dart';

///
/// [requestCode] 参见 [FlutterEasyPermission.request]
/// [perms] 参见 [FlutterEasyPermission.request]
/// [permsGroup] 参见 [FlutterEasyPermission.request]
///
typedef Granted = void Function(int requestCode,List<Permissions> ?perms,PermissionGroup ?perm);

///
/// [isPermanent] 是否有一个权限被永久拒绝
///
typedef Denied = void Function(int requestCode,List<Permissions> ?perms,
    PermissionGroup ?perm,bool isPermanent);


class FlutterEasyPermission {
  static const MethodChannel _channel =
      const MethodChannel('xyz.bczl.flutter_easy_permission/permissions');

  static const MethodChannel _callbackChannel =
      const MethodChannel('xyz.bczl.flutter_easy_permission/callback');

  static Set<FlutterEasyPermission> _callbacks = Set<FlutterEasyPermission>();

  Granted ?_granted;
  Denied ?_denied;
  VoidCallback ?_onSettingsReturned;

  ///
  /// 检查权限
  ///
  /// [perms] 一组要检查的Android权限。参见 [Permissions]
  /// [permsGroup] 一组要检查的iOS权限。参见 [PermissionGroup]
  /// 已获得授权时返回：true，否则返回：false
  ///
  static Future<bool> has({required List<Permissions> perms,required List<PermissionGroup> permsGroup}) async {
    assert(perms!= null || permsGroup != null);
    try {
      var list = _getPermissionsIndex(Platform.isAndroid ? perms:permsGroup);
      return await _channel.invokeMethod('hasPermissions', {"perms": list});
    }catch(e,s){
      debugPrint('$e\n$s');
    }
    return false;
  }

  ///
  /// 请求权限
  ///
  /// [perms] 参见 [has]
  /// [permsGroup] 参见 [has]
  /// [rationale] 仅Android有效。解释为什么应用程序需要这组权限；如果用户第一次拒绝请求，将显示该信息。
  /// [requestCode] 追踪此请求的请求码，必须是小于256的整数，将在[Granted]、[Denied]回调中返回
  ///
  static void request({required List<Permissions> perms,required List<PermissionGroup> permsGroup,
    String ?rationale,int requestCode=DefaultRequestCode}) async {
    assert(perms!=null || permsGroup != null);

    try{
      var list = _getPermissionsIndex(Platform.isAndroid ? perms:permsGroup);
      await _channel.invokeMethod('requestPermissions',
          {"perms":list,"rationale":rationale,"requestCode":requestCode});
    }catch(e,s){
      debugPrint('$e\n$s');
    }
  }

  ///
  /// 设置用户授权结果的回调
  ///
  /// [onGranted] 成功授权时回调。 参见 [Granted]
  /// [onDenied]  拒绝授权时回调。参见 [Denied]
  /// [onSettingsReturned] 仅Android有效。Android平台调用[showAppSettingsDialog]后的回调
  ///
  void addPermissionCallback({
    Granted ?onGranted,
    Denied ?onDenied,
    VoidCallback ?onSettingsReturned,
  }){
    this._granted = onGranted;
    this._denied = onDenied;
    this._onSettingsReturned = onSettingsReturned;
    _callbacks.add(this);
    if(_callbackChannel.checkMethodCallHandler(null)){
      _callbackChannel.setMethodCallHandler(_handler);
    }
  }

  static Future<dynamic> _handler(MethodCall call){
    PermissionGroup ?pg ;
    List<Permissions> perms = []..length=0;
    try {
      switch (call.method) {
        case "onGranted":
          int ?perm = call.arguments["perm"];
          int requestCode = call.arguments["requestCode"] ?? -1;

          if(perm !=null){
            pg = _getPermission(perm);
          }else{
            List<int> permList = call.arguments["perms"].cast<int>();
            perms = _getPermissions(permList);
          }
          _callbacks.forEach((e) {
            e._granted?.call(requestCode, perms, pg);
          });
          break;
        case "onDenied":
          int ?perm = call.arguments["perm"];
          int requestCode = call.arguments["requestCode"];
          bool isPermanentlyDenied;
          if(perm !=null){
            pg = _getPermission(perm);
            bool firstTime = call.arguments["firstTime"];
            isPermanentlyDenied = !firstTime;
          }else{
            List<int> permList = call.arguments["perms"].cast<int>();
            isPermanentlyDenied = call.arguments["permanently"];
            perms = _getPermissions(permList);
          }
          _callbacks.forEach((e) {
            e._denied?.call(requestCode, perms,pg ,isPermanentlyDenied);
          });
          break;
        case "onSettingsReturned":
          _callbacks.forEach((e) {
            e._onSettingsReturned?.call();
          });
          break;
      }
    }catch(e,s){
      debugPrint('$e\n$s');
    }
    return Future.value();
  }

  static List<int> _getPermissionsIndex(List<dynamic> perms){
    if(perms !=null && perms.isNotEmpty){
      if(perms is List<PermissionGroup>){
        return perms.map((e) => e.index).toList();
      }else if(perms is List<Permissions>){
        return perms.map((e) => e.index).toList();
      }
    }
    throw Exception("_getPermissionsIndex: parameter 'perms' cannot be null or empty");
  }

  static List<Permissions> _getPermissions(List<int> perms){
    if(perms !=null && perms.isNotEmpty){
      return perms.map((e) => Permissions.values[e]).toList();
    }
    throw Exception("_getPermissions: parameter 'perms' cannot be null or empty");
  }

  static PermissionGroup _getPermission(int perm){
    return PermissionGroup.values[perm];
  }

  ///
  /// 提示用户进入应用的设置界面并启用权限的对话框。
  /// 如果用户在对话框中点击 "确定"，就会被发送到设置界面。
  /// 在Android平台，需要接收设置页面返回的通知，在[addPermissionCallback]中实现[_onSettingsReturned]
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
      debugPrint(e.toString());
    }
  }

  void dispose(){
    _callbacks.remove(this);
  }
}
