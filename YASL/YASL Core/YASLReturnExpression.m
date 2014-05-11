//
//  YASLReturnExpression.m
//  YASL
//
//  Created by Ankh on 09.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLReturnExpression.h"
#import "YASLCoreLangClasses.h"

@implementation YASLReturnExpression

- (YASLTranslationExpression *) foldConstantExpressionWithSolver:(YASLExpressionSolver *)solver {
	if ([self operandsCount]) {
		YASLTranslationExpression *foldedReturn = [[self leftOperand] foldConstantExpressionWithSolver:solver];
		self.returnType = foldedReturn.returnType;
		self.subnodes[0] = foldedReturn;
	}
	return self;
}

- (NSString *) toString {
	return [NSString stringWithFormat:@"return %@", [self leftOperand] ? [self leftOperand] : @""];
}

@end

@implementation YASLReturnExpression (Assembling)

- (BOOL) assemble:(YASLAssembly *)assembly unPointer:(BOOL)unPointer {
	YASLTranslationExpression *expression = [self leftOperand];
	[expression assemble:assembly unPointer:unPointer];
	YASLTranslationNode *f = self;
	while (f && (f.type != YASLTranslationNodeTypeFunction)) {
		f = f.parent;
	}
	YASLDeclarationScope *functionBodyScope = [f.declarationScope.childs firstObject];

	YASLOpcodeOperand *retRef = [REG_IMM(BP, @0) asPointer];
	YASLOpcodeOperand *extLab = IMM_(@0);
	YASLLocalDeclaration *retVal = [functionBodyScope localDeclarationByIdentifier:[(YASLTranslationFunction *)f returnVarIdentifier]];
	YASLLocalDeclaration *extLabel = [functionBodyScope localDeclarationByIdentifier:[(YASLTranslationFunction *)f exitLabelIdentifier]];
	[retVal.reference addReferent:retRef];
	[extLabel.reference addReferent:extLab];
	[assembly push:OPC_(MOV, retRef, REG_(R0))];
	[assembly push:OPC_(JMP, extLab)];
	return YES;
}

@end
