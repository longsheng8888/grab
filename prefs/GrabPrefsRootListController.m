#import "GrabPrefsRootListController.h"

// 告诉编译器，这个类不要直接去链接系统库
@implementation GrabPrefsRootListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }
    return _specifiers;
}

@end
