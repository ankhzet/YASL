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

- (NSString *) nodeType {
	return [NSString stringWithFormat:@"%@:%@", [super nodeType], [self description]];
}

- (NSString *) unsafeDescription:(NSMutableSet *)circular {
	return [NSString stringWithFormat:@"'%@'", self.literal];
}

- (BOOL) matches:(YASLAssembly *)match for:(YASLAssembly *)assembly {
	YASLToken *token = [match pop];
	return [token.value isEqualToString:self.literal];
}

- (YASLNonfatalException *) exceptionOnToken:(YASLToken *)token inAssembly:(YASLAssembly *)assembly {
	YASLNonfatalException *exception = [YASLNonfatalException exceptionWithMsg:@"\"%@\" expected, \"%@\" found", self.literal, token.value];
	[assembly pushException:exception];
	return exception;
}

@end
