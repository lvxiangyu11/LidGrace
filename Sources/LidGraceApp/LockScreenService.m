#import "LockScreenService.h"
#import "SharedPaths.h"

@implementation LockScreenService

+ (void)lockScreen {
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/System/Library/CoreServices/Menu Extras/User.menu/Contents/Resources/CGSession";
    task.arguments = @[@"-suspend"];
    [task launch];
}

+ (void)triggerGraceAndLock {
    [[NSFileManager defaultManager] createDirectoryAtPath:LGSharedRootPath()
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];

    NSString *timestamp = [NSString stringWithFormat:@"%lld\n", (long long)[[NSDate date] timeIntervalSince1970]];
    [timestamp writeToFile:LGManualTriggerPath()
                atomically:YES
                  encoding:NSUTF8StringEncoding
                     error:nil];

    [self lockScreen];
}

@end
