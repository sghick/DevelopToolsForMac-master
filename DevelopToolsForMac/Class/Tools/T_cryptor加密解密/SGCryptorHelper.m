//
//  SGCryptorHelper.m
//  DevelopToolsForMac
//
//  Created by buding on 15/8/13.
//  Copyright (c) 2015年 com.wp. All rights reserved.
//

#import "SGCryptorHelper.h"
#import "Cryptor.h"
#import "SGConfigManager.h"
#import <Cocoa/Cocoa.h>

@implementation SGCryptorHelper

- (void)execute:(id (^)())setup block:(void (^)(id))block {
    NSString * input = setup();
    if ([input isKindOfClass:[NSString class]]) {
        NSArray *inputs = [input componentsSeparatedByString:@":"];
        if (inputs.count != 2) {
            block(@"格式错误!\n\t格式是:\n\t\tkey:searl");
            return;
        }
        NSString *key = inputs[0];
        NSString *searl = inputs[1];
        NSString *edes = [SGCryptorHelper encodeDESwithKey:key searl:searl];
        NSString *result = [NSString stringWithFormat:@"%@\n%@:%@\n%@", [NSDate date], key, searl , edes];
        NSLog(@"%@", result);
        SGConfigManager * manager = [SGConfigManager defaultConfigManager];
        if (manager.curConfig.outputType.intValue == 1 && manager.curConfig.outputString && manager.curConfig.outputString.length) {
            [result writeToFile:manager.curConfig.outputString atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
        // 复制到剪切版
//        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
//        [pasteboard setString:edes forType:NSPasteboardTypeString];
//        NSAlert *alert = [[NSAlert alloc] init];
//        alert.messageText = @"已经复制到剪切板";
//        [alert addButtonWithTitle:@"确定"];
//        [alert beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSModalResponse returnCode) {
//        }];
        block(edes);
    }
}

+ (NSString *)encodeDESwithKey:(NSString *)key searl:(NSString *)searl {
    NSMutableString *rtn = [NSMutableString string];
    NSString *str = [Cryptor encodeDES:searl key:key];
    const char *chars = [str cStringUsingEncoding:NSUTF8StringEncoding];
    [rtn appendString:[NSString stringWithCString:chars encoding:NSUTF8StringEncoding]];
    [rtn appendString:@"\n"];
    for (int i = 0; i < strlen(chars); i++) {
        [rtn appendFormat:@"%d,\n", chars[i]];
    }
    return [rtn copy];
}

@end
