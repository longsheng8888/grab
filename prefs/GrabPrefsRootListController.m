#import "GrabPrefsRootListController.h"
#import <objc/runtime.h>

// 这里不写 @implementation GrabPrefsRootListController : PSListController
// 直接用 UIViewController 来顶替，防止 GitHub 报错
@implementation GrabPrefsRootListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"抢单设置";
}

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
