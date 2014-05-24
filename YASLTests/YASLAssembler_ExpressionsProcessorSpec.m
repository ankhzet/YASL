//
//  YASLAssembler_ExpressionsProcessorSpec.m
//  YASL
//  Spec for YASLAssembler+ExpressionsProcessor
//
//  Created by Ankh on 03.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Kiwi.h"
#import "YASLBasicAssembler.h"

SPEC_BEGIN(YASLAssembler_ExpressionsProcessorSpec)

describe(@"YASLAssembler+ExpressionsProcessor", ^{
	it(@"should assemble expressions", ^{
		NSString *source1 = @"script test;\
		int i1 = 1 + 2 - 3 + 4 - 5 + 6 + 7 - 8 - 9;\
		";

		NSString *source2 = @"script test;\
		int i2 = 1 > 2 ? -2 : -1;\
		";

		NSString *source3 = @"script test;\
		int i3 = 3 & 4 && 5 & (6 && 7 & 8);\
		";

		NSString *source4 = @"script test;\
		int i4 = 1 + 2 * 3 + 4;\
		";

		NSString *source5 = @"script test;\
		int i5 = 2 | 3, i6 = 11 * (12 + 13), i7 = i5 ^ 4;\
		";

		NSString *source6 = @"script test;\
		int array[] = {0, 1 + 2, 2 * 3, 3 + 4 * 5,\
		5 + 6 * 7 >> 1, 1 << 2,\
		2 >= 1, 3 == 5, 5 != 3,\
		3 & 4, 5 | 6, 7 ^ 8, 8 || 9, 9 && 10\
		};\
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
		YASLTranslationUnit *result2 = [assembler assembleSource:source2];
		YASLTranslationUnit *result3 = [assembler assembleSource:source3];
		YASLTranslationUnit *result4 = [assembler assembleSource:source4];
		YASLTranslationUnit *result5 = [assembler assembleSource:source5];
		YASLTranslationUnit *result6 = [assembler assembleSource:source6];
		[[result1 shouldNot] beNil];
		[[result2 shouldNot] beNil];
		[[result3 shouldNot] beNil];
		[[result4 shouldNot] beNil];
		[[result5 shouldNot] beNil];
		[[result6 shouldNot] beNil];
	});
});

SPEC_END
