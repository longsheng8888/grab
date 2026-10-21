#import "GrabPrefsRootListController.h"

@implementation GrabPrefsRootListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"抢单设置";
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];

    // 画一个最低金额
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, 120, 30)];
    lbl.text = @"最低金额(元):";
    [self.view addSubview:lbl];

    UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(150, 100, 100, 30)];
    tf.borderStyle = UITextBorderStyleRoundedRect;
    tf.text = @"20";
    tf.keyboardType = UIKeyboardTypeNumberPad;
    tf.tag = 100;
    [self.view addSubview:tf];
    
    // 画一个保存按钮
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(20, 160, 230, 44);
    [btn setTitle:@"保存设置" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)save {
    UITextField *tf = (UITextField *)[self.view viewWithTag:100];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"minYuan"] = @([tf.text doubleValue]);
    dict[@"enabled"] = @YES;
    [dict writeToFile:@"/var/mobile/Library/Preferences/com.yourname.grab.plist" atomically:YES];
    
    // 发通知让 Tweak 生效
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.yourname.grab.prefs.changed"), NULL, NULL, YES);
    
    UIAlertController *a = [UIAlertController alertControllerWithTitle:@"已保存" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [a addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:a animated:YES completion:nil];
}
@end
