#import "GrabPrefsRootListController.h"
#import <objc/runtime.h>

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
