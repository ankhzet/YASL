//
//  YASLTranslationFunction.m
//  YASL
//
//  Created by Ankh on 09.05.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "YASLTranslationFunction.h"
#import "YASLCoreLangClasses.h"

@implementation YASLTranslationFunction

+ (instancetype) functionInScope:(YASLDeclarationScope *)scope withDeclaration:(YASLLocalDeclaration *)declaration {
	YASLTranslationFunction *functionNode = [YASLTranslationFunction nodeInScope:scope withType:YASLTranslationNodeTypeFunction];
	functionNode->_declaration = declaration;
	return functionNode;
}

- (NSString *) toString {
	NSString *signature = [NSString stringWithFormat:@"%@ %@", self.declaration.dataType, self.declaration.declarator];
	return [NSString stringWithFormat:@"%@ {\n%@\n}", signature, [self.subnodes componentsJoinedByString:@";\n"]];
}

- (NSString *) returnVarIdentifier {
	return [NSString stringWithFormat:@"%@:return", self.declaratorIdentifier];
}

- (NSString *) exitLabelIdentifier {
	return [NSString stringWithFormat:@"%@:exit", self.declaratorIdentifier];
}

@end

/*
 
 func(p1, p2, p3) {int l1, l2; return p2;} ->
 push p1
 push p2
 push p3
 call :func
 
 :func
 push bp
 save r1, r3
 mov bp, sp
 pushv (sizeof(l1) + sizeof(l2) + sizeof(return))
 :func:body
 mov r0, [:p2]
 mov [func:return], r0
 :exit
 mov r0, [func:return]
 mov sp, bp
 load r3, r1
 pop bp
 retv (3 * 4)
 
BP-r  idx BP stack
 
bp-36   0 00 0000
 
 push p1
bp-32   4 00 p1
 
 push p2
bp-28   8 00 p2
 
 push p3
bp-24  12 00 p3
 
 call :func
bp-20  16 00 :func

 push bp
bp-16	 20 00 bp

 save r1, r3
bp-12  24 00 r1
bp-08  28 00 r2
bp-04  32 00 r3
 
 mov bp, sp
bp-00	 32 32

 pushv 3 * 4
bp-00  36 32 l1
bp+04  40 32 l2
bp+08  44 32 func:return

 mov r0, [bp-28]
 mov [bp+08], r0
 :exit
 mov r0, [bp+08]

 mov sp, bp
bp-00  32 32

 load r3, r1
bp-04  28 32 r3
bp-08  24 32 r2
bp-12  20 32 r1
 pop bp
bp+16  16 00
 retv (3 * 4)
bp+12  12 00 :func
bp+08  08 00 p3
bp+04  04 00 p2
bp+00  00 00 p1


 */

@implementation YASLTranslationFunction (Assembling)

- (BOOL) assemble:(YASLAssembly *)assembly unPointer:(BOOL)unPointer {
	YASLDeclarationScope *functionScope = self.declarationScope;
	YASLDeclarationScope *bodyScope = [functionScope.childs firstObject];

	YASLLocalDeclaration *declaration = [functionScope localDeclarationByIdentifier:self.declaratorIdentifier];

	YASLLocalDeclaration *returnVar = [bodyScope localDeclarationByIdentifier:[self returnVarIdentifier]];
	YASLLocalDeclaration *extLabel = [bodyScope localDeclarationByIdentifier:[self exitLabelIdentifier]];
	YASLOpcodeOperand *returnImmediate = [REG_IMM(BP, @0) asPointer];
	YASLOpcodeOperand *startImmediate = IMM_(@0);
	[returnVar.reference addReferent:returnImmediate];
	YASLDataType *returns = returnVar.dataType;
	BOOL isVoid = [returns baseType] == YASLBuiltInTypeVoid;

	NSArray *params = [functionScope localDeclarations];

//	[functionScope.placementManager calcPlacementForScope:functionScope];
	NSUInteger localDataSize = [bodyScope scopeDataSize];
	NSUInteger paramsDataSize = [functionScope localDeclarationsDataSize];

	NSInteger savedRegisters = (isVoid ? 4 : 3) * sizeof(YASLInt);
	NSInteger savedBP = sizeof(YASLInt);
	NSInteger savedIP = sizeof(YASLInt);
	NSInteger preservedOnStack = savedRegisters + savedBP + savedIP;
	NSInteger totalOffset = - ( preservedOnStack + paramsDataSize);
	for (YASLLocalDeclaration *param in params) {
    param.reference.base = totalOffset;
	}

	[declaration.reference addReferent:startImmediate];
	YASLOpcodeOperand *lowerReg = isVoid ? REG_(R0) : REG_(R1);
	[assembly push:OPC_(NOP)]; // mark function start
	[assembly push:OPC_(JMP, startImmediate)];
	[assembly push:declaration.reference];
	[assembly push:OPC_(PUSH, REG_(BP))];
	[assembly push:OPC_(SAVE, lowerReg, REG_(R3))];
	[assembly push:OPC_(MOV, REG_(BP), REG_(SP))];
	if (localDataSize)
		[assembly push:OPC_(PUSHV, IMM_(@(localDataSize)))];

	for (YASLTranslationNode *statement in self.subnodes) {
		[statement assemble:assembly unPointer:unPointer];
	}


	[assembly push:extLabel.reference];

	if (!isVoid) {
		[assembly push:OPC_(MOV, REG_(R0), returnImmediate)];
	}

	[assembly push:OPC_(MOV, REG_(SP), REG_(BP))];
	[assembly push:OPC_(LOAD, REG_(R3), lowerReg)];
	[assembly push:OPC_(POP, REG_(BP))];
	[assembly push:(paramsDataSize ? OPC_(RETV, IMM_(@(paramsDataSize))) : OPC_(POP, REG_(BP)))];
	return YES;
}

@end
