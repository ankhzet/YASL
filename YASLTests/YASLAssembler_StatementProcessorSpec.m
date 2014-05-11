//
//  YASLAssembler_StatementProcessorSpec.m
//  YASL
//  Spec for YASLAssembler+StatementProcessor
//
//  Created by Ankh on 04.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Kiwi.h"
#import "YASLBasicAssembler.h"

SPEC_BEGIN(YASLAssembler_StatementProcessorSpec)

describe(@"YASLAssembler+StatementProcessor", ^{
	it(@"should assemble statements", ^{
		NSString *source1 = @"script test;\r\
		int i = 0;\r\
		int j = 1, k, l = 10;\r\
		{\r\
			float m = 20, n = 40;\r\
			int j = 50;\r\
			k = 60;\r\
			j = 20 + 30;\r\
			l = k - j * (m + 1 - (60 % 11));\r\
			n++;\r\
			k +=  k > j ? 1 : m * n;\r\
			l = ++j * m;\r\
		}\r\
		";

//		NSString *source2 = @"script test;\
//		";
//
//		NSString *source3 = @"script test;\
//		";
//
//		NSString *source4 = @"script test;\
//		";
//
//		NSString *source5 = @"script test;\
//		";
//
//		NSString *source6 = @"script test;\
//		";

		YASLDataTypesManager *typeManager = [YASLDataTypesManager new];
		[typeManager registerType:[YASLBuiltInTypeIntInstance new]];
		[typeManager registerType:[YASLBuiltInTypeFloatInstance new]];
		[typeManager registerType:[YASLBuiltInTypeBoolInstance new]];
		[typeManager registerType:[YASLBuiltInTypeCharInstance new]];
		YASLLocalDeclarations *globalDeclarationScope = [YASLLocalDeclarations declarationsManagerWithDataTypesManager:typeManager];

		YASLAssembler *assembler = [YASLAssembler new];
		[assembler setDeclarationScope:globalDeclarationScope];

		YASLTranslationUnit *result1 = [assembler assembleSource:source1];
//		YASLTranslationUnit *result2 = [assembler assembleSource:source2];
//		YASLTranslationUnit *result3 = [assembler assembleSource:source3];
//		YASLTranslationUnit *result4 = [assembler assembleSource:source4];
//		YASLTranslationUnit *result5 = [assembler assembleSource:source5];
//		YASLTranslationUnit *result6 = [assembler assembleSource:source6];
		[[result1 shouldNot] beNil];
//		[[result2 shouldNot] beNil];
//		[[result3 shouldNot] beNil];
//		[[result4 shouldNot] beNil];
//		[[result5 shouldNot] beNil];
//		[[result6 shouldNot] beNil];
	});
});

SPEC_END
