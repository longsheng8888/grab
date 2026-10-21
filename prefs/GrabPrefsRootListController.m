#import "GrabPrefsRootListController.h"
#import <objc/runtime.h>

// 放在 .m 里面，不暴露给外部，就不会有重复定义的报错
@interface GrabPrefsRootListController () {
    NSArray *_specifiers;
}
- (id)loadSpecifiersFromPlistName:(NSString *)plistName target:(id)target;
@end

@implementation GrabPrefsRootListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        SEL sel = NSSelectorFromString(@"loadSpecifiersFromPlistName:target:");
        if ([self respondsToSelector:sel]) {
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            _specifiers = [self performSelector:sel withObject:@"Root" withObject:self];
            #pragma clang diagnostic pop
        }
    }
    return _specifiers;
}

@end
