
#import "ScannerMenu.h"
#import "ScannerCore.h"
#import "ScriptScanner.h"
#import "ExportManager.h"

static UIWindow *scannerWindow = nil;
static UIView *floatingButton = nil;
static UIView *menuPanel = nil;
static BOOL menuVisible = NO;

@implementation ScannerMenu

+ (UIColor *)backgroundColor {
    return [UIColor colorWithRed:0.055 green:0.065 blue:0.09 alpha:0.98];
}

+ (UIColor *)accentColor {
    return [UIColor colorWithRed:0.30 green:0.48 blue:1.0 alpha:1.0];
}

+ (UILabel *)makeLabel:(NSString *)text
                  size:(CGFloat)size
                 color:(UIColor *)color {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont systemFontOfSize:size
                                   weight:UIFontWeightSemibold];
    label.textColor = color;
    label.numberOfLines = 0;
    return label;
}

+ (UIButton *)makeButton:(NSString *)title action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14
                                               weight:UIFontWeightSemibold];
    button.backgroundColor = [self accentColor];
    button.layer.cornerRadius = 12;
    [button addTarget:self
               action:action
     forControlEvents:UIControlEventTouchUpInside];
    return button;
}

+ (void)showMenu {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (scannerWindow) {
            return;
        }

        UIWindowScene *activeScene = nil;

        for (UIScene *scene in
             UIApplication.sharedApplication.connectedScenes) {
            if (scene.activationState ==
                    UISceneActivationStateForegroundActive &&
                [scene isKindOfClass:[UIWindowScene class]]) {
                activeScene = (UIWindowScene *)scene;
                break;
            }
        }

        if (!activeScene) {
            NSLog(@"[DataScanner] No active scene.");
            return;
        }

        scannerWindow =
            [[UIWindow alloc] initWithWindowScene:activeScene];

        scannerWindow.frame = activeScene.coordinateSpace.bounds;
        scannerWindow.windowLevel = UIWindowLevelAlert + 1;
        scannerWindow.backgroundColor = UIColor.clearColor;

        UIViewController *controller = [[UIViewController alloc] init];
        controller.view.backgroundColor = UIColor.clearColor;
        controller.view.frame = scannerWindow.bounds;
        controller.view.autoresizingMask =
            UIViewAutoresizingFlexibleWidth |
            UIViewAutoresizingFlexibleHeight;

        scannerWindow.rootViewController = controller;
        scannerWindow.hidden = NO;

        [self createFloatingButton];
    });
}

+ (void)createFloatingButton {
    if (!scannerWindow || floatingButton) {
        return;
    }

    UIView *button =
        [[UIView alloc] initWithFrame:CGRectMake(16, 180, 54, 54)];

    button.backgroundColor = [self accentColor];
    button.layer.cornerRadius = 27;
    button.layer.borderWidth = 2;
    button.layer.borderColor = UIColor.whiteColor.CGColor;
    button.layer.shadowColor = UIColor.blackColor.CGColor;
    button.layer.shadowOpacity = 0.35;
    button.layer.shadowRadius = 8;
    button.layer.shadowOffset = CGSizeMake(0, 3);
    button.userInteractionEnabled = YES;

    UILabel *title = [self makeLabel:@"DS"
                                size:16
                               color:UIColor.whiteColor];

    title.frame = button.bounds;
    title.textAlignment = NSTextAlignmentCenter;
    title.autoresizingMask =
        UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleHeight;
    title.userInteractionEnabled = NO;

    [button addSubview:title];

    UITapGestureRecognizer *tap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(toggleMenu)];

    UIPanGestureRecognizer *pan =
        [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(moveButton:)];

    [button addGestureRecognizer:tap];
    [button addGestureRecognizer:pan];

    floatingButton = button;
    [scannerWindow.rootViewController.view addSubview:floatingButton];
}

+ (void)moveButton:(UIPanGestureRecognizer *)gesture {
    UIView *view = gesture.view;
    UIView *parent = view.superview;

    CGPoint delta = [gesture translationInView:parent];

    view.center = CGPointMake(view.center.x + delta.x,
                              view.center.y + delta.y);

    [gesture setTranslation:CGPointZero inView:parent];

    if (gesture.state == UIGestureRecognizerStateEnded) {
        CGRect bounds = parent.bounds;
        CGFloat halfW = CGRectGetWidth(view.bounds) / 2;
        CGFloat halfH = CGRectGetHeight(view.bounds) / 2;

        CGFloat x = MIN(MAX(view.center.x, halfW),
                        CGRectGetWidth(bounds) - halfW);
        CGFloat y = MIN(MAX(view.center.y, halfH),
                        CGRectGetHeight(bounds) - halfH);

        [UIView animateWithDuration:0.18 animations:^{
            view.center = CGPointMake(x, y);
        }];
    }
}

+ (void)toggleMenu {
    if (menuVisible) {
        [self hideMenu];
    } else {
        [self openMenu];
    }
}

+ (void)openMenu {
    if (!scannerWindow || menuVisible) {
        return;
    }

    menuVisible = YES;

    UIView *root = scannerWindow.rootViewController.view;
    CGFloat width = MIN(CGRectGetWidth(root.bounds) - 32, 360);
    CGFloat height = 330;

    if (width < 250) {
        width = MAX(CGRectGetWidth(root.bounds) - 20, 220);
    }

    UIView *panel =
        [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];

    panel.center = CGPointMake(CGRectGetMidX(root.bounds),
                               CGRectGetMidY(root.bounds));

    panel.backgroundColor = [self backgroundColor];
    panel.layer.cornerRadius = 22;
    panel.layer.borderWidth = 1;
    panel.layer.borderColor =
        [UIColor colorWithWhite:1 alpha:0.15].CGColor;
    panel.layer.shadowColor = UIColor.blackColor.CGColor;
    panel.layer.shadowOpacity = 0.35;
    panel.layer.shadowRadius = 18;
    panel.layer.shadowOffset = CGSizeMake(0, 6);

    UILabel *heading = [self makeLabel:@"DATASCANNER"
                                  size:20
                                 color:UIColor.whiteColor];

    heading.frame = CGRectMake(20, 18, width - 80, 28);
    heading.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [panel addSubview:heading];

    UIButton *close =
        [UIButton buttonWithType:UIButtonTypeSystem];

    close.frame = CGRectMake(width - 48, 12, 36, 36);
    close.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [close setTitle:@"✕" forState:UIControlStateNormal];
    [close setTitleColor:UIColor.whiteColor
                forState:UIControlStateNormal];
    close.backgroundColor = [UIColor colorWithWhite:1 alpha:0.10];
    close.layer.cornerRadius = 10;

    [close addTarget:self
              action:@selector(hideMenu)
    forControlEvents:UIControlEventTouchUpInside];

    [panel addSubview:close];

    UILabel *subtitle =
        [self makeLabel:@"LOCAL SOURCE FILE EXPLORER"
                   size:10
                  color:[UIColor colorWithWhite:0.65 alpha:1]];

    subtitle.frame = CGRectMake(20, 52, width - 40, 18);
    subtitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [panel addSubview:subtitle];

    UIView *line =
        [[UIView alloc] initWithFrame:CGRectMake(20, 82, width - 40, 1)];

    line.backgroundColor = [UIColor colorWithWhite:1 alpha:0.12];
    line.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [panel addSubview:line];

    UILabel *status =
        [self makeLabel:@"Ready to scan local files"
                   size:12
                  color:[UIColor colorWithWhite:0.85 alpha:1]];

    status.frame = CGRectMake(20, 96, width - 40, 26);
    status.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    status.tag = 4001;
    [panel addSubview:status];

    UIButton *scanButton =
        [self makeButton:@"SCAN SOURCE FILES"
                  action:@selector(scanFiles)];

    scanButton.frame = CGRectMake(20, 135, width - 40, 48);
    scanButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [panel addSubview:scanButton];

    UIButton *exportButton =
        [self makeButton:@"COPY STATUS JSON"
                  action:@selector(exportStatus)];

    exportButton.frame = CGRectMake(20, 195, width - 40, 44);
    exportButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    exportButton.backgroundColor =
        [UIColor colorWithRed:0.16 green:0.19 blue:0.27 alpha:1];

    [panel addSubview:exportButton];

    UILabel *footer =
        [self makeLabel:@"Tap DS to reopen after closing"
                   size:10
                  color:[UIColor colorWithWhite:0.58 alpha:1]];

    footer.textAlignment = NSTextAlignmentCenter;
    footer.frame = CGRectMake(20, 270, width - 40, 20);
    footer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [panel addSubview:footer];

    menuPanel = panel;
    [root addSubview:menuPanel];
    [root bringSubviewToFront:floatingButton];
}

+ (void)hideMenu {
    menuVisible = NO;
    [menuPanel removeFromSuperview];
    menuPanel = nil;
}

+ (void)scanFiles {
    if (!menuPanel) {
        return;
    }

    NSArray<NSDictionary *> *files =
        [[[ScriptScanner alloc] init] scan];

    UILabel *status = [menuPanel viewWithTag:4001];
    status.text = [NSString stringWithFormat:
                   @"Found %lu local file(s)",
                   (unsigned long)files.count];

    [self showMessage:@"Scan complete"
              message:[NSString stringWithFormat:
                       @"Found %lu supported files in DataScannerSources.",
                       (unsigned long)files.count]];
}

+ (void)exportStatus {
    NSDictionary *status = [ScannerCore status];
    NSError *error = nil;

    NSData *json =
        [NSJSONSerialization dataWithJSONObject:status
                                        options:NSJSONWritingPrettyPrinted
                                          error:&error];

    if (!json || error) {
        [self showMessage:@"Export failed"
                  message:error.localizedDescription ?:
                          @"Could not create JSON."];
        return;
    }

    NSString *jsonText =
        [[NSString alloc] initWithData:json
                              encoding:NSUTF8StringEncoding];

    BOOL copied =
        [ExportManager copyTextToClipboard:jsonText ?: @"{}"];

    if (copied) {
        [self showMessage:@"Copied"
                  message:@"Status JSON copied to clipboard."];
    } else {
        [self showMessage:@"Copy failed"
                  message:@"Unable to copy the status JSON."];
    }
}

+ (void)showMessage:(NSString *)title
            message:(NSString *)message {
    if (!scannerWindow ||
        scannerWindow.rootViewController.presentedViewController) {
        return;
    }

    UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:title
                                            message:message
                                     preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:
        [UIAlertAction actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                               handler:nil]];

    [scannerWindow.rootViewController presentViewController:alert
                                                   animated:YES
                                                 completion:nil];
}

@end
