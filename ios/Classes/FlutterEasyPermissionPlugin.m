#import "FlutterEasyPermissionPlugin.h"
#import <Foundation/Foundation.h>
#import "EasyPermission.h"

@implementation FlutterEasyPermissionPlugin
{
    NSObject<FlutterPluginRegistrar> *_registrar;
    FlutterMethodChannel* _callbackChannel;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"xyz.bczl.flutter_easy_permission/permissions"
            binaryMessenger:[registrar messenger]];
    FlutterEasyPermissionPlugin* instance = [[FlutterEasyPermissionPlugin alloc] initWithRegistrar:registrar];
  [registrar addMethodCallDelegate:instance channel:channel];
}

-(instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar{
    self = [super init];
    if(self){
        _registrar = registrar;
        _callbackChannel = [FlutterMethodChannel methodChannelWithName:@"xyz.bczl.flutter_easy_permission/callback"
                                                       binaryMessenger:[registrar messenger]];
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *args = call.arguments;
    NSArray *perms = args[@"perms"];
    if ([@"hasPermissions" isEqualToString:call.method]) {
        for (NSNumber *perm in perms) {
            BOOL ret = [EasyPermission authorizedWithType:perm.intValue];
            if (!ret) {
                result([NSNumber numberWithBool:NO]);
                return;
            }
        }
        result([NSNumber numberWithBool:YES]);
    }else if([@"requestPermissions" isEqualToString:call.method]){
        NSNumber *requestCode = args[@"requestCode"];
        
        for (NSNumber *perm in perms) {
            [EasyPermission authorizeWithType:perm.intValue completion:^(BOOL granted, BOOL firstTime) {
                NSDictionary *param = @{
                    @"perm":perm,
                    @"requestCode":requestCode,
                    @"firstTime":[NSNumber numberWithBool:firstTime]
                };
                
                NSString *method = granted ? @"onGranted":@"onDenied";
                [self->_callbackChannel invokeMethod:method arguments:param];
            }];
        }
        result(nil);
    }else if([@"showSettingsDialog" isEqualToString:call.method]){
        NSString *title = args[@"title"];
        NSString *rationale = args[@"rationale"];
        NSString *positiveBtnText = args[@"positiveButtonText"];
        NSString *negativeBtnText = args[@"negativeButtonText"];
        [EasyPermissionSetting showAlertToDislayPrivacySettingWithTitle:title msg:rationale cancel:negativeBtnText setting:positiveBtnText];
        result(nil);
    }else {
        result(FlutterMethodNotImplemented);
    }
}

@end
