//
//  YASLAnyNode.m
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLAnyNode.h"
#import "YASLAssembly.h"

@implementation YASLAnyNode


- (NSString *) description {
	return @"Any";
}

- (BOOL) matches:(YASLAssembly *)match for:(YASLAssembly *)assembly {
	[match pop];
	return YES;
}

@end
