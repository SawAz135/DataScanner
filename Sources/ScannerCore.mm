
#import "ScannerCore.h"

@implementation ScannerCore

+ (NSString *)sourceDirectory {
    NSString *documents =
        NSSearchPathForDirectoriesInDomains(
            NSDocumentDirectory,
            NSUserDomainMask,
            YES
        ).firstObject;

    return [documents
        stringByAppendingPathComponent:@"DataScannerSources"];
}

+ (BOOL)prepareSourceDirectory:(NSError **)error {
    return [[NSFileManager defaultManager]
        createDirectoryAtPath:[self sourceDirectory]
        withIntermediateDirectories:YES
        attributes:nil
        error:error];
}

+ (NSDictionary *)status {
    NSError *error = nil;
    BOOL ready = [self prepareSourceDirectory:&error];

    return @{
        @"name": @"DataScanner",
        @"version": @"1.0.0",
        @"sourceDirectory": [self sourceDirectory],
        @"ready": @(ready),
        @"error": error.localizedDescription ?: [NSNull null]
    };
}

@end
