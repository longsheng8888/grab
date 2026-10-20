#import <Foundation/Foundation.h>
#import <objc/message.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

// ======= 动态设置 =======
#define kPrefsPath @"/var/mobile/Library/Preferences/com.yourname.grab.plist"
static double GetMinFee() { NSDictionary *d = [NSDictionary dictionaryWithContentsOfFile:kPrefsPath]; return d[@"minFee"] ? [d[@"minFee"] doubleValue] : 20.0; }
static double GetMaxDist() { NSDictionary *d = [NSDictionary dictionaryWithContentsOfFile:kPrefsPath]; return d[@"maxDist"] ? [d[@"maxDist"] doubleValue] : 5.0; }

static NSMutableSet *gPushIds = nil;
static int gLock = 0;

static id SafeValue(id obj, NSString *key) {
    if (!obj) return nil;
    @try {
        SEL sel = NSSelectorFromString([key stringByAppendingString:@":"]);
        if ([obj respondsToSelector:sel]) {
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            return [obj performSelector:sel withObject:nil];
            #pragma clang diagnostic pop
        }
        SEL sel2 = NSSelectorFromString([key stringByAppendingString:@"_"]);
        if ([obj respondsToSelector:sel2]) {
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            return [obj performSelector:sel2];
            #pragma clang diagnostic pop
        }
        return [obj valueForKey:key];
    } @catch (__unused NSException *e) {
        return nil;
    }
}

static void DoGrab(id order, NSString *freightNo) {
    Class P = objc_getClass("HLLOrderPickupPresenter");
    if (!P) { NSLog(@"[grab] no HLLOrderPickupPresenter"); return; }
    id presenter = ((id (*)(id, SEL, id))objc_msgSend)([P alloc], sel_registerName("initWithOrder:"), order);
    if (!presenter) { NSLog(@"[grab] presenter nil for %@", freightNo); return; }

    __block id blockRef = nil;
    void (^cb)(id) = ^(id resp) {
        NSLog(@"[grab] 回调 %@ -> %@", freightNo, resp);
        gLock = 0;
        blockRef = nil;
    };
    blockRef = [cb copy];

    SEL sel = sel_registerName("startSignPickup:success:failed:");
    if ([presenter respondsToSelector:sel]) {
        ((void (*)(id, SEL, id, id, id))objc_msgSend)(presenter, sel, nil, blockRef, blockRef);
        NSLog(@"[grab] 已发起抢单 %@", freightNo);
    }
}

// ======= 主功能注入 =======
%hook HLLHallOrderProvider
- (void)orderNewBatchPushTask:(id)task {
    %orig;
    @try {
        id params = SafeValue(task, @"params");
        id data = SafeValue(params, @"data");
        id fre = SafeValue(data, @"freight_no");
        if (fre) {
            if (!gPushIds) gPushIds = [NSMutableSet new];
            [gPushIds addObject:[fre description]];
            NSLog(@"[grab] 【推送】%@", fre);
        }
    } @catch (NSException *e) {}
}

- (id)convertOrderModelsWithJson:(id)json {
    id ret = %orig;
    @try {
        if (![ret respondsToSelector:@selector(count)]) return ret;
        NSUInteger cnt = ((NSUInteger (*)(id, SEL))objc_msgSend)(ret, sel_registerName("count"));
        for (NSUInteger i = 0; i < cnt; i++) {
            id o = ((id (*)(id, SEL, NSUInteger))objc_msgSend)(ret, sel_registerName("objectAtIndex:"), i);
            id freObj = SafeValue(o, @"freight_no");
            if (!freObj) continue;
            NSString *fre = [freObj description];

            double yuan = [SafeValue(o, @"total_fee_fen") doubleValue] / 100.0;
            double km = [SafeValue(o, @"navigation_value") doubleValue] / 1000.0;

            BOOL isPush = (gPushIds && [gPushIds containsObject:fre]);
            BOOL hit = (yuan >= GetMinFee() && km <= GetMaxDist());

            NSLog(@"[grab] %@%@ %@ | %.2f元 | %.2fkm", isPush ? @"[推送]" : @"", hit ? @"[达标]" : @"", fre, yuan, km);

            if (isPush && hit && gLock < 1) {
                gLock = 1;
                NSLog(@"[grab] ★★★ 抢单 %@", fre);
                DoGrab(o, fre);
            }
        }
    } @catch (NSException *e) {}
    return ret;
}
%end

// ======= 手机设置界面 =======
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
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:kPrefsPath];
    id val = prefs[[specifier propertyForKey:@"key"]];
    return val ? val : ([specifier propertyForKey:@"key"] isEqualToString:@"minFee"] ? @20 : @5);
}
- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:kPrefsPath] ?: [NSMutableDictionary dictionary];
    prefs[[specifier propertyForKey:@"key"]] = value;
    [prefs writeToFile:kPrefsPath atomically:YES];
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
