
import 'package:flutter/material.dart';

import 'package:flutter_easy_permission/easy_permissions.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const needPermissions = [
    Permissions.WRITE_EXTERNAL_STORAGE,
    Permissions.READ_EXTERNAL_STORAGE];

  @override
  void initState() {
    super.initState();

    FlutterEasyPermission.addPermissionCallback(
        onGranted: (requestCode,perms){
          debugPrint("获得授权:$perms");
        },
        onDenied: (requestCode,perms,isPermanentlyDenied){
          if(isPermanentlyDenied){
            FlutterEasyPermission.showAppSettingsDialog();
          }else{
            debugPrint("授权失败:$perms");
          }
        },
        onSettingsReturned: (){
          FlutterEasyPermission.has(needPermissions).then(
                  (value) => value
                  ?debugPrint("已获得授权:$needPermissions")
                  :debugPrint("未获得授权:$needPermissions")
          );
        });
  }

  @override
  void dispose() {
    FlutterEasyPermission.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                  child: Text("检查权限"),
                  onPressed: (){
                    FlutterEasyPermission.has(needPermissions).then(
                            (value) => value
                                ?debugPrint("已获得授权:$needPermissions")
                                :debugPrint("未获得授权:$needPermissions")
                    );
                  }),
              ElevatedButton(
                child: Text("请求权限"),
                  onPressed: (){
                FlutterEasyPermission.request(needPermissions,rationale:"测试需要这些权限");
              })
            ],
          )
        ),
      ),
    );
  }
}
