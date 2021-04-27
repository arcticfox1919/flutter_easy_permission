# flutter_easy_permission

Permission plugin for Flutter.This is a wrapper for the **[easypermissions](https://github.com/googlesamples/easypermissions)** library.


- [x]  Android
- [x]  iOS



## Example

```dart
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
  static const permissions = [
    Permissions.CAMERA];

  static const permissionGroup = [
    PermissionGroup.Camera];

  FlutterEasyPermission _easyPermission;

  @override
  void initState() {
    super.initState();

    _easyPermission = FlutterEasyPermission()
      ..addPermissionCallback(
        onGranted: (requestCode,perms,perm){
          debugPrint("android获得授权:$perms");
          debugPrint("iOS获得授权:$perm");
        },
        onDenied: (requestCode,perms,perm,isPermanent){
          if(isPermanent){
            FlutterEasyPermission.showAppSettingsDialog(title: "Camera");
          }else{
            debugPrint("android授权失败:$perms");
            debugPrint("iOS授权失败:$perm");
          }
        },

        onSettingsReturned: (){
          FlutterEasyPermission.has(perms: permissions).then(
                  (value) => value
                  ?debugPrint("已获得授权:$permissions")
                  :debugPrint("未获得授权:$permissions")
          );
        });
  }

  @override
  void dispose() {
    _easyPermission.dispose();
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
                    FlutterEasyPermission.has(perms: permissions,permsGroup: permissionGroup).then(
                            (value) => value
                                ?debugPrint("已获得授权")
                                :debugPrint("未获得授权")
                    );
                  }),
              ElevatedButton(
                child: Text("请求权限"),
                  onPressed: (){
                FlutterEasyPermission.request(
                    perms: permissions,permsGroup: permissionGroup,rationale:"测试需要这些权限");
              })
            ],
          )
        ),
      ),
    );
  }
}
```



