//
//  YASLEvent.m
//  YASL
//
//  Created by Ankh on 26.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLEvent.h"

@implementation YASLEvent

+ (instancetype) eventWithEventManager:(id<YASLEventManagerDelegate>)manager {
	return [[self alloc] initWithEventManager:manager];
}

- (id)initWithEventManager:(id<YASLEventManagerDelegate>)manager {
	if (!(self = [super init]))
		return self;

	_manager = manager;
	return self;
}

- (void) close {
	[_manager closeEvent:self.handle];
}

@end
