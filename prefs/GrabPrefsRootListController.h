#import <UIKit/UIKit.h>

@interface PSListController : UIViewController
{
    NSArray *_specifiers;
}
- (NSArray *)specifiers;
- (id)loadSpecifiersFromPlistName:(NSString *)plistName target:(id)target;
@end

@interface GrabPrefsRootListController : PSListController
@end
