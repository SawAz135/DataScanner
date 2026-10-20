
#import "ExportManager.h"
#import <UIKit/UIKit.h>

@implementation ExportManager

+ (BOOL)exportJSON:(id)object
         toFileURL:(NSURL *)url
             error:(NSError **)error {
    if (!url.isFileURL) {
        if (error) {
            *error = [NSError errorWithDomain:@"DataScanner"
                                         code:1
                                     userInfo:@{
                NSLocalizedDescriptionKey:
                    @"Une URL de fichier local est requise."
            }];
        }
        return NO;
    }

    if (![NSJSONSerialization isValidJSONObject:object]) {
        if (error) {
            *error = [NSError errorWithDomain:@"DataScanner"
                                         code:2
                                     userInfo:@{
                NSLocalizedDescriptionKey:
                    @"Les données ne sont pas compatibles JSON."
            }];
        }
        return NO;
    }

    NSData *data = [NSJSONSerialization
        dataWithJSONObject:object
                   options:NSJSONWritingPrettyPrinted
                     error:error];

    if (!data) {
        return NO;
    }

    return [data writeToURL:url
                    options:NSDataWritingAtomic
                      error:error];
}

+ (BOOL)copyTextToClipboard:(NSString *)text {
    if (![NSThread isMainThread]) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            UIPasteboard.generalPasteboard.string = text;
        });
        return YES;
    }

    UIPasteboard.generalPasteboard.string = text;
    return YES;
}

@end
