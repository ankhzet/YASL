//
//  YASLExpressionSolverSpec.m
//  YASL
//  Spec for YASLExpressionSolver
//
//  Created by Ankh on 08.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Kiwi.h"
#import "YASLExpressionSolver.h"
#import "YASLLocalDeclarations.h"
#import "YASLCoreLangClasses.h"

SPEC_BEGIN(YASLExpressionSolverSpec)

describe(@"YASLExpressionSolver", ^{
	it(@"should load productions matrix", ^{
		YASLDataTypesManager *typeManager = [YASLDataTypesManager datatypesManagerWithParentManager:nil];
		[typeManager registerType:[YASLBuiltInTypeIntInstance new]];
		[typeManager registerType:[YASLBuiltInTypeFloatInstance new]];
		[typeManager registerType:[YASLBuiltInTypeBoolInstance new]];
		[typeManager registerType:[YASLBuiltInTypeCharInstance new]];
		YASLLocalDeclarations *scope = [YASLLocalDeclarations declarationsManagerWithDataTypesManager:typeManager];

		YASLExpressionSolver *solver = [YASLExpressionSolver solverInDeclarationScope:scope];
		[[solver shouldNot] beNil];
		[[solver should] beKindOfClass:[YASLExpressionSolver class]];

	});
});

SPEC_END
