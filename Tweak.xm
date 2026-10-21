#import <Foundation/Foundation.h>
#import <objc/message.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <os/lock.h>

// ===== 偏好 =====
#define PREFS_DOMAIN  "com.yourname.grab"
#define PREFS_NOTIFY  "com.yourname.grab.prefs.changed"

static BOOL   gEnabled  = YES;
static BOOL   gPushOnly = YES;
static double gMinYuan  = 20.0;
static double gMaxKm    = 5.0;
static double gMinCoin  = 0.0;

static NSMutableDictionary<NSString *, NSNumber *> *gPushIds = nil;
static os_unfair_lock gLockObj = OS_UNFAIR_LOCK_INIT;
static BOOL gGrabbing = NO;
static const int kPushTTL = 300;

static inline void L(NSString *fmt, ...) {
    va_list ap; va_start(ap, fmt);
    NSString *s = [[NSString alloc] initWithFormat:fmt arguments:ap];
    va_end(ap);
    NSLog(@"[grab] %@", s);
}

static NSString *PrefsPath(void) {
    return [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%s.plist", PREFS_DOMAIN];
}

static void ReloadPrefs(void) {
    NSDictionary *d = [NSDictionary dictionaryWithContentsOfFile:PrefsPath()];
    if (d) {
        if (d[@"enabled"])  gEnabled  = [d[@"enabled"]  boolValue];
        if (d[@"pushOnly"]) gPushOnly = [d[@"pushOnly"] boolValue];
        if (d[@"minYuan"])  gMinYuan  = [d[@"minYuan"]  doubleValue];
        if (d[@"maxKm"])    gMaxKm    = [d[@"maxKm"]    doubleValue];
        if (d[@"minCoin"])  gMinCoin  = [d[@"minCoin"]  doubleValue];
    }
    L(@"配置 enabled=%d pushOnly=%d minYuan=%.1f maxKm=%.1f minCoin=%.1f",
      gEnabled, gPushOnly, gMinYuan, gMaxKm, gMinCoin);
}

static void PrefsChangedCB(CFNotificationCenterRef c, void *o,
                           CFStringRef n, const void *obj, CFDictionaryRef info) {
    ReloadPrefs();
}

// ================= 绝对防闪退的初始化 =================
%ctor {
    // 如果当前进程是设置 App，直接终止初始化，彻底杜绝设置界面闪退！
    NSString *processName = [[NSProcessInfo processInfo] processName];
    if ([processName isEqualToString:@"Preferences"]) {
        return;
    }
    
    @try {
        ReloadPrefs();
        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(), NULL,
            PrefsChangedCB, CFSTR(PREFS_NOTIFY), NULL,
            CFNotificationSuspensionBehaviorDeliverImmediately);
    } @catch (__unused NSException *e) {}
}

// ===== 安全取值 =====
static id SafeValue(id obj, NSString *key) {
    if (!obj || !key) return nil;
    @try {
        SEL sel = NSSelectorFromString(key);
        if ([obj respondsToSelector:sel]) {
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            return [obj performSelector:sel];
            #pragma clang diagnostic pop
        }
        return [obj valueForKey:key];
    } @catch (__unused NSException *e) { return nil; }
}

static void PrunePushIds(void) {
    @synchronized (gPushIds) {
        if (!gPushIds) return;
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
        NSMutableArray *drop = [NSMutableArray array];
        for (NSString *k in gPushIds) {
            if (now - gPushIds[k].doubleValue > kPushTTL) [drop addObject:k];
        }
        if (drop.count) [gPushIds removeObjectsForKeys:drop];
    }
}

// ===== 抢单 =====
static void DoGrab(id order, NSString *freightNo) {
    Class P = objc_getClass("HLLOrderPickupPresenter");
    if (!P) { L(@"找不到 HLLOrderPickupPresenter"); return; }

    SEL initSel = sel_registerName("initWithOrder:");
    if (![P instancesRespondToSelector:initSel]) { L(@"Presenter 无 initWithOrder:"); return; }
    id presenter = ((id (*)(id, SEL, id))objc_msgSend)([P alloc], initSel, order);
    if (!presenter) { L(@"presenter init 失败"); return; }

    SEL sel = sel_registerName("startSignPickup:success:failed:");
    if (![presenter respondsToSelector:sel]) { L(@"Presenter 无 startSignPickup"); return; }

    __block BOOL done = NO;
    void (^ok)(id) = ^(id resp) {
        if (done) return; done = YES;
        os_unfair_lock_lock(&gLockObj); gGrabbing = NO; os_unfair_lock_unlock(&gLockObj);
        L(@"抢单成功 %@ resp=%@", freightNo, resp);
    };
    void (^fail)(id err) = ^(id err) {
        if (done) return; done = YES;
        os_unfair_lock_lock(&gLockObj); gGrabbing = NO; os_unfair_lock_unlock(&gLockObj);
        L(@"抢单失败 %@ err=%@", freightNo, err);
    };

    L(@"发起抢单 %@", freightNo);
    ((void (*)(id, SEL, id, id, id))objc_msgSend)(presenter, sel, order, [ok copy], [fail copy]);
}

// ===== Hooks =====
%hook HLLHallOrderProvider

- (void)orderNewBatchPushTask:(id)task {
    %orig;
    @try {
        id params = SafeValue(task, @"params");
        id data   = SafeValue(params, @"data");
        id fre    = SafeValue(data, @"freight_no");
        if (fre) {
            NSString *key = [fre description];
            @synchronized (gPushIds ?: (gPushIds = [NSMutableDictionary new])) {
                gPushIds[key] = @([[NSDate date] timeIntervalSince1970]);
            }
            PrunePushIds();
            L(@"收到推送 %@", key);
        } else {
            L(@"推送解析失败 task=%@", task);
        }
    } @catch (NSException *e) { L(@"push 异常 %@", e); }
}

- (id)convertOrderModelsWithJson:(id)json {
    id ret = %orig;
    @try {
        if (![ret isKindOfClass:[NSArray class]]) {
            L(@"返回值不是 NSArray: %@", [ret class]);
            return ret;
        }
        for (id o in (NSArray *)ret) {
            @autoreleasepool {
                id freObj = SafeValue(o, @"freight_no");
                if (!freObj) continue;
                NSString *fre = [freObj description];

                double yuan = [SafeValue(o, @"total_fee_fen") doubleValue] / 100.0;
                double km   = [SafeValue(o, @"navigation_value") doubleValue] / 1000.0;
                double coin = [SafeValue(o, @"coin") doubleValue];

                BOOL isPush = NO;
                @synchronized (gPushIds) { isPush = (gPushIds && gPushIds[fre] != nil); }

                BOOL hit = gEnabled
                        && yuan >= gMinYuan
                        && km   <= gMaxKm
                        && coin >= gMinCoin
                        && (!gPushOnly || isPush);

                L(@"单号:%@ 金额:%.2f 距离:%.2fkm 金币:%.0f push=%d hit=%d",
                  fre, yuan, km, coin, isPush, hit);

                if (hit) {
                    os_unfair_lock_lock(&gLockObj);
                    BOOL can = !gGrabbing; if (can) gGrabbing = YES;
                    os_unfair_lock_unlock(&gLockObj);

                    if (can) {
                        @synchronized (gPushIds) { [gPushIds removeObjectForKey:fre]; }
                        DoGrab(o, fre);
                    } else {
                        L(@"已有抢单进行中，跳过 %@", fre);
                    }
                }
            }
        }
    } @catch (NSException *e) { L(@"convert 异常 %@", e); }
    return ret;
}

%end
