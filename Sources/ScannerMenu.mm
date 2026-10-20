
#import "ScannerMenu.h"
#import "ScannerCore.h"
#import "ScriptScanner.h"
#import "ExportManager.h"

@interface ScannerMenu ()
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UINavigationController *navigation;
@end

@implementation ScannerMenu

static ScannerMenu *sharedMenu;

+ (void)showMenu {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!sharedMenu) {
            sharedMenu = [ScannerMenu new];
        }
        [sharedMenu present];
    });
}

+ (void)hideMenu {
    dispatch_async(dispatch_get_main_queue(), ^{
        sharedMenu.window.hidden = YES;
        sharedMenu.window = nil;
    });
}

- (void)present {
    if (self.window) {
        self.window.hidden = NO;
        return;
    }

    UIViewController *root = [UIViewController new];
    root.view.backgroundColor = [UIColor colorWithRed:0.04
                                                 green:0.05
                                                  blue:0.10
                                                 alpha:1.0];

    UILabel *title = [UILabel new];
    title.text = @"DATASCANNER";
    title.textColor = [UIColor colorWithRed:0.20
                                      green:0.95
                                       blue:0.95
                                      alpha:1.0];
    title.font = [UIFont boldSystemFontOfSize:25];
    title.translatesAutoresizingMaskIntoConstraints = NO;
    [root.view addSubview:title];

    UILabel *subtitle = [UILabel new];
    subtitle.text = @"Authorized source explorer";
    subtitle.textColor = UIColor.lightGrayColor;
    subtitle.translatesAutoresizingMaskIntoConstraints = NO;
    [root.view addSubview:subtitle];

    UIButton *scanButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [scanButton setTitle:@"SCAN SOURCE FILES" forState:UIControlStateNormal];
    [scanButton setTitleColor:UIColor.whiteColor
                     forState:UIControlStateNormal];
    scanButton.backgroundColor =
        [UIColor colorWithRed:0.05 green:0.55 blue:0.65 alpha:1.0];
    scanButton.layer.cornerRadius = 12;
    scanButton.translatesAutoresizingMaskIntoConstraints = NO;
    [scanButton addTarget:self
                   action:@selector(scanFiles)
         forControlEvents:UIControlEventTouchUpInside];
    [root.view addSubview:scanButton];

    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [closeButton setTitle:@"CLOSE" forState:UIControlStateNormal];
    closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [closeButton addTarget:self
                    action:@selector(closeMenu)
          forControlEvents:UIControlEventTouchUpInside];
    [root.view addSubview:closeButton];

    [NSLayoutConstraint activateConstraints:@[
        [title.topAnchor constraintEqualToAnchor:root.view.safeAreaLayoutGuide.topAnchor constant:24],
        [title.centerXAnchor constraintEqualToAnchor:root.view.centerXAnchor],
        [subtitle.topAnchor constraintEqualToAnchor:title.bottomAnchor constant:8],
        [subtitle.centerXAnchor constraintEqualToAnchor:root.view.centerXAnchor],
        [scanButton.topAnchor constraintEqualToAnchor:subtitle.bottomAnchor constant:28],
        [scanButton.leadingAnchor constraintEqualToAnchor:root.view.leadingAnchor constant:20],
        [scanButton.trailingAnchor constraintEqualToAnchor:root.view.trailingAnchor constant:-20],
        [scanButton.heightAnchor constraintEqualToConstant:52],
        [closeButton.topAnchor constraintEqualToAnchor:scanButton.bottomAnchor constant:14],
        [closeButton.centerXAnchor constraintEqualToAnchor:root.view.centerXAnchor]
    ]];

    self.navigation = [[UINavigationController alloc]
        initWithRootViewController:root];
    self.navigation.navigationBarHidden = YES;

    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = self.navigation;
    self.window.windowLevel = UIWindowLevelAlert + 1;
    self.window.hidden = NO;
}

- (void)scanFiles {
    NSArray *files = [[ScriptScanner alloc] scan];

    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"Scan complete"
                         message:[NSString stringWithFormat:
                             @"%lu authorized source files found.",
                             (unsigned long)files.count]
                  preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction
        actionWithTitle:@"OK"
                  style:UIAlertActionStyleDefault
                handler:nil]];

    [self.navigation.topViewController presentViewController:alert
                                                    animated:YES
                                                  completion:nil];
}

- (void)closeMenu {
    self.window.hidden = YES;
    self.window = nil;
}

@end
