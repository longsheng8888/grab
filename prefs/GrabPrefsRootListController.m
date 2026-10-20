#import "GrabPrefsRootListController.h"
#import <Preferences/PSSpecifier.h>

@implementation GrabPrefsRootListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"自动抢单设置";
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
    
    // 手动创建 UI，避免各种找不到类的 Bug
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scroll.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:scroll];

    UILabel *lbl1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 40, 200, 30)];
    lbl1.text = @"最低金额（元）";
    lbl1.font = [UIFont systemFontOfSize:16];
    [scroll addSubview:lbl1];

    UITextField *tf1 = [[UITextField alloc] initWithFrame:CGRectMake(220, 40, 100, 30)];
    tf1.text = @"20";
    tf1.borderStyle = UITextBorderStyleRoundedRect;
    tf1.keyboardType = UIKeyboardTypeNumberPad;
    tf1.tag = 100;
    [scroll addSubview:tf1];

    UILabel *lbl2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 90, 200, 30)];
    lbl2.text = @"最远距离（公里）";
    lbl2.font = [UIFont systemFontOfSize:16];
    [scroll addSubview:lbl2];

    UITextField *tf2 = [[UITextField alloc] initWithFrame:CGRectMake(220, 90, 100, 30)];
    tf2.text = @"5";
    tf2.borderStyle = UITextBorderStyleRoundedRect;
    tf2.keyboardType = UIKeyboardTypeNumberPad;
    tf2.tag = 101;
    [scroll addSubview:tf2];

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(20, 150, 300, 44);
    [btn setTitle:@"保存设置" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(savePrefs) forControlEvents:UIControlEventTouchUpInside];
    [scroll addSubview:btn];
    
    // 读取旧数据
    NSString *plistPath = @"/var/mobile/Library/Preferences/com.yourname.grab.plist";
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    if (dict[@"minYuan"]) tf1.text = [dict[@"minYuan"] stringValue];
    if (dict[@"maxKm"]) tf2.text = [dict[@"maxKm"] stringValue];
}

- (void)savePrefs {
    UITextField *tf1 = (UITextField *)[self.view viewWithTag:100];
    UITextField *tf2 = (UITextField *)[self.view viewWithTag:101];
    
    NSString *plistPath = @"/var/mobile/Library/Preferences/com.yourname.grab.plist";
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    if (!dict) dict = [NSMutableDictionary dictionary];
    
    dict[@"minYuan"] = @([tf1.text doubleValue]);
    dict[@"maxKm"] = @([tf2.text doubleValue]);
    dict[@"enabled"] = @YES;
    
    [dict writeToFile:plistPath atomically:YES];
    
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
        CFSTR("com.yourname.grab.prefs.changed"), NULL, NULL, YES);
        
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"保存成功" message:@"设置已生效，请返回货拉拉重启" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
