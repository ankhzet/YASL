//
//  YASLAssemblerSpec.m
//  YASL
//  Spec for YASLAssembler
//
//  Created by Ankh on 02.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Kiwi.h"
#import "YASLBasicAssembler.h"

SPEC_BEGIN(YASLAssemblerSpec)

describe(@"YASLAssembler", ^{

	it(@"should properly initialize", ^{
		YASLAssembler *instance = [YASLAssembler new];
		[[instance shouldNot] beNil];
		[[instance should] beKindOfClass:[YASLAssembler class]];
	});

	it(@"should assemble script definition", ^{
		NSString *source = @"script test;";

		YASLAssembler *assembler = [YASLAssembler new];

		YASLTranslationUnit *result = [assembler assembleSource:source];
		[[result shouldNot] beNil];
		[[result should] beKindOfClass:[YASLTranslationUnit class]];
		[[result.name should] equal:@"test"];
	});


});

SPEC_END
