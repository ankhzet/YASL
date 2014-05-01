//
//  YASLIdentifierNode.m
//  YASL
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLIdentifierNode.h"
#import "YASLCompositeNode.h"
#import "YASLToken.h"
#import "YASLAssembly.h"

@implementation YASLIdentifierNode

- (NSString *) description {
	if (self.link && [self.link isKindOfClass:[YASLCompositeNode class]]) {
		YASLCompositeNode *compositeLink = (id)self.link;
		if (![compositeLink hasChild:self])
			return [NSString stringWithFormat:@"('%@' \n -> %@\n)", self.identifier, self.link];
	}

	return [NSString stringWithFormat:@"%@", self.identifier];
}

- (BOOL) matches:(YASLAssembly *)match for:(YASLAssembly *)assembly {
	if (!self.link) {
		YASLToken *token = [match pop];
		return token.kind == YASLTokenKindIdentifier;
	}

	return [self.link match:match andAssembly:assembly];
}

@end
