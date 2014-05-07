//
//  YASLTokenizerSpec.m
//  YASL
//  Spec for YASLTokenizer
//
//  Created by Ankh on 29.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Kiwi.h"
#import "YASLTokenizer.h"

SPEC_BEGIN(YASLTokenizerSpec)

describe(@"YASLTokenizer", ^{
	it(@"should properly initialize", ^{
		YASLTokenizer *instance = [YASLTokenizer new];
		[[instance shouldNot] beNil];
		[[instance should] beKindOfClass:[YASLTokenizer class]];
	});

	it(@"should parse integers & floats", ^{
		NSString *source = @"1 123 123.456 123. .456";
		YASLTokenizer *tokenizer = [[YASLTokenizer alloc] initWithSource:source];

		NSArray *tokens = [tokenizer tokenizeAll];

		[[tokens shouldNot] beNil];
		[[tokens should] haveCountOf:6];
	});

	it(@"should parse identifiers", ^{
		NSString *source = @"a a_ _ _a a_b 9 _9 _a9 _9a a9 a.9 a9. 9a";
		YASLTokenizer *tokenizer = [[YASLTokenizer alloc] initWithSource:source];

		NSArray *tokens = [tokenizer tokenizeAll];

		[[tokens shouldNot] beNil];
		[[tokens should] haveCountOf:17];
	});

	it(@"should parse strings", ^{
		NSString *source = @"sa sdas 'asdas' sadsa \" asd asdas das 'sdasdasdsadsa\" 'asdadasd\"asdasd' ad";
		YASLTokenizer *tokenizer = [[YASLTokenizer alloc] initWithSource:source];

		NSArray *tokens = [tokenizer toValueArray:[tokenizer tokenizeAll]];

		[[tokens shouldNot] beNil];
		[[tokens should] haveCountOf:7];
		[[tokens should] equal:@[@"sa", @"sdas", @"asdas", @"sadsa", @" asd asdas das 'sdasdasdsadsa", @"asdadasd\"asdasd", @"ad"]];
	});

	it(@"should parse booleans", ^{
		NSString *source = @"tru true fal false";
		YASLTokenizer *tokenizer = [[YASLTokenizer alloc] initWithSource:source];

		NSArray *tokens = [tokenizer tokenizeAll];

		[[tokens shouldNot] beNil];
		[[tokens should] haveCountOf:4];
		[[theValue(((YASLToken *)tokens[1]).kind) should] equal:theValue(YASLTokenKindBool)];
		[[theValue([((YASLToken *)tokens[1]) asBool]) should] beYes];
		[[theValue(((YASLToken *)tokens[3]).kind) should] equal:theValue(YASLTokenKindBool)];
		[[theValue([((YASLToken *)tokens[3]) asBool]) should] beNo];
	});

	it(@"should parse comments", ^{
		NSString *source = @"\
		ab cd /*ef g*/h\n\
		// abcdefg/*h\n\
		abcdefg\n\
		abcd*/e /*f\n\
		asdasda*/bcd\n\
		abc/**/defgh\n\
		";
		YASLTokenizer *tokenizer = [[YASLTokenizer alloc] initWithSource:source];

		NSArray *tokens = [tokenizer toValueArray:[tokenizer tokenizeAll]];

		[[tokens shouldNot] beNil];
		[[tokens should] haveCountOf:11];
	});

	it(@"should parse symbols", ^{
		NSString *source1 = @"\
		a = b + c - d * e ++ f -- g == h != i >= j <= k << l >> m & n && o | p || q ^ r < s > t % u / w ( x ) y [ z ]\
		";
		NSString *source2 = @"=+-*++--==!=>=<=<<>>&&&|||^<>%/()[]";

		YASLTokenizer *tokenizer = [[YASLTokenizer alloc] initWithSource:source1];
		NSArray *tokens1 = [tokenizer toValueArray:[tokenizer tokenizeAll]];
		tokenizer.source = source2;
		NSArray *tokens2 = [tokenizer toValueArray:[tokenizer tokenizeAll]];

		[[tokens1 shouldNot] beNil];
		[[tokens1 should] haveCountOf:50];
		[[tokens1 should] equal:
		 @[
			 @"a", @"=", @"b", @"+", @"c", @"-", @"d", @"*", @"e", @"++", @"f", @"--", @"g",
			 @"==", @"h", @"!=", @"i", @">=", @"j", @"<=", @"k", @"<<", @"l", @">>", @"m",
			 @"&", @"n", @"&&", @"o", @"|", @"p", @"||", @"q", @"^", @"r", @"<", @"s", @">",
			 @"t", @"%", @"u", @"/", @"w", @"(", @"x", @")", @"y", @"[", @"z", @"]",
			 ]];

		[[tokens2 shouldNot] beNil];
		[[tokens2 should] haveCountOf:25];
		[[tokens2 should] equal:
		 @[
			 @"=", @"+", @"-", @"*", @"++", @"--", @"==", @"!=", @">=", @"<=", @"<<", @">>",
			 @"&&", @"&", @"||", @"|", @"^", @"<", @">", @"%", @"/", @"(", @")", @"[", @"]",
			 ]];

	});
});

SPEC_END
