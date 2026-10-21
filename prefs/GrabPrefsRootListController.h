#import <UIKit/UIKit.h>

// 自己伪造一个类，骗过 GitHub 的编译器
@interface PSListController : UIViewController
{
    NSArray *_specifiers;
}
- (NSArray *)specifiers;
- (id)loadSpecifiersFromPlistName:(NSString *)plistName target:(id)target;
@end

@interface GrabPrefsRootListController : PSListController
@end
