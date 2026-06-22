#import "SettingsWindowController.h"
#import "AppConfig.h"

@interface SettingsWindowController ()
@property(nonatomic, strong) NSButton *enabledBox;
@property(nonatomic, strong) NSPopUpButton *durationPopup;
@end

@implementation SettingsWindowController

- (instancetype)init {
    NSRect frame = NSMakeRect(0, 0, 360, 180);
    NSWindow *window = [[NSWindow alloc] initWithContentRect:frame
                                                   styleMask:(NSWindowStyleMaskTitled | NSWindowStyleMaskClosable)
                                                     backing:NSBackingStoreBuffered
                                                       defer:NO];
    self = [super initWithWindow:window];
    if (self) {
        window.title = @"LidGrace Settings";
        [self buildUI];
        [self reload];
    }
    return self;
}

- (void)buildUI {
    NSView *content = self.window.contentView;

    NSTextField *title = [[NSTextField alloc] initWithFrame:NSMakeRect(24, 125, 312, 24)];
    title.stringValue = @"Sleep grace period";
    title.editable = NO;
    title.bordered = NO;
    title.drawsBackground = NO;
    title.font = [NSFont boldSystemFontOfSize:14];
    [content addSubview:title];

    self.enabledBox = [[NSButton alloc] initWithFrame:NSMakeRect(24, 92, 280, 24)];
    self.enabledBox.buttonType = NSSwitchButton;
    self.enabledBox.title = @"Enable LidGrace";
    self.enabledBox.target = self;
    self.enabledBox.action = @selector(saveFromUI:);
    [content addSubview:self.enabledBox];

    self.durationPopup = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(24, 52, 180, 28)];
    NSArray *items = @[
        @[@"1 minute", @60],
        @[@"3 minutes", @180],
        @[@"5 minutes", @300],
        @[@"10 minutes", @600],
        @[@"30 minutes", @1800]
    ];

    for (NSArray *item in items) {
        [self.durationPopup addItemWithTitle:item[0]];
        self.durationPopup.lastItem.tag = [item[1] integerValue];
    }

    self.durationPopup.target = self;
    self.durationPopup.action = @selector(saveFromUI:);
    [content addSubview:self.durationPopup];
}

- (void)reload {
    AppConfig *config = [AppConfig loadConfig];
    self.enabledBox.state = config.enabled ? NSControlStateValueOn : NSControlStateValueOff;

    for (NSMenuItem *item in self.durationPopup.itemArray) {
        if (item.tag == config.graceSeconds) {
            [self.durationPopup selectItem:item];
            break;
        }
    }
}

- (void)saveFromUI:(id)sender {
    AppConfig *config = [AppConfig loadConfig];
    config.enabled = (self.enabledBox.state == NSControlStateValueOn);
    config.graceSeconds = self.durationPopup.selectedItem.tag;
    [config save:nil];
}

- (void)showWindowNearStatusItem {
    [self reload];
    [self showWindow:nil];
    [self.window makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
}

@end
