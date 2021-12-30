# flutter_easy_permission

[中文文档](README-zh.md)  |  English



Permission plugin for Flutter.This is a wrapper for the **[easypermissions](https://github.com/googlesamples/easypermissions)** library.


- [x]  Android
- [x]  iOS

## Usage

1. Configure permissions
2. Permissions should be checked first when calling certain APIs
3. No permission, then request from the user
4. Handling callbacks

### Configure permissions

#### Android

Open the `android/app/src/main/AndroidManifest.xml` file in the project root directory and configure the permissions you need:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="xyz.bczl.flutter.easy_permission_example">
    <!--  Configure permissions here -->
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

For a detailed description of these constants, go [here](https://developer.android.com/reference/android/Manifest.permission#summary).

To understand how permissions are handled on Android, [here's](https://developer.android.com/guide/topics/permissions/overview) a comprehensive document.

#### iOS

Open the `ios/Runner/Info.plist` file in the project root directory and configure the permissions you need:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!--  Configure permissions here  -->
    <key>NSCameraUsageDescription</key>
	<string>Explain to the user here why you need the permission</string>

    <!--  .............  -->
</dict>
</plist>
```

Note that replacing the content of the `<string></string>` tag gives the user a reason for needing the permission.

For a detailed explanation of iOS permissions, you can go [here](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW17).

Integrating permissions that are not required in iOS may not pass the app shop, so do not integrate those that are not used, you will also need to do some configuration.

Open the `ios/Podfile` file and add the following code:

```ruby
target 'Runner' do
  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  # Add the library of permissions you need here
  pod 'EasyPermissionX/Camera'
end
```
You can integrate the following libraries:
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

Once configured, you need to run the command install in the project's ios directory:

```shell
pod install
```

### Check Permissions

```dart
const permissions = [Permissions.CAMERA];
const permissionGroup = [PermissionGroup.Camera];

bool ret = await FlutterEasyPermission.has(perms: permissions,permsGroup: permissionGroup);
```

Since Android and iOS permissions are very different, it is difficult to handle them uniformly, so you have to handle them separately. The parameter `perms` corresponds to Android permissions and the parameter `permsGroup` to iOS permissions. The app can only run on one platform at a time, so you don't need to worry about messing up.

Note the relationship between the API and the library, to check and request the relevant permissions you must integrate the corresponding library, see the following table:

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

### Request permission
```dart
FlutterEasyPermission.request(
                    perms: permissions,permsGroup: permissionGroup,rationale:"Test permission requests here");
```

### Handling callbacks

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

When `isPermanent` returns true, it indicates that the system will not pop up an authorization dialog when requesting permissions, so you may need to pop up a dialog yourself with content that mainly prompts the user, and if you must use this feature, you can go to the system settings page to reopen the permissions.

On Android, you may also need to implement the `onSettingsReturned` callback function to better handle permission interactions.It is the callback after `showAppSettingsDialog` is called

## Example

**For a complete example, please see [here](https://github.com/arcticfox1919/flutter_easy_permission/blob/main/example/lib/main.dart).**