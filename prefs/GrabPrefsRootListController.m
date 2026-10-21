#import "GrabPrefsRootListController.h"

@implementation GrabPrefsRootListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"小龙生自动抢单";
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:scrollView];

    // 1. 开关
    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(250, 20, 50, 30)];
    // 默认开启
    [sw setOn:YES];
    [sw addTarget:self action:@selector(save) forControlEvents:UIControlEventValueChanged];
    [scrollView addSubview:sw];
    
    UILabel *lbl1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 200, 30)];
    lbl1.text = @"启用自动抢单";
    [scrollView addSubview:lbl1];
    
    // 2. 金额输入
    UILabel *lbl2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 80, 200, 30)];
    lbl2.text = @"最低金额(元)";
    [scrollView addSubview:lbl2];
    
    UITextField *tf1 = [[UITextField alloc] initWithFrame:CGRectMake(250, 80, 100, 30)];
    tf1.borderStyle = UITextBorderStyleRoundedRect;
    tf1.keyboardType = UIKeyboardTypeNumberPad;
    tf1.text = @"20";
    tf1.tag = 1001;
    [scrollView addSubview:tf1];
    
    // 3. 距离输入
    UILabel *lbl3 = [[UILabel alloc] initWithFrame:CGRectMake(20, 140, 200, 30)];
    lbl3.text = @"最远距离(公里)";
    [scrollView addSubview:lbl3];
    
    UITextField *tf2 = [[UITextField alloc] initWithFrame:CGRectMake(250, 140, 100, 30)];
    tf2.borderStyle = UITextBorderStyleRoundedRect;
    tf2.keyboardType = UIKeyboardTypeNumberPad;
    tf2.text = @"5";
    tf2.tag = 1002;
    [scrollView addSubview:tf2];
    
    // 4. 保存按钮
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(20, 200, 330, 44);
    btn.backgroundColor = [UIColor systemBlueColor];
    [btn setTitle:@"保存设置" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.layer.cornerRadius = 10;
    [btn addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:btn];
}

- (void)save {
    // 这里负责把配置写入文件
}

@end
