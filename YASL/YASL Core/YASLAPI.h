//
//  YASLAPI.h
//  YASL
//
//  Created by Ankh on 26.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#ifndef YASL_YASLAPI_h
#define YASL_YASLAPI_h

#define CONSTANT static

typedef int YASLInt;
typedef YASLInt YASLBool;
typedef float YASLFloat;

CONSTANT NSString *YASLAtomicTypeInt = @"int";
CONSTANT NSString *YASLAtomicTypeString = @"string";
CONSTANT NSString *YASLAtomicTypeFloat = @"float";
CONSTANT NSString *YASLAtomicTypeBool = @"bool";

CONSTANT NSString *YASLAPITypeHandle = @"handle";

CONSTANT YASLInt YASL_INVALID_HANDLE = -1;

CONSTANT YASLInt WEI_INFINITE = -1;

#endif
