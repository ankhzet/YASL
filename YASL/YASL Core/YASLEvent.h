//
//  YASLEvent.h
//  YASL
//
//  Created by Ankh on 26.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YASLCodeCommons.h"

typedef NS_ENUM(YASLInt, YASLEventState) {
	YASLEventStateClear  = 0,
	YASLEventStateSet    = 1,
	YASLEventStateFailed = 2,
	YASLEventStateTimeout= 3,
};

@class YASLEventsAPI;
@interface YASLEvent : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) YASLInt handle;
@property (nonatomic, weak, readonly) YASLEventsAPI *manager;

@property (nonatomic) YASLInt state;
@property (nonatomic) BOOL autoreset;

@property (nonatomic) NSUInteger links;

+ (instancetype) eventWithEventManager:(YASLEventsAPI *)manager;

- (void) close;

@end
