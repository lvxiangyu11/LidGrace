#import "AppDelegate.h"
#import "StatusMenuController.h"
#import "SharedPaths.h"
#import "LockScreenService.h"

@interface AppDelegate ()
@property(nonatomic, strong) StatusMenuController *menuController;
@property(nonatomic, strong) NSTimer *lockRequestTimer;
@property(nonatomic) NSTimeInterval lastLockRequestTime;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];

    self.menuController = [[StatusMenuController alloc] init];
    [self.menuController start];

    self.lockRequestTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                             target:self
                                                           selector:@selector(checkLockRequest:)
                                                           userInfo:nil
                                                            repeats:YES];
}

- (void)checkLockRequest:(id)sender {
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:LGLockRequestPath() error:nil];
    NSDate *modified = attributes[NSFileModificationDate];
    if (!modified) return;

    NSTimeInterval timestamp = [modified timeIntervalSince1970];
    if (timestamp <= self.lastLockRequestTime) return;

    self.lastLockRequestTime = timestamp;
    [LockScreenService lockScreen];
}

@end
