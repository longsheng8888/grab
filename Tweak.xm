#import <Foundation/Foundation.h>
#import <objc/message.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

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
    id presenter = ((id (*)(id, SEL, id))objc_msgSend)(
        [P alloc], sel_registerName("initWithOrder:"), order);
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
        ((void (*)(id, SEL, id, id, id))objc_msgSend)(
            presenter, sel, nil, blockRef, blockRef);
        NSLog(@"[grab] 已发起抢单 %@", freightNo);
    } else {
        NSLog(@"[grab] presenter 无 startSignPickup");
    }
}

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
    } @catch (NSException *e) {
        NSLog(@"[grab] push err %@", e);
    }
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

            double fen  = [SafeValue(o, @"total_fee_fen") doubleValue];
            double yuan = fen / 100.0;
            double meter = [SafeValue(o, @"navigation_value") doubleValue];
            double km = meter / 1000.0;

            BOOL isPush = (gPushIds && [gPushIds containsObject:fre]);
            BOOL hit = (yuan >= GetMinFee() && km <= GetMaxDist());

            NSLog(@"[grab] %@%@ %@ | %.2f元 | %.2fkm",
                  isPush ? @"[推送单]" : @"        ",
                  hit ? @"【达标】" : @"      ",
                  fre, yuan, km);

            if (isPush && hit && gLock < 1) {
                gLock = 1;
                NSLog(@"[grab] ★★★ 抢单 %@", fre);
                DoGrab(o, fre);
            }
        }
    } @catch (NSException *e) {
        NSLog(@"[grab] convert err %@", e);
    }
    return ret;
}

%end
