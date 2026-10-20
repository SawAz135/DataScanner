
#import "ScannerMenu.h"
#import "ScannerCore.h"
#import "ScriptScanner.h"
#import "ExportManager.h"

@interface ScannerMenu ()
@end

@implementation ScannerMenu

static UIWindow *scannerWindow = nil;
static UIView *floatingButton = nil;
static UIView *menuPanel = nil;
static BOOL menuVisible = NO;

+ (UIColor *)backgroundColor {
    return [UIColor colorWithRed:0.055
                           green:0.065
                            blue:0.09
                           alpha:0.97];
}

+ (UIColor *)accentColor {
    return [UIColor colorWithRed:0.35
                           green:0.55
                            blue:1.0
                           alpha:1.0];
}

+ (UILabel *)label:(NSString *)text
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

+ (UIButton *)button:(NSString *)title
              action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15
                                               weight:UIFontWeightSemibold];
    button.backgroundColor = [self accentColor];
    [button setTitleColor:UIColor.whiteColor
                 forState:UIControlStateNormal];
    button.layer.cornerRadius = 12;
    [button addTarget:self
               action:action
     forControlEvents:UIControlEventTouchUpInside];
    return button;
}

+ (void)showMenu {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (scannerWindow) {
            [self showFloatingButton];
            return;
        }

        UIWindowScene *activeScene = nil;

        for (UIScene *scene in
             UIApplication.sharedApplication.connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive &&
                [scene isKindOfClass:[UIWindowScene class]]) {
                activeScene = (UIWindowScene *)scene;
                break;
            }
        }

        if (!activeScene) {
            NSLog(@"[DataScanner] No active window scene.");
            return;
        }

        scannerWindow = [[UIWindow alloc] initWithWindowScene:activeScene];
        scannerWindow.frame = activeScene.coordinateSpace.bounds;
        scannerWindow.windowLevel = UIWindowLevelAlert + 1;
        scannerWindow.backgroundColor = UIColor.clearColor;
        scannerWindow.rootViewController = [[UIViewController alloc] init];
        scannerWindow.rootViewController.view.backgroundColor =
            UIColor.clearColor;
        scannerWindow.rootViewController.view.userInteractionEnabled = YES;
        scannerWindow.hidden = NO;

        [self showFloatingButton];
        [self hideMenu];
    });
}

+ (void)showFloatingButton {
    if (!scannerWindow || floatingButton) {
        return;
    }

    UIView *button = [[UIView alloc] initWithFrame:
                      CGRectMake(18, 180, 54, 54)];
    button.backgroundColor = [self accentColor];
    button.layer.cornerRadius = 27;
    button.layer.borderWidth = 2;
    button.layer.borderColor =
        [UIColor colorWithWhite:1 alpha:0.85].CGColor;
    button.layer.shadowColor = UIColor.blackColor.CGColor;
    button.layer.shadowOpacity = 0.3;
    button.layer.shadowRadius = 8;
    button.layer.shadowOffset = CGSizeMake(0, 3);
    button.userInteractionEnabled = YES;

    UILabel *title = [self label:@"DS"
                            size:16
                           color:UIColor.whiteColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.frame = button.bounds;
    title.autoresizingMask =
        UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleHeight;
    title.userInteractionEnabled = NO;
    [button addSubview:title];

    UITapGestureRecognizer *tap =
        [[UITapGestureRecognizer alloc]
         initWithTarget:self
         action:@selector(toggleMenu)];
    [button addGestureRecognizer:tap];

    UIPanGestureRecognizer *pan =
        [[UIPanGestureRecognizer alloc]
         initWithTarget:self
         action:@selector(moveFloatingButton:)];
    [button addGestureRecognizer:pan];

    floatingButton = button;
    [scannerWindow.rootViewController.view addSubview:floatingButton];
}

+ (void)moveFloatingButton:(UIPanGestureRecognizer *)gesture {
    UIView *view = gesture.view;
    CGPoint translation = [gesture translationInView:view.superview];

    view.center = CGPointMake(view.center.x + translation.x,
                              view.center.y + translation.y);
    [gesture setTranslation:CGPointZero inView:view.superview];

    if (gesture.state == UIGestureRecognizerStateEnded) {
        CGRect bounds = view.superview.bounds;
        CGFloat halfWidth = view.bounds.size.width / 2;
        CGFloat halfHeight = view.bounds.size.height / 2;

        CGFloat x = MIN(MAX(view.center.x, halfWidth),
                        bounds.size.width - halfWidth);
        CGFloat y = MIN(MAX(view.center.y, halfHeight),
                        bounds.size.height - halfHeight);

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

    UIView *panel = [[UIView alloc] initWithFrame:
                     CGRectMake(20, 0,
                                root.bounds.size.width - 40, 330)];
    panel.center = CGPointMake(root.bounds.size.width / 2,
                               root.bounds.size.height / 2);
    panel.autoresizingMask =
        UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleBottomMargin;
    panel.backgroundColor = [self backgroundColor];
    panel.layer.cornerRadius = 22;
    panel.layer.borderWidth = 1;
    panel.layer.borderColor =
        [UIColor colorWithWhite:1 alpha:0.14].CGColor;
    panel.layer.shadowColor = UIColor.blackColor.CGColor;
    panel.layer.shadowOpacity = 0.35;
    panel.layer.shadowRadius = 20;
    panel.layer.shadowOffset = CGSizeMake(0, 8);

    UILabel *heading = [self label:@"DATASCANNER"
                              size:20
                             color:UIColor.whiteColor];
    heading.frame = CGRectMake(20, 18, panel.bounds.size.width - 75, 28);
    heading.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [panel addSubview:heading];

    UIButton *close = [UIButton buttonWithType:UIButtonTypeSystem];
    close.frame = CGRectMake(panel.bounds.size.width - 48, 12, 36, 36);
    close.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [close setTitle:@"✕" forState:UIControlStateNormal];
    [close setTitleColor:UIColor.whiteColor
                forState:UIControlStateNormal];
    close.titleLabel.font = [UIFont systemFontOfSize:19
                                               weight:UIFontWeightBold];
    close.backgroundColor = [UIColor colorWithWhite:1 alpha:0.09];
    close.layer.cornerRadius = 11;
    [close addTarget:self
              action:@selector(hideMenu)
    forControlEvents:UIControlEventTouchUpInside];
    [panel addSubview:close];

    UILabel *subtitle =
        [self label:@"AUTHORIZED LOCAL SOURCE EXPLORER"
                size:10
               color:[UIColor colorWithWhite:0.65 alpha:1]];
    subtitle.frame = CGRectMake(20, 52, panel.bounds.size.width - 40, 18);
    subtitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [panel addSubview:subtitle];

    UIView *separator = [[UIView alloc]
                         initWithFrame:CGRectMake(20, 82,
                                                  panel.bounds.size.width - 40,
                                                  1)];
    separator.backgroundColor = [UIColor colorWithWhite:1 alpha:0.12];
    separator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [panel addSubview:separator];

    UILabel *status = [self label:@"Ready to scan local files"
                              size:13
                             color:[UIColor colorWithWhite:0.82 alpha:1]];
    status.frame = CGRectMake(20, 97, panel.bounds.size.width - 40, 24);
    status.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    status.tag = 4001;
    [panel addSubview:status];

    UIButton *scan = [self button:@"SCAN SOURCE FILES"
                           action:@selector(scanFiles)];
    scan.frame = CGRectMake(20, 137, panel.bounds.size.width - 40, 48);
    scan.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [panel addSubview:scan];

    UIButton *export = [self button:@"EXPORT STATUS JSON"
                             action:@selector(exportStatus)];
    export.frame = CGRectMake(20, 197, panel.bounds.size.width - 40, 44);
    export.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    export.backgroundColor =
        [UIColor colorWithRed:0.16 green:0.19 blue:0.27 alpha:1];
    [panel addSubview:export];

    UILabel *footer = [self label:@"Tap DS anytime to reopen"
                             size:11
                            color:[UIColor colorWithWhite:0.55 alpha:1]];
    footer.textAlignment = NSTextAlignmentCenter;
    footer.frame = CGRectMake(20, 269, panel.bounds.size.width - 40, 20);
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
    NSArray<NSDictionary *> *files = [[[ScriptScanner alloc] init] scan];

    UILabel *status = [menuPanel viewWithTag:4001];
    status.text = [NSString stringWithFormat:
                   @"Found %lu supported local file(s)",
                   (unsigned long)files.count];

    UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"Scan complete"
                                            message:[NSString stringWithFormat:
                                                     @"Found %lu supported files in DataScannerSources.",
                                                     (unsigned long)files.count]
                                     preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                              style:UIAlertActionStyleDefault
                                            handler:nil]];

    [scannerWindow.rootViewController presentViewController:alert
                                                   animated:YES
                                                 completion:nil];
}

+ (void)exportStatus {
    NSDictionary *status = [ScannerCore status];
    NSError *error = nil;

    NSData *json = [NSJSONSerialization dataWithJSONObject:status
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&error];

    if (!json || error) {
        [self showMessage:@"Export failed"
                  message:error.localizedDescription ?: @"Unable to create JSON."];
        return;
    }

    NSString *text = [[NSString alloc] initWithData:json
                                           encoding:NSUTF8StringEncoding];

    [ExportManager copyTextToClipboard:text ?: @"{}"];

    [self showMessage:@"Status copied"
              message:@"The status JSON was copied to the clipboard."];
}

+ (void)showMessage:(NSString *)title
            message:(NSString *)message {
    UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:title
                                            message:message
                                     preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                              style:UIAlertActionStyleDefault
                                            handler:nil]];

    [scannerWindow.rootViewController presentViewController:alert
                                                   animated:YES
                                                 completion:nil];
}

@end
