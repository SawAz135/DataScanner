#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScannerCore : NSObject

+ (NSString *)sourceDirectory;
+ (BOOL)prepareSourceDirectory:(NSError **)error;
+ (NSDictionary *)status;

@end

NS_ASSUME_NONNULL_END
