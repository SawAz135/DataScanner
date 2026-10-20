
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ExportManager : NSObject

+ (BOOL)exportJSON:(id)object
         toFileURL:(NSURL *)url
             error:(NSError **)error;

+ (BOOL)copyTextToClipboard:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
