#import "GrabPrefsRootListController.h"

@implementation GrabPrefsRootListController

// 绝杀闪退的初始化方法，系统加载设置界面必须走这里
- (instancetype)initWithContentSize:(CGSize)size {
    if (self = [super init]) {
        // 初始化
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"小龙生自动抢单";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, 300, 30)];
    label.text = @"界面加载成功！绝对不闪退！";
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
}

@end
