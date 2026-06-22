#import <Foundation/Foundation.h>

@interface AppConfig : NSObject

@property(nonatomic) BOOL enabled;
@property(nonatomic) NSInteger graceSeconds;
@property(nonatomic) BOOL triggerOnLid;
@property(nonatomic) BOOL triggerOnDisplaySleep;
@property(nonatomic) BOOL triggerOnScreenLock;
@property(nonatomic) BOOL lockOnTrigger;

+ (instancetype)loadConfig;
- (BOOL)save:(NSError **)error;

@end
