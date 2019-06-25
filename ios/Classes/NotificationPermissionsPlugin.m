#import "NotificationPermissionsPlugin.h"
#import "UserNotifications/UserNotifications.h"

@implementation NotificationPermissionsPlugin {
    FlutterMethodChannel *_channel;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel *channel =
    [FlutterMethodChannel methodChannelWithName:@"notification_permissions"
                                binaryMessenger:[registrar messenger]];
    NotificationPermissionsPlugin *instance =
    [[NotificationPermissionsPlugin alloc] initWithChannel:channel];
    [registrar addApplicationDelegate:instance];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel {
    self = [super init];
    
    if (self) {
        _channel = channel;
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *method = call.method;
    if ([@"requestNotificationPermissions" isEqualToString:method]) {
        UIUserNotificationType notificationTypes = 0;
        NSDictionary *arguments = call.arguments;
        if ([arguments[@"sound"] boolValue]) {
            notificationTypes |= UIUserNotificationTypeSound;
        }
        if ([arguments[@"alert"] boolValue]) {
            notificationTypes |= UIUserNotificationTypeAlert;
        }
        if ([arguments[@"badge"] boolValue]) {
            notificationTypes |= UIUserNotificationTypeBadge;
        }
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        
        result(nil);
    } else if ([@"getNotificationPermissionStatus" isEqualToString:method]) {
        if (@available(iOS 10.0, *)) {
            [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                if(settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
                    //notifications are enabled for this app
                    if(settings.notificationCenterSetting == UNNotificationSettingEnabled ||
                       settings.lockScreenSetting == UNNotificationSettingEnabled ||
                       (settings.alertSetting == UNNotificationSettingEnabled && settings.alertStyle != UNAlertStyleNone)) {
                        //the user will be able to see the notifications (on the lock screen, in history and/or via banners)
                        result(@"granted");
                    }
                    else {
                        //the user must change notification settings in order te receive notifications
                        result(@"denied");
                    }
                } else if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined) {
                    result(@"unknown");
                } else {
                    result(@"denied");
                }
            }];
        } else {
            // Fallback on earlier versions
        }
    }  else {
        result(FlutterMethodNotImplemented);
    }
}

@end

