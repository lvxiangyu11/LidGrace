#import <Foundation/Foundation.h>

@interface LockScreenService : NSObject

+ (void)lockScreen;
+ (void)triggerGraceAndLock;

@end
