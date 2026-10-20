
#import "ScriptScanner.h"
#import "ScannerCore.h"

@implementation ScriptScanner

- (NSArray<NSDictionary *> *)scan {
    NSError *error = nil;

    if (![ScannerCore prepareSourceDirectory:&error]) {
        return @[];
    }

    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *root = [ScannerCore sourceDirectory];

    NSDirectoryEnumerator *enumerator =
        [fm enumeratorAtPath:root];

    NSSet *allowedExtensions = [NSSet setWithArray:@[
        @"lua", @"luau", @"txt", @"json", @"xml", @"md"
    ]];

    NSMutableArray<NSDictionary *> *results =
        [NSMutableArray array];

    for (NSString *relativePath in enumerator) {
        NSString *extension =
            relativePath.pathExtension.lowercaseString;

        if (![allowedExtensions containsObject:extension]) {
            continue;
        }

        NSString *fullPath =
            [root stringByAppendingPathComponent:relativePath];

        BOOL isDirectory = NO;
        if (![fm fileExistsAtPath:fullPath
                      isDirectory:&isDirectory] || isDirectory) {
            continue;
        }

        NSError *readError = nil;
        NSDictionary *attributes =
            [fm attributesOfItemAtPath:fullPath
                                error:&readError];

        if (readError || attributes.fileSize > 2 * 1024 * 1024) {
            continue;
        }

        [results addObject:@{
            @"name": relativePath.lastPathComponent,
            @"path": relativePath,
            @"extension": extension,
            @"size": attributes.fileSize
        }];
    }

    return [results copy];
}

- (NSString *)readSourceAtPath:(NSString *)path
                         error:(NSError **)error {
    NSString *root = ScannerCore.sourceDirectory;
    NSString *fullPath =
        [[root stringByAppendingPathComponent:path] stringByStandardizingPath];

    NSString *normalizedRoot =
        [root stringByStandardizingPath];

    NSString *requiredPrefix =
        [normalizedRoot stringByAppendingString:@"/"];

    if (![fullPath hasPrefix:requiredPrefix]) {
        if (error) {
            *error = [NSError errorWithDomain:@"DataScanner"
                                         code:1
                                     userInfo:@{
                NSLocalizedDescriptionKey:
                    @"Chemin non autorisé."
            }];
        }
        return nil;
    }

    BOOL isDirectory = NO;
    if (![[NSFileManager defaultManager]
            fileExistsAtPath:fullPath
                 isDirectory:&isDirectory] || isDirectory) {
        if (error) {
            *error = [NSError errorWithDomain:@"DataScanner"
                                         code:2
                                     userInfo:@{
                NSLocalizedDescriptionKey:
                    @"Fichier introuvable."
            }];
        }
        return nil;
    }

    return [NSString stringWithContentsOfFile:fullPath
                                     encoding:NSUTF8StringEncoding
                                        error:error];
}

@end
