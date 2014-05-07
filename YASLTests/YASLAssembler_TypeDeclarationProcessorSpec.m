//
//  YASLAssembler_TypeDeclarationProcessorSpec.m
//  YASL
//  Spec for YASLAssembler+TypeDeclarationProcessor
//
//  Created by Ankh on 03.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Kiwi.h"
#import "YASLBasicAssembler.h"

SPEC_BEGIN(YASLAssembler_TypeDeclarationProcessorSpec)

describe(@"YASLAssembler+TypeDeclarationProcessor", ^{
	it(@"should properly initialize", ^{
		YASLAssembler *instance = [YASLAssembler new];
		[[instance shouldNot] beNil];
		[[instance should] beKindOfClass:[YASLAssembler class]];
	});


	it(@"should assemble type definitions", ^{
		NSString *source1 = @"script test;\
		typedef int myIntType;\
		";

		NSString *source2 = @"script test;\
		typedef myIntType myIntType2;\
		";

		NSString *source3 = @"script test;\
		typedef int myIntArray[];\
		";

		NSString *source4 = @"script test;\
		typedef int myIntArray2[3];\
		";

		YASLDataTypesManager *typeManager = [YASLDataTypesManager new];
		[typeManager registerType:[YASLBuiltInTypeIntInstance new]];
		YASLLocalDeclarations *globalDeclarationScope = [YASLLocalDeclarations declarationsManagerWithDataTypesManager:typeManager];

		YASLAssembler *assembler = [YASLAssembler new];
		[assembler setDeclarationScope:globalDeclarationScope];

		YASLTranslationUnit *result1 = [assembler assembleSource:source1];
		YASLTranslationUnit *result2 = [assembler assembleSource:source2];
		YASLTranslationUnit *result3 = [assembler assembleSource:source3];
		YASLTranslationUnit *result4 = [assembler assembleSource:source4];
		[[result1 shouldNot] beNil];
		[[result2 shouldNot] beNil];
		[[result3 shouldNot] beNil];
		[[result4 shouldNot] beNil];

		YASLDataType *type;
		type = [typeManager typeByName:@"myIntType"];
		[[type shouldNot] beNil];
		[[type.parent should] equal:[typeManager typeByName:@"int"]];

		type = [typeManager typeByName:@"myIntType2"];
		[[type shouldNot] beNil];
		[[type.parent should] equal:[typeManager typeByName:@"myIntType"]];

		type = [typeManager typeByName:@"myIntArray"];
		[[type shouldNot] beNil];
		[[type.parent should] equal:[typeManager typeByName:@"int"]];
		
	});

});

SPEC_END
