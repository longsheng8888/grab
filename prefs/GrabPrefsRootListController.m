#import "GrabPrefsRootListController.h"

@implementation GrabPrefsRootListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"小龙生自动抢单";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 30)];
    label.text = @"你好，界面加载成功了！";
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
}

@end
