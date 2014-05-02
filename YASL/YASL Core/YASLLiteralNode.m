//
//  YASLLiteralNode.m
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLLiteralNode.h"
#import "YASLToken.h"
#import "YASLAssembly.h"

@implementation YASLLiteralNode

- (NSString *) description {
	return [NSString stringWithFormat:@"'%@'%@", self.literal, self.discard ? @"!" : @""];
}

- (BOOL) matches:(YASLAssembly *)match for:(YASLAssembly *)assembly {
	YASLToken *token = (!self.discard) ? [match pop] : [match top];
	return [token.value isEqualToString:self.literal];
}

@end
