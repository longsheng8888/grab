#import "GrabPrefsRootListController.h"

@implementation GrabPrefsRootListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"小龙生自动抢单";
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, 300, 30)];
    label.text = @"界面加载成功！";
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
}

@end
