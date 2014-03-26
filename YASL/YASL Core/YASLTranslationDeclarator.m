//
//  YASLTranslationDeclarator.m
//  YASL
//
//  Created by Ankh on 03.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTranslationDeclarator.h"
#import "YASLCoreLangClasses.h"

@implementation YASLDeclaratorSpecifier

+ (instancetype) specifierWithType:(YASLTranslationNodeType)type param:(NSInteger)param andElems:(NSArray *)elems {
	YASLDeclaratorSpecifier *specifier = [self new];
	specifier.type = type;
	specifier.param = param;
	specifier.elements = elems;
	return specifier;
}

- (NSString *) description {
	switch (self.type) {
		case YASLTranslationNodeTypeArrayDeclarator:
			return [NSString stringWithFormat:@"[%lu] = {%@}", self.param, [self.elements componentsJoinedByString:@", "]];
			break;

		case YASLTranslationNodeTypeFunction:
			return [NSString stringWithFormat:@"(%@)", [self.elements componentsJoinedByString:@", "]];
			break;

		default:
			break;
	}
	return @"<unknown declarator specifier>";
}

@end

@implementation YASLTranslationDeclarator

- (YASLDataType *) declareSpecific:(YASLTranslationExpression *)variable withDataType:(YASLDataType *)declarationDataType inScope:(YASLLocalDeclarations *)scope {

	NSUInteger pointer = self.isPointer;
	while (pointer-- > 0) {
		YASLDataType *pointerType = [YASLDataType typeWithName:@""];
		pointerType.parent = declarationDataType;
		pointerType.isPointer = 1;
		declarationDataType = pointerType;
	}

	variable.returnType = declarationDataType;

	if (![_declaratorSpecifiers notEmpty])
		return declarationDataType;

	YASLAssembly *specifiers = [_declaratorSpecifiers copy];
	while ([specifiers notEmpty]) {
		YASLDeclaratorSpecifier *specifier = [specifiers pop];
		switch (specifier.type) {
			case YASLTranslationNodeTypeArrayDeclarator: {
				NSUInteger count = specifier.param;
				NSArray *elements = specifier.elements;
				YASLArrayDataType *arrayDataType = [YASLArrayDataType typeWithName:@""];
				arrayDataType.parent = declarationDataType;
				arrayDataType.elements = count;
				declarationDataType = arrayDataType;
				variable.returnType = declarationDataType;
				if ([elements count]) {
					YASLDataType *indexDataType = [scope.globalTypesManager typeByName:YASLBuiltInTypeIdentifierInt];
					YASLCompoundExpression *elementInits = [YASLCompoundExpression compoundExpressionInScope:scope.currentScope];

					NSUInteger index = 0;
					for (YASLTranslationExpression *initializer in elements) {
						YASLArrayElementExpression *arrayElement = [YASLArrayElementExpression arrayElementInScope:scope.currentScope];
						YASLTranslationConstant *elementIndex = [YASLTranslationConstant constantInScope:scope.currentScope withType:indexDataType andValue:@(index++)];
						[arrayElement addSubNode:variable];
						[arrayElement addSubNode:elementIndex];

						YASLTranslationExpression *expression = [initializer nthOperand:0];
						[initializer setNth:0 operand:arrayElement];
						[initializer setNth:1 operand:expression];
						YASLTranslationExpression *folded = [initializer foldConstantExpressionWithSolver:scope.expressionSolver];
						[elementInits addSubNode:folded];
					}
					[self setSubNodes:@[elementInits]];
				}
				break;
			}
			case YASLTranslationNodeTypeFunction:
				//						[self raiseError:@"Function declarator implementation"];
				break;

			default:
				[self raiseError:@"Unknown declarator type: \"%u\"", specifier.type];
				break;
		}
	}

	return declarationDataType;
}

- (NSString *) toString {
	NSString *pointer = [@"" stringByPaddingToLength:self.isPointer withString:@"*" startingAtIndex:0];
	NSString *specifiers = self.declaratorSpecifiers ? [self.declaratorSpecifiers stackToString] : @"";
	return [NSString stringWithFormat:@"(D:%@%@%@%@)", pointer, self.declaratorIdentifier, specifiers, [[[self nodesEnumerator:NO] allObjects] componentsJoinedByString:@" "]];
}

- (void) addSpecifier:(YASLDeclaratorSpecifier *)specifier {
	if (!self.declaratorSpecifiers)
		self.declaratorSpecifiers = [YASLAssembly new];

	[self.declaratorSpecifiers push:specifier];
	self.type = specifier.type;
}

@end
