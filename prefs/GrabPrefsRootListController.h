#import <UIKit/UIKit.h>

// 手动声明 Preferences 框架的类和变量，防止 GitHub 编译机报错
@interface PSListController : UIViewController
{
    NSArray *_specifiers; // 骗过编译器的声明
}
- (NSArray *)specifiers;
- (id)loadSpecifiersFromPlistName:(NSString *)plistName target:(id)target;
@end

@interface GrabPrefsRootListController : PSListController
@end
