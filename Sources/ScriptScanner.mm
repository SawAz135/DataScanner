
#import "ScriptScanner.h"
#import "ScannerCore.h"

@implementation ScriptScanner

- (NSArray<NSDictionary *> *)scan {
    NSError *directoryError = nil;

    if (![ScannerCore prepareSourceDirectory:&directoryError]) {
        NSLog(@"[DataScanner] Directory error: %@",
              directoryError.localizedDescription);
        return @[];
    }

    NSString *rootPath = [ScannerCore sourceDirectory];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSArray<NSString *> *allowedExtensions = @[
        @"lua",
        @"luau",
        @"txt",
        @"json",
        @"xml",
        @"md"
    ];

    NSMutableArray<NSDictionary *> *results =
        [NSMutableArray array];

    NSDirectoryEnumerator *enumerator =
        [fileManager enumeratorAtPath:rootPath];

    NSString *relativePath = nil;

    while ((relativePath = [enumerator nextObject]) != nil) {
        NSString *fullPath =
            [rootPath stringByAppendingPathComponent:relativePath];

        BOOL isDirectory = NO;

        if (![fileManager fileExistsAtPath:fullPath
                               isDirectory:&isDirectory]) {
            continue;
        }

        if (isDirectory) {
            continue;
        }

        NSString *extension =
            relativePath.pathExtension.lowercaseString;

        if (![allowedExtensions containsObject:extension]) {
            continue;
        }

        NSError *attributesError = nil;

        NSDictionary<NSFileAttributeKey, id> *attributes =
            [fileManager attributesOfItemAtPath:fullPath
                                          error:&attributesError];

        if (!attributes || attributesError) {
            continue;
        }

        unsigned long long fileSize =
            [attributes fileSize];

        if (fileSize > 2ULL * 1024ULL * 1024ULL) {
            continue;
        }

        [results addObject:@{
            @"name": relativePath.lastPathComponent,
            @"path": fullPath,
            @"relativePath": relativePath,
            @"extension": extension,
            @"size": @(fileSize),
            @"modified": attributes[NSFileModificationDate]
                ?: [NSDate date]
        }];
    }

    return [results copy];
}

- (NSString *)readSourceAtPath:(NSString *)path
                         error:(NSError **)error {
    NSString *rootPath =
        [[ScannerCore sourceDirectory]
            stringByStandardizingPath];

    NSString *targetPath =
        [path stringByStandardizingPath];

    NSString *requiredPrefix =
        [rootPath stringByAppendingString:@"/"];

    if (![targetPath hasPrefix:requiredPrefix]) {
        if (error) {
            *error = [NSError errorWithDomain:@"DataScanner"
                                         code:1
                                     userInfo:@{
                NSLocalizedDescriptionKey:
                    @"Access denied: file is outside the scanner directory."
            }];
        }

        return nil;
    }

    NSFileManager *fileManager =
        [NSFileManager defaultManager];

    BOOL isDirectory = NO;

    if (![fileManager fileExistsAtPath:targetPath
                           isDirectory:&isDirectory] ||
        isDirectory) {
        if (error) {
            *error = [NSError errorWithDomain:@"DataScanner"
                                         code:2
                                     userInfo:@{
                NSLocalizedDescriptionKey:
                    @"The requested file does not exist or is not a file."
            }];
        }

        return nil;
    }

    NSString *extension =
        targetPath.pathExtension.lowercaseString;

    NSSet<NSString *> *allowedExtensions = [NSSet setWithArray:@[
        @"lua",
        @"luau",
        @"txt",
        @"json",
        @"xml",
        @"md"
    ]];

    if (![allowedExtensions containsObject:extension]) {
        if (error) {
            *error = [NSError errorWithDomain:@"DataScanner"
                                         code:3
                                     userInfo:@{
                NSLocalizedDescriptionKey:
                    @"This file type is not supported."
            }];
        }

        return nil;
    }

    NSError *attributesError = nil;

    NSDictionary<NSFileAttributeKey, id> *attributes =
        [fileManager attributesOfItemAtPath:targetPath
                                      error:&attributesError];

    if (!attributes) {
        if (error) {
            *error = attributesError;
        }

        return nil;
    }

    unsigned long long fileSize =
        [attributes fileSize];

    if (fileSize > 2ULL * 1024ULL * 1024ULL) {
        if (error) {
            *error = [NSError errorWithDomain:@"DataScanner"
                                         code:4
                                     userInfo:@{
                NSLocalizedDescriptionKey:
                    @"The file exceeds the 2 MiB size limit."
            }];
        }

        return nil;
    }

    return [NSString stringWithContentsOfFile:targetPath
                                     encoding:NSUTF8StringEncoding
                                        error:error];
}

@end
