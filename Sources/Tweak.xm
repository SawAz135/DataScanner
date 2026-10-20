
#import <UIKit/UIKit.h>
#import "ScannerCore.h"
#import "ScannerMenu.h"

%ctor {
    @autoreleasepool {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = nil;

            if (![ScannerCore prepareSourceDirectory:&error]) {
                NSLog(@"[DataScanner] Error: %@",
                      error.localizedDescription);
                return;
            }

            NSLog(@"[DataScanner] Ready. Menu will not open automatically.");
        });
    }
}
