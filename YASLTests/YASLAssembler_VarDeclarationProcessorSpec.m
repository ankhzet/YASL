//
//  YASLAssembler_VarDeclarationProcessorSpec.m
//  YASL
//  Spec for YASLAssembler+VarDeclarationProcessor
//
//  Created by Ankh on 03.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Kiwi.h"
#import "YASLbasicAssembler.h"

SPEC_BEGIN(YASLAssembler_VarDeclarationProcessorSpec)

describe(@"YASLAssembler+VarDeclarationProcessor", ^{
	it(@"should properly initialize", ^{
		YASLAssembler *instance = [YASLAssembler new];
		[[instance shouldNot] beNil];
		[[instance should] beKindOfClass:[YASLAssembler class]];
	});

	it(@"should assemble variable declarations", ^{
		NSString *source1 = @"script test;\
		int myIntVar;\
		";

		NSString *source2 = @"script test;\
		typedef int myIntType;\
		myIntType myIntVar2;\
		";

		NSString *source3 = @"script test;\
		int i = 0;\
		";

		NSString *source4 = @"script test;\
		int i2 = 10;\
		";

		NSString *source5 = @"script test;\
		myIntType i3, i4 = 250, i5;\
		";

		NSString *source6 = @"script test;\
		int myIntArray[] = {0, 1, 2};\
		";

		YASLDataTypesManager *typeManager = [YASLDataTypesManager new];
		[typeManager registerType:[YASLBuiltInTypeIntInstance new]];
		YASLLocalDeclarations *globalDeclarationScope = [YASLLocalDeclarations declarationsManagerWithDataTypesManager:typeManager];

		YASLAssembler *assembler = [YASLAssembler new];
		[assembler setDeclarationScope:globalDeclarationScope];

		YASLTranslationUnit *result3 = [assembler assembleSource:source3];
		YASLTranslationUnit *result1 = [assembler assembleSource:source1];
		YASLTranslationUnit *result2 = [assembler assembleSource:source2];
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
