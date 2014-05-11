//
//  YASLOperationProductionsAssemblerSpec.m
//  YASL
//  Spec for YASLOperationProductionsAssembler
//
//  Created by Ankh on 08.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Kiwi.h"
#import "YASLOperationProductionsAssembler.h"

SPEC_BEGIN(YASLOperationProductionsAssemblerSpec)

describe(@"YASLOperationProductionsAssembler", ^{
	it(@"should properly initialize", ^{
		YASLOperationProductionsAssembler *instance = [YASLOperationProductionsAssembler new];
		[[instance shouldNot] beNil];
		[[instance should] beKindOfClass:[YASLOperationProductionsAssembler class]];
	});

	it(@"should ", ^{
		NSString *source = @"\r\
		 [*, /, %] {\r\
			 [int] {\r\
				 [int, char, bool]: int,\r\
				 [float]: float,\r\
			 }\r\
			 [float] {\r\
				 [int, float]: float,\r\
			 }\r\
			 [bool] [*] {\r\
				 [int]: int,\r\
				 [float]: float,\r\
				 [char]: char,\r\
			 }\r\
			 [char] {\r\
				 [int]: int,\r\
			 }\r\
		 }\r\
		 [<<, >>] {\r\
			 [int] {\r\
				 [int, char, bool]: int,\r\
			 }\r\
			 [bool] {\r\
				 [int]: int,\r\
			 }\r\
			 [char] {\r\
				 [int]: int,\r\
			 }\r\
		 }\r\
		";

		YASLOperationProductionsAssembler *assembler = [YASLOperationProductionsAssembler new];

		NSArray *result = [assembler assembleSource:source];
		[[result shouldNot] beNil];
		[[result should] beKindOfClass:[NSArray class]];
		[[result should] haveCountOf:2];

	});
});

SPEC_END
