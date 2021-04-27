
const DefaultRequestCode = 101;

///
/// AppSettingsDialog的默认文本内容
///
const SettingsDialogTitle = "需要的权限";
const SettingsDialogRationale = "如果没有所请求的权限，此应用可能无法正常工作，请打开应用设置界面，修改应用权限。";
const SettingsDialogPositiveButton = "确定";
const SettingsDialogNegativeButton = "取消";

enum Permissions {
  WRITE_CONTACTS,
  GET_ACCOUNTS,
  READ_CONTACTS,
  READ_CALL_LOG,
  READ_PHONE_STATE,
  CALL_PHONE,
  WRITE_CALL_LOG,
  USE_SIP,
  PROCESS_OUTGOING_CALLS,
  ADD_VOICEMAIL,
  READ_CALENDAR,
  WRITE_CALENDAR,
  CAMERA,
  BODY_SENSORS,
  ACCESS_FINE_LOCATION,
  ACCESS_COARSE_LOCATION,
  READ_EXTERNAL_STORAGE,
  WRITE_EXTERNAL_STORAGE,
  RECORD_AUDIO,
  READ_SMS,
  RECEIVE_WAP_PUSH,
  RECEIVE_MMS,
  RECEIVE_SMS,
  SEND_SMS,
}

// *****************************************************************************
// ************************************ iOS ************************************
// *****************************************************************************
enum PermissionGroup {
  Location,
  Camera,
  Photos,
  Contacts,
  Reminders,
  Calendar,
  Microphone,
  Health,
  DataNetwork,
  MediaLibrary,
  Tracking,
  Notification,
  Bluetooth
}


