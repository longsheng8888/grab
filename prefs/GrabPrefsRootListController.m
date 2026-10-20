#import "GrabPrefsRootListController.h"
#import <objc/runtime.h>

#define PREFS_NOTIFY "com.yourname.grab.prefs.changed"

@implementation GrabPrefsRootListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"自动抢单设置";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
        initWithTitle:@"保存"
        style:UIBarButtonItemStyleDone
        target:self
        action:@selector(save)];
        
    // 动态调用私有的 Preferences 方法加载界面
    SEL loadSel = NSSelectorFromString(@"loadSpecifiersFromPlistName:target:");
    if ([self respondsToSelector:loadSel]) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:loadSel withObject:@"Root" withObject:self];
        #pragma clang diagnostic pop
    }
}

- (void)save {
    [self.view endEditing:YES];
    CFNotificationCenterPostNotification(
        CFNotificationCenterGetDarwinNotifyCenter(),
        CFSTR(PREFS_NOTIFY), NULL, NULL, YES);
    UIAlertController *a = [UIAlertController
        alertControllerWithTitle:@"已保存"
        message:@"即刻生效"
        preferredStyle:UIAlertControllerStyleAlert];
    [a addAction:[UIAlertAction actionWithTitle:@"OK"
        style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:a animated:YES completion:nil];
}

@end
