//
//  TestUtils.h
//  YASL
//
//  Created by Ankh on 26.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#ifndef YASL_TestUtils_h
#define YASL_TestUtils_h

#define CPU_PUTINSTR(_offset, _opcode, _type, _op1, _op2, _r1, _r2) *((YASLCodeInstruction *)[ram dataAt:_offset]) = (YASLCodeInstruction){\
.opcode = _opcode,\
.type = _type,\
.operand1 = _op1,\
.operand2 = _op2,\
.r1 = _r1,\
.r2 = _r2,\
};\
_offset += sizeof(YASLCodeInstruction);

#define CPU_PUTVAL(_offset, _val) \
[ram setInt:_val at:_offset]; \
_offset += sizeof(YASLInt);

#endif
