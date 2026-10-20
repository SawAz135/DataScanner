
#import <UIKit/UIKit.h>
#import "ScannerCore.h"
#import "ScannerMenu.h"

static BOOL scannerInitialized = NO;

static void DataScannerInitialize(void) {
    if (scannerInitialized) {
        return;
    }

    NSError *error = nil;

    if (![ScannerCore prepareSourceDirectory:&error]) {
        NSLog(@"[DataScanner] Setup failed: %@",
              error.localizedDescription);
        return;
    }

    [ScannerMenu showMenu];
    scannerInitialized = YES;

    NSLog(@"[DataScanner] Initialization requested.");
}

%ctor {
    @autoreleasepool {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]
                addObserverForName:UIApplicationDidBecomeActiveNotification
                            object:nil
                             queue:[NSOperationQueue mainQueue]
                        usingBlock:^(NSNotification *notification) {
                DataScannerInitialize();
            }];

            DataScannerInitialize();
        });
    }
}
