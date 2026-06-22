#import "SharedPaths.h"

NSString *LGSharedRootPath(void) {
    return @"/Library/Application Support/LidGrace";
}

NSString *LGConfigPath(void) {
    return [LGSharedRootPath() stringByAppendingPathComponent:@"config.json"];
}

NSString *LGStatusPath(void) {
    return [LGSharedRootPath() stringByAppendingPathComponent:@"status.json"];
}

NSString *LGManualTriggerPath(void) {
    return [LGSharedRootPath() stringByAppendingPathComponent:@"manual_trigger"];
}

NSString *LGLockRequestPath(void) {
    return [LGSharedRootPath() stringByAppendingPathComponent:@"lock_request"];
}
