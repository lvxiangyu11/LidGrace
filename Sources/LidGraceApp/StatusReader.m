#import "StatusReader.h"
#import "SharedPaths.h"

@implementation StatusReader

- (NSDictionary *)status {
    NSData *data = [NSData dataWithContentsOfFile:LGStatusPath()];
    if (!data) return @{};

    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (![json isKindOfClass:[NSDictionary class]]) return @{};

    return (NSDictionary *)json;
}

- (NSString *)menuTitle {
    NSDictionary *status = [self status];
    NSString *mode = status[@"mode"];
    NSNumber *remaining = status[@"remaining_seconds"];

    if (!mode) {
        return @"LidGrace";
    }

    if ([mode isEqualToString:@"active"] && [remaining respondsToSelector:@selector(integerValue)]) {
        NSInteger seconds = [remaining integerValue];
        return [NSString stringWithFormat:@"LidGrace · %ld:%02ld", (long)(seconds / 60), (long)(seconds % 60)];
    }

    if ([mode isEqualToString:@"disabled"]) {
        return @"LidGrace · Off";
    }

    return @"LidGrace";
}

@end
