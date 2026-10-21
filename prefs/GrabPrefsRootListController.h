#import <UIKit/UIKit.h>

@interface GrabPrefsRootListController : UIViewController
{
    NSArray *_specifiers;
}
- (NSArray *)specifiers;
- (id)loadSpecifiersFromPlistName:(NSString *)plistName target:(id)target;
@end
