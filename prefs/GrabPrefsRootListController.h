#import <UIKit/UIKit.h>

// 手动声明 Preferences 框架的类，防止 GitHub 的 Mac 编译机找不到框架报错
@interface PSListController : UIViewController
- (NSArray *)specifiers;
- (id)loadSpecifiersFromPlistName:(NSString *)plistName target:(id)target;
@end

@interface GrabPrefsRootListController : PSListController
@end
