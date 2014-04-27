//
//  YASLEvent.m
//  YASL
//
//  Created by Ankh on 26.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLEvent.h"
#import "YASLEventsAPI.h"

@implementation YASLEvent

+ (instancetype) eventWithEventManager:(YASLEventsAPI *)manager {
	return [[self alloc] initWithEventManager:manager];
}

- (id)initWithEventManager:(YASLEventsAPI *)manager {
	if (!(self = [super init]))
		return self;

	_manager = manager;
	return self;
}

- (void) close {
	[_manager closeEvent:self.handle];
}

@end
