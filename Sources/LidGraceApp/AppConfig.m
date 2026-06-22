#import "AppConfig.h"
#import "SharedPaths.h"

@implementation AppConfig

+ (instancetype)defaults {
    AppConfig *config = [[AppConfig alloc] init];
    config.enabled = YES;
    config.graceSeconds = 300;
    config.triggerOnLid = YES;
    config.triggerOnDisplaySleep = YES;
    config.triggerOnScreenLock = YES;
    config.lockOnTrigger = YES;
    return config;
}

+ (instancetype)loadConfig {
    AppConfig *config = [AppConfig defaults];
    NSData *data = [NSData dataWithContentsOfFile:LGConfigPath()];
    if (!data) {
        return config;
    }

    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (![json isKindOfClass:[NSDictionary class]]) {
        return config;
    }

    id value = json[@"enabled"];
    if ([value respondsToSelector:@selector(boolValue)]) config.enabled = [value boolValue];

    value = json[@"grace_seconds"];
    if ([value respondsToSelector:@selector(integerValue)]) config.graceSeconds = [value integerValue];

    value = json[@"trigger_on_lid"];
    if ([value respondsToSelector:@selector(boolValue)]) config.triggerOnLid = [value boolValue];

    value = json[@"trigger_on_display_sleep"];
    if ([value respondsToSelector:@selector(boolValue)]) config.triggerOnDisplaySleep = [value boolValue];

    value = json[@"trigger_on_screen_lock"];
    if ([value respondsToSelector:@selector(boolValue)]) config.triggerOnScreenLock = [value boolValue];

    value = json[@"lock_on_trigger"];
    if ([value respondsToSelector:@selector(boolValue)]) config.lockOnTrigger = [value boolValue];

    return config;
}

- (BOOL)save:(NSError **)error {
    NSDictionary *json = @{
        @"enabled": @(self.enabled),
        @"grace_seconds": @(self.graceSeconds),
        @"trigger_on_lid": @(self.triggerOnLid),
        @"trigger_on_display_sleep": @(self.triggerOnDisplaySleep),
        @"trigger_on_screen_lock": @(self.triggerOnScreenLock),
        @"lock_on_trigger": @(self.lockOnTrigger)
    };

    NSData *data = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:error];
    if (!data) {
        return NO;
    }

    [[NSFileManager defaultManager] createDirectoryAtPath:LGSharedRootPath()
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];

    return [data writeToFile:LGConfigPath() options:NSDataWritingAtomic error:error];
}

@end
