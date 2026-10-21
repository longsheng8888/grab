#import <UIKit/UIKit.h>

// 直接声明私有头文件，跳过链接错误
@interface PSListController : UIViewController
{
    NSArray *_specifiers;
}
- (NSArray *)specifiers;
- (id)loadSpecifiersFromPlistName:(NSString *)plistName target:(id)target;
@end

@interface GrabPrefsRootListController : PSListController
@end
