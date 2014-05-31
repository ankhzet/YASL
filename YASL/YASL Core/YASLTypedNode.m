//
//  YASLTypedNode.m
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTypedNode.h"
#import "YASLAssembly.h"

@implementation YASLTypedNode

- (id) initWithType:(YASLTokenKind)type {
	if (!(self = [self init]))
		return self;

	self.type = type;
	return self;
}

- (NSString *) unsafeDescription:(NSMutableSet *)circular {
	return [NSString stringWithFormat:@"{%@}", [YASLToken tokenKindName:self.type]];
}

- (BOOL) matches:(YASLAssembly *)match for:(YASLAssembly *)assembly {
	YASLToken *token = [match pop];
	return token.kind == self.type;
}

- (YASLNonfatalException *) exceptionOnToken:(YASLToken *)token inAssembly:(YASLAssembly *)assembly {
	YASLNonfatalException *exception = [YASLNonfatalException exceptionWithMsg:@"%@ expected, %@ found", [YASLToken tokenKindName:self.type], [YASLToken tokenKindName:token.kind]];
	[assembly pushException:exception];
	return exception;
}

@end
