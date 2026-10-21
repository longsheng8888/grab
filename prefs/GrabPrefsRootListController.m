#import "GrabPrefsRootListController.h"
#import <objc/runtime.h>

@interface GrabPrefsRootListController ()
{
    NSArray *_specifiers;
}
@end

@implementation GrabPrefsRootListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"抢单设置";
    
    // 动态去系统里找加载界面的方法，GitHub编译机没这方法也不会报错
    SEL sel = NSSelectorFromString(@"loadSpecifiersFromPlistName:target:");
    if ([self respondsToSelector:sel]) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        _specifiers = [self performSelector:sel withObject:@"Root" withObject:self];
        #pragma clang diagnostic pop
    }
}

- (NSArray *)specifiers {
    return _specifiers;
}

@end
