//
//  YASLTranslationUnit.m
//  YASL
//
//  Created by Ankh on 28.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTranslationUnit.h"

@implementation YASLTranslationUnit

- (id)init {
	if (!(self = [super init]))
		return self;

	_labels = [NSMutableDictionary dictionary];
	return self;
}

@end
