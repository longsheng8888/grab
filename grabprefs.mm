#import <Foundation/Foundation.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface GrabPrefsListController : PSListController
@end

@implementation GrabPrefsListController
- (id)specifiers {
    if(_specifiers == nil) {
        NSMutableArray *specs = [NSMutableArray array];
        PSSpecifier *fee = [PSSpecifier preferenceSpecifierNamed:@"最低金额 (元)" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSListItemCell edit:nil];
        [fee setProperty:@"minFee" forKey:@"key"];
        [fee setProperty:@YES forKey:@"isNumeric"];
        [specs addObject:fee];

        PSSpecifier *dist = [PSSpecifier preferenceSpecifierNamed:@"最远距离 (km)" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSListItemCell edit:nil];
        [dist setProperty:@"maxDist" forKey:@"key"];
        [dist setProperty:@YES forKey:@"isNumeric"];
        [specs addObject:dist];
        
        _specifiers = specs;
    }
    return _specifiers;
}
- (id)readPreferenceValue:(PSSpecifier*)specifier {
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.yourname.grab.plist"];
    id val = prefs[[specifier propertyForKey:@"key"]];
    return val ? val : ([specifier propertyForKey:@"key"] isEqualToString:@"minFee"] ? @20 : @5);
}
- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.yourname.grab.plist"] ?: [NSMutableDictionary dictionary];
    prefs[[specifier propertyForKey:@"key"]] = value;
    [prefs writeToFile:@"/var/mobile/Library/Preferences/com.yourname.grab.plist" atomically:YES];
}
@end

@interface GrabPrefsRootListController : PSListController
@end
@implementation GrabPrefsRootListController
- (id)specifiers {
    if(_specifiers == nil) {
        NSMutableArray *specs = [NSMutableArray array];
        PSSpecifier *group = [PSSpecifier groupSpecifierWithName:@"自动抢单设置"];
        [group setProperty:@"默认最低20元，最远5公里。修改后点击右上角应用。" forKey:@"footerText"];
        [specs addObject:group];
        
        GrabPrefsListController *vc = [[GrabPrefsListController alloc] init];
        PSSpecifier *link = [PSSpecifier preferenceSpecifierNamed:@"修改抢单条件" target:self set:nil get:nil detail:vc cell:PSLinkListCell edit:nil];
        [specs addObject:link];
        
        _specifiers = specs;
    }
    return _specifiers;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"应用" style:UIBarButtonItemStyleDone target:self action:@selector(applyPrefs)];
}
- (void)applyPrefs {
    system("killall -9 SpringBoard");
}
@end
