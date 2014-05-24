//
//  YASLReturnExpression.m
//  YASL
//
//  Created by Ankh on 09.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLJumpExpression.h"
#import "YASLCoreLangClasses.h"

@implementation YASLJumpExpression

- (YASLTranslationExpression *) foldConstantExpressionWithSolver:(YASLExpressionSolver *)solver {
	if ((self.expressionType == YASLExpressionTypeReturn) && [self nodesCount]) {
		YASLTranslationExpression *foldedReturn = [[self leftOperand] foldConstantExpressionWithSolver:solver];
		self.returnType = foldedReturn.returnType;
		[self setNth:0 operand:foldedReturn];
	}
	return self;
}

- (NSString *) toString {
	switch (self.expressionType) {
		case YASLExpressionTypeReturn:
			return [NSString stringWithFormat:@"return %@", [self leftOperand] ? [self leftOperand] : @""];
			break;

		case YASLExpressionTypeJump:
			return [NSString stringWithFormat:@"%@", self.specifier];
			break;

		default:
			break;
	}
	return @"jump";
}

@end

@implementation YASLJumpExpression (Assembling)

- (void) assembleReturn:(YASLAssembly *)assembly {
	YASLTranslationNode *f = self;
	while (f && (f.type != YASLTranslationNodeTypeFunction)) {
		f = f.parent;
	}
	YASLTranslationFunction *function = (YASLTranslationFunction *)f;
	YASLDeclarationScope *functionBodyScope = [f.declarationScope.childs firstObject];

	YASLLocalDeclaration *extLabel = [functionBodyScope localDeclarationByIdentifier:[function exitLabelIdentifier]];
	YASLOpcodeOperand *extAddress = [extLabel.reference addNewOpcodeOperandReferent];

	if ([self nodesCount]) {
		YASLLocalDeclaration *retVal = [functionBodyScope localDeclarationByIdentifier:[function returnVarIdentifier]];
		YASLOpcodeOperand *retAddress = [retVal.reference addReferent:[REG_IMM(BP, @0) asPointer]];

		YASLTranslationExpression *expression = [self leftOperand];
		[expression assemble:assembly unPointered:YES];
		[assembly push:OPC_(MOV, retAddress, REG_(R0))];
	}
	[assembly push:OPC_(JMP, extAddress)];
}

- (void) assembleJump:(YASLAssembly *)assembly {
	YASLOpcodeOperand *extAddress = [self.jumpDeclaration.reference addNewOpcodeOperandReferent];
	[assembly push:OPC_(JMP, extAddress)];
}

- (void) assemble:(YASLAssembly *)assembly {
	switch (self.expressionType) {
		case YASLExpressionTypeReturn:
			[self assembleReturn:assembly];
			break;

		case YASLExpressionTypeJump:
			[self assembleJump:assembly];
			break;

		default:
			break;
	}
}

@end
