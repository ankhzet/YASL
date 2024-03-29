//
//  YASLTranslationExpression.h
//  YASL
//
//  Created by Ankh on 03.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTranslationNode.h"
#import "YASLCodeCommons.h"

typedef NS_ENUM(NSUInteger, YASLExpressionType) {
	YASLExpressionTypeMin = 0,
	YASLExpressionTypeUnary,
	YASLExpressionTypeBinary,
	YASLExpressionTypeTernar,

	YASLExpressionTypeTypecast,
	YASLExpressionTypeSizeOf,

	YASLExpressionTypeVariable,
	YASLExpressionTypeConstant,
	YASLExpressionTypeString,

	YASLExpressionTypeArray,
	YASLExpressionTypeCall,
	YASLExpressionTypeProperty,
	YASLExpressionTypeStructure,
	YASLExpressionTypeAssignment,
	YASLExpressionTypeIterational,
	YASLExpressionTypeSwitch,
	YASLExpressionTypeUnreference,

	YASLExpressionTypeJump,
	YASLExpressionTypeReturn,

	YASLExpressionTypeDesignatedInitializer,

};

typedef NS_ENUM(NSUInteger, YASLExpressionOperator) {
	YASLExpressionOperatorUnknown = 0,
	YASLExpressionOperatorAdd,
	YASLExpressionOperatorSub,
	YASLExpressionOperatorMul,
	YASLExpressionOperatorDiv,
	YASLExpressionOperatorRest,

	YASLExpressionOperatorIncrement,
	YASLExpressionOperatorDecrement,

	YASLExpressionOperatorInclusiveOr,
	YASLExpressionOperatorExclusiveOr,
	YASLExpressionOperatorLogicOr,
	YASLExpressionOperatorLogicAnd,
	YASLExpressionOperatorInclusiveAnd,

	YASLExpressionOperatorGreater,
	YASLExpressionOperatorGreaterEqual,
	YASLExpressionOperatorLess,
	YASLExpressionOperatorLessEqual,
	YASLExpressionOperatorNotEqual,
	YASLExpressionOperatorEqual,

	YASLExpressionOperatorSHL,
	YASLExpressionOperatorSHR,

	YASLExpressionOperatorInv,
	YASLExpressionOperatorNot,
	YASLExpressionOperatorRef,
	YASLExpressionOperatorUnref,

	YASLExpressionOperatorMAX
};

@class YASLDataType, YASLExpressionSolver;
@interface YASLTranslationExpression : YASLTranslationNode

@property (nonatomic) YASLExpressionType expressionType;
@property (nonatomic) NSString *specifier;
@property (nonatomic) YASLDataType *returnType;
@property (nonatomic) BOOL isUnary;

+ (instancetype) expressionInScope:(YASLDeclarationScope *)scope withType:(YASLExpressionType)type andSpecifier:(NSString *)specifier;
+ (instancetype) expressionInScope:(YASLDeclarationScope *)scope withType:(YASLExpressionType)type;

- (YASLTranslationExpression *) foldConstantExpressionWithSolver:(YASLExpressionSolver *)solver;

+ (YASLExpressionOperator) specifierToOperator:(NSString *)specifier unary:(BOOL)unary;
+ (NSString *) operatorToSpecifier:(YASLExpressionOperator)operator;
- (YASLExpressionOperator) expressionOperator;

+ (BOOL) checkFolding:(YASLTranslationExpression **)operand withSolver:(YASLExpressionSolver *)solver;

@end

@interface YASLTranslationExpression (Assembling)

+ (YASLOpcodes) operationToOpcode:(YASLExpressionOperator)operator typed:(YASLBuiltInType)type;

@end
