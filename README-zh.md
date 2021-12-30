# flutter_easy_permission

中文文档 |  [English](README.md)

这是Flutter上的一个权限处理的插件库，它的Android实现包装自 **[easypermissions](https://github.com/googlesamples/easypermissions)** 。


- [x]  Android
- [x]  iOS

## 用法

1. 配置权限
2. 检查权限。当调用一些需要权限的API时，应先检查是否具有相关权限
3. 请求权限。如果未获得授权，则向用户请求这些权限
4. 处理回调

### 配置权限

#### Android

在项目根目录中打开`android/app/src/main/AndroidManifest.xml`文件，然后配置所需的权限：

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="xyz.bczl.flutter.easy_permission_example">
    <!--  在此处配置权限 -->
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.CAMERA"/>
   <application
        android:label="flutter_easy_permission_example"
        android:icon="@mipmap/ic_launcher">
        <!--  .............  -->
   </application>
</manifest>
```

有关这些常量的详细说明，请转到[这里](https://developer.android.google.cn/reference/android/Manifest.permission#summary)。

要了解Android上的权限是如何处理的，[这里](https://developer.android.google.cn/guide/topics/permissions/overview)有一份完整文档。

#### iOS

打开项目根目录下的`ios/Runner/Info.plist`文件，配置你需要的权限：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!--  在此处配置权限  -->
    <key>NSCameraUsageDescription</key>
	<string>在此向用户解释你为什么需要这个权限</string>

    <!--  .............  -->
</dict>
</plist>
```

注意，替换`<string></string>`标签中的内容，给用户一个需要权限的理由。

关于iOS权限的详细解释，你可以查看[这里](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW17)。

集成iOS中未使用的权限库，可能无法通过应用商店审核，所以不要集成那些不用的权限库，因此你还需要做一些配置。

打开`ios/Podfile`文件，添加以下代码。

```ruby
target 'Runner' do
  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  # Add the library of permissions you need here
  pod 'EasyPermissionX/Camera'
end
```
你可以集成的库（请按需集成，如果集成不需要的库，可能导致苹果应用商店上架审核失败）：
```ruby
pod 'EasyPermissionX/Camera'
pod 'EasyPermissionX/Photo'
pod 'EasyPermissionX/Contact'
pod 'EasyPermissionX/Location'
pod 'EasyPermissionX/Reminder'
pod 'EasyPermissionX/Calendar'
pod 'EasyPermissionX/Microphone'
pod 'EasyPermissionX/Health'
pod 'EasyPermissionX/Net'
pod 'EasyPermissionX/Tracking'
pod 'EasyPermissionX/Media'
pod 'EasyPermissionX/Notification'
pod 'EasyPermissionX/Bluetooth'
```

配置好后，你需要在项目的ios目录下运行安装命令：

```shell
pod install
```

### 检查权限

```dart
const permissions = [Permissions.CAMERA];
const permissionGroup = [PermissionGroup.Camera];

bool ret = await FlutterEasyPermission.has(perms: permissions,permsGroup: permissionGroup);
```

由于Android和iOS的权限有很大不同，很难统一处理，所以你必须分别处理。参数`perms`对应的是Android权限，参数`permsGroup`对应的是iOS权限。app同一时间只能在一个平台上运行，所以你不需要担心会出现混乱。

注意API和库之间的关系，要检查和请求相关的权限，你必须集成相应的库，见下表：

| PermissionGroup | Info.plist                                                   | Integrated lib               |
| --------------- | ------------------------------------------------------------ | ---------------------------- |
| Calendar        | `NSCalendarsUsageDescription`                                | EasyPermissionX/Calendar     |
| Reminders       | `NSRemindersUsageDescription`                                | EasyPermissionX/Reminder     |
| Contacts        | `NSContactsUsageDescription`                                 | EasyPermissionX/Contact      |
| Camera          | `NSCameraUsageDescription`                                   | EasyPermissionX/Camera       |
| Microphone      | `NSMicrophoneUsageDescription`                               | EasyPermissionX/Microphone   |
| Photos          | `NSPhotoLibraryUsageDescription`                             | EasyPermissionX/Photo        |
| Location        | `NSLocationUsageDescription`<br /> `NSLocationAlwaysAndWhenInUseUsageDescription`<br /> `NSLocationWhenInUseUsageDescription` | EasyPermissionX/Location     |
| Notification    | `PermissionGroupNotification`                                | EasyPermissionX/Notification |
| Bluetooth       | `NSBluetoothAlwaysUsageDescription`<br /> `NSBluetoothPeripheralUsageDescription` | EasyPermissionX/Bluetooth    |

### 请求权限
```dart
FlutterEasyPermission.request(
                    perms: permissions,permsGroup: permissionGroup,rationale:"Test permission requests here");
```

### 处理回调

```dart
void initState() {
    super.initState();
    _easyPermission = FlutterEasyPermission()
      ..addPermissionCallback(
        onGranted: (requestCode,perms,perm){
          debugPrint("Android Authorized:$perms");
          debugPrint("iOS Authorized:$perm");
        },
        onDenied: (requestCode,perms,perm,isPermanent){
          if(isPermanent){
            FlutterEasyPermission.showAppSettingsDialog(title: "Camera");
          }else{
            debugPrint("Android Deny authorization:$perms");
            debugPrint("iOS Deny authorization:$perm");
          }
        },);
  }

void dispose() {
    _easyPermission.dispose();
    super.dispose();
}
```

当`isPermanent`返回true时，表明系统在请求权限时不会弹出授权对话框，所以你可能需要自己弹出一个对话框，内容主要是提示用户，如果你必须使用这个功能，你可以到系统设置页面重新打开权限。

在Android上，你可能还需要实现`onSettingsReturned`回调函数，以更好地处理权限交互。它是`showAppSettingsDialog`被调用后的回调。

## 例子

**一个完整的例子, 查看 [这里](https://github.com/arcticfox1919/flutter_easy_permission/blob/main/example/lib/main.dart)。**