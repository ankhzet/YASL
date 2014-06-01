//
//  YASLTranslationUnit.m
//  YASL
//
//  Created by Ankh on 28.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTranslationUnit.h"
#import "YASLCoreLangClasses.h"

@implementation YASLTranslationUnit

+ (instancetype) unitInScope:(YASLDeclarationScope *)scope withName:(NSString *)name {
	YASLTranslationUnit *unit = [YASLTranslationUnit nodeInScope:scope withType:YASLTranslationNodeTypeRoot];
	unit.name = name;
	return unit;
}

- (NSString *) toString {
	return [NSString stringWithFormat:@"[unit %@]", self.name];
}

@end
