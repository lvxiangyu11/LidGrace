#import "StatusMenuController.h"
#import "AppConfig.h"
#import "StatusReader.h"
#import "LockScreenService.h"
#import "SettingsWindowController.h"

@interface StatusMenuController ()

@property(nonatomic, strong) NSStatusItem *statusItem;
@property(nonatomic, strong) NSTimer *timer;
@property(nonatomic, strong) StatusReader *reader;
@property(nonatomic, strong) SettingsWindowController *settingsWindow;

@end

@implementation StatusMenuController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.reader = [[StatusReader alloc] init];
        self.settingsWindow = [[SettingsWindowController alloc] init];
    }
    return self;
}

- (void)start {
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];

    if (@available(macOS 11.0, *)) {
        self.statusItem.button.image = [NSImage imageWithSystemSymbolName:@"lock.circle" accessibilityDescription:@"LidGrace"];
    } else {
        self.statusItem.button.title = @"LG";
    }

    self.statusItem.menu = [self buildMenu];
    [self refresh:nil];

    self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                  target:self
                                                selector:@selector(refresh:)
                                                userInfo:nil
                                                 repeats:YES];
}

- (NSMenu *)buildMenu {
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"LidGrace"];

    NSMenuItem *status = [[NSMenuItem alloc] initWithTitle:@"LidGrace"
                                                    action:nil
                                             keyEquivalent:@""];
    status.tag = 9001;
    [menu addItem:status];

    [menu addItem:[NSMenuItem separatorItem]];

    NSMenuItem *enabled = [[NSMenuItem alloc] initWithTitle:@"Enabled"
                                                     action:@selector(toggleEnabled:)
                                              keyEquivalent:@""];
    enabled.target = self;
    enabled.tag = 9002;
    [menu addItem:enabled];

    [menu addItem:[NSMenuItem separatorItem]];

    NSArray *durations = @[
        @[@"1 minute", @60],
        @[@"3 minutes", @180],
        @[@"5 minutes", @300],
        @[@"10 minutes", @600],
        @[@"30 minutes", @1800]
    ];

    for (NSArray *duration in durations) {
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:duration[0]
                                                      action:@selector(setGrace:)
                                               keyEquivalent:@""];
        item.target = self;
        item.tag = [duration[1] integerValue];
        [menu addItem:item];
    }

    [menu addItem:[NSMenuItem separatorItem]];

    NSMenuItem *lock = [[NSMenuItem alloc] initWithTitle:@"Lock Screen Now"
                                                  action:@selector(lockNow:)
                                           keyEquivalent:@""];
    lock.target = self;
    [menu addItem:lock];

    NSMenuItem *settings = [[NSMenuItem alloc] initWithTitle:@"Settings..."
                                                      action:@selector(openSettings:)
                                               keyEquivalent:@""];
    settings.target = self;
    [menu addItem:settings];

    NSMenuItem *logs = [[NSMenuItem alloc] initWithTitle:@"Open Logs"
                                                  action:@selector(openLogs:)
                                           keyEquivalent:@""];
    logs.target = self;
    [menu addItem:logs];

    [menu addItem:[NSMenuItem separatorItem]];

    NSMenuItem *quit = [[NSMenuItem alloc] initWithTitle:@"Quit"
                                                  action:@selector(quit:)
                                           keyEquivalent:@""];
    quit.target = self;
    [menu addItem:quit];

    return menu;
}

- (void)refresh:(id)sender {
    NSString *title = [self.reader menuTitle];
    NSDictionary *status = [self.reader status];
    AppConfig *config = [AppConfig loadConfig];

    NSMenuItem *statusItem = [self.statusItem.menu itemWithTag:9001];
    statusItem.title = title;

    NSMenuItem *enabledItem = [self.statusItem.menu itemWithTag:9002];
    enabledItem.state = config.enabled ? NSControlStateValueOn : NSControlStateValueOff;

    for (NSMenuItem *item in self.statusItem.menu.itemArray) {
        if (item.tag == 60 || item.tag == 180 || item.tag == 300 || item.tag == 600 || item.tag == 1800) {
            item.state = (item.tag == config.graceSeconds) ? NSControlStateValueOn : NSControlStateValueOff;
        }
    }

    NSString *mode = status[@"mode"];
    if ([mode isEqualToString:@"active"]) {
        self.statusItem.button.toolTip = title;
    } else {
        self.statusItem.button.toolTip = @"LidGrace";
    }
}

- (void)toggleEnabled:(id)sender {
    AppConfig *config = [AppConfig loadConfig];
    config.enabled = !config.enabled;
    [config save:nil];
    [self refresh:nil];
}

- (void)setGrace:(NSMenuItem *)sender {
    AppConfig *config = [AppConfig loadConfig];
    config.graceSeconds = sender.tag;
    [config save:nil];
    [self refresh:nil];
}

- (void)lockNow:(id)sender {
    [LockScreenService triggerGraceAndLock];
}

- (void)openSettings:(id)sender {
    [self.settingsWindow showWindowNearStatusItem];
}

- (void)openLogs:(id)sender {
    [[NSWorkspace sharedWorkspace] openFile:@"/var/log/lidgrace.daemon.log"];
}

- (void)quit:(id)sender {
    [NSApp terminate:nil];
}

@end
