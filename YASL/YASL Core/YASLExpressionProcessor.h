//
//  YASLExpressionProcessor.h
//  YASL
//
//  Created by Ankh on 05.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YASLTranslationExpression.h"

#define PREFIX_OPERATION(_symbolic, _right) (_symbolic right)
#define POSTFIX_OPERATION(_left, _symbolic) (left _symbolic)
#define BINARY_OPERATION(_left, _right, _symbolic) PREFIX_OPERATION(POSTFIX_OPERATION(_left, _symbolic), _right)

#define DECLARE_OPERATION(_operation, _symbolic)\
case _operation:\
value = left _symbolic right; break

#define DECLARE_PREFIX_OPERATION(_operation, _symbolic)\
case _operation:\
value = _symbolic operand; break

#define DECLARE_POSTFIX_OPERATION(_operation, _symbolic)\
case _operation:\
value = operand _symbolic; break

#define DECLARE_FOR_RETURN_TYPE(_returnTypeID, _returnType, _castType)\
case _returnTypeID: {\
_returnType value;\
switch (_castType) {\
case YASLBuiltInTypeInt:\
value = [self intOperation:operator resultForLeftOperand:leftOperand rightOperand:rightOperand]; break;\
case YASLBuiltInTypeFloat:\
value = [self floatOperation:operator resultForLeftOperand:leftOperand rightOperand:rightOperand]; break;\
case YASLBuiltInTypeBool:\
value = [self boolOperation:operator resultForLeftOperand:leftOperand rightOperand:rightOperand]; break;\
case YASLBuiltInTypeChar:\
value = [self charOperation:operator resultForLeftOperand:leftOperand rightOperand:rightOperand]; break;\
default:\
value = 0;\
}\
result = [YASLTranslationConstant constantInScope:_solver.declarationScope.currentScope withType:self.returnType andValue:@(value)];\
break;\
}\

#define DECLARE_UNARY_FOR_RETURN_TYPE(_returnTypeID, _returnType, _castType)\
case _returnTypeID: {\
_returnType value;\
switch (_castType) {\
case YASLBuiltInTypeInt:\
value = [self intUnaryOperation:operator resultForOperand:leftOperand]; break;\
case YASLBuiltInTypeFloat:\
value = [self floatUnaryOperation:operator resultForOperand:leftOperand]; break;\
case YASLBuiltInTypeBool:\
value = [self boolUnaryOperation:operator resultForOperand:leftOperand]; break;\
case YASLBuiltInTypeChar:\
value = [self charUnaryOperation:operator resultForOperand:leftOperand]; break;\
default:\
value = 0;\
}\
result = [YASLTranslationConstant constantInScope:_solver.declarationScope.currentScope withType:self.returnType andValue:@(value)];\
break;\
}\



@class YASLDataType, YASLExpressionSolver, YASLDataTypesManager, YASLTranslationConstant;
@interface YASLExpressionProcessor : NSObject

@property (nonatomic, readonly) YASLExpressionSolver *solver;
@property (nonatomic) YASLDataType *returnType;
@property (nonatomic, readonly) YASLDataType *castType;

- (id)initWithDataTypesManager:(YASLDataTypesManager *)manager;
- (id) initWithDataTypesManager:(YASLDataTypesManager *)manager forSolver:(YASLExpressionSolver *)solver withCastType:(YASLDataType *)castType;

- (YASLTranslationExpression *) solveExpression:(YASLTranslationExpression *)expression;

+ (NSString *) returnTypeIdentifier;


- (YASLInt) intOperation:(YASLExpressionOperator)operator resultForLeftOperand:(YASLTranslationConstant *)leftOperand rightOperand:(YASLTranslationConstant *)rightOperand;
- (YASLFloat) floatOperation:(YASLExpressionOperator)operator resultForLeftOperand:(YASLTranslationConstant *)leftOperand rightOperand:(YASLTranslationConstant *)rightOperand;
- (YASLBool) boolOperation:(YASLExpressionOperator)operator resultForLeftOperand:(YASLTranslationConstant *)leftOperand rightOperand:(YASLTranslationConstant *)rightOperand;
- (YASLChar) charOperation:(YASLExpressionOperator)operator resultForLeftOperand:(YASLTranslationConstant *)leftOperand rightOperand:(YASLTranslationConstant *)rightOperand;

@end
