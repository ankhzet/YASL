//
//  YASLAssembler_FunctionProcessorSpec.m
//  YASL
//  Spec for YASLAssembler+FunctionProcessor
//
//  Created by Ankh on 09.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Kiwi.h"
#import "YASLBasicAssembler.h"

SPEC_BEGIN(YASLAssembler_FunctionProcessorSpec)

describe(@"YASLAssembler+FunctionProcessor", ^{
	it(@"should assemble statements", ^{
		NSString *source1 = @"script test;\r\
		typedef int myInt;\r\
		int k = 10;\r\
		myInt l = 20;\r\
		int func(int param1, param2; bool param3) {\r\
			int j = param1 + param2;\
			return param3 ? j + k : j + 1;\r\
		}\r\
		";

		YASLDataTypesManager *typeManager = [YASLDataTypesManager new];
		[typeManager registerType:[YASLBuiltInTypeIntInstance new]];
		[typeManager registerType:[YASLBuiltInTypeFloatInstance new]];
		[typeManager registerType:[YASLBuiltInTypeBoolInstance new]];
		[typeManager registerType:[YASLBuiltInTypeCharInstance new]];
		YASLLocalDeclarations *globalDeclarationScope = [YASLLocalDeclarations declarationsManagerWithDataTypesManager:typeManager];

		YASLAssembler *assembler = [YASLAssembler new];
		[assembler setDeclarationScope:globalDeclarationScope];

		YASLTranslationUnit *result1 = [assembler assembleSource:source1];
		[[result1 shouldNot] beNil];
		NSLog(@"%@", result1);
	});
});

SPEC_END
