#import "GrabPrefsRootListController.h"

@interface GrabPrefsRootListController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITextField *moneyField;
@property (nonatomic, strong) UITextField *kmField;
@end

@implementation GrabPrefsRootListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"小龙生自动抢单";
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleInsetGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(savePrefs)];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    for (UIView *v in cell.contentView.subviews) {
        [v removeFromSuperview];
    }

    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 150, 30)];
    UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(160, 10, 150, 30)];
    tf.borderStyle = UITextBorderStyleRoundedRect;
    tf.keyboardType = UIKeyboardTypeDecimalPad;

    if (indexPath.row == 0) {
        lbl.text = @"最低金额(元)";
        tf.text = @"20";
        self.moneyField = tf;
    } else {
        lbl.text = @"最远距离(km)";
        tf.text = @"5";
        self.kmField = tf;
    }
    
    [cell.contentView addSubview:lbl];
    [cell.contentView addSubview:tf];
    return cell;
}

- (void)savePrefs {
    [self.view endEditing:YES];
    
    NSMutableDictionary *prefs = [NSMutableDictionary dictionary];
    prefs[@"minYuan"] = @([self.moneyField.text doubleValue]);
    prefs[@"maxKm"] = @([self.kmField.text doubleValue]);
    prefs[@"enabled"] = @YES;
    
    NSString *path = @"/var/mobile/Library/Preferences/com.yourname.grab.plist";
    [prefs writeToFile:path atomically:YES];
    
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.yourname.grab.prefs.changed"), NULL, NULL, YES);
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"保存成功" message:@"配置已生效" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
