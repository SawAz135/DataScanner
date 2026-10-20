
#import <UIKit/UIKit.h>
#import "ScannerCore.h"
#import "ScannerMenu.h"

%ctor {
    @autoreleasepool {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"[DataScanner] Tweak loaded");

            NSError *error = nil;
            if (![ScannerCore prepareSourceDirectory:&error]) {
                NSLog(@"[DataScanner] Directory error: %@",
                      error.localizedDescription);
                return;
            }

            [[NSNotificationCenter defaultCenter]
                addObserverForName:@"DataScannerInitializeMenu"
                            object:nil
                             queue:[NSOperationQueue mainQueue]
                        usingBlock:^(NSNotification *note) {
                [ScannerMenu showMenu];
            }];
        });
    }
}
