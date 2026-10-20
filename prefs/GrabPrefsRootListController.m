#import "GrabPrefsRootListController.h"

#define PREFS_NOTIFY "com.yourname.grab.prefs.changed"

@implementation GrabPrefsRootListController

- (NSArray *)specifiers {
    if (_specifiers == nil) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }
    return _specifiers;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
        initWithTitle:@"保存"
        style:UIBarButtonItemStyleDone
        target:self
        action:@selector(save)];
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
