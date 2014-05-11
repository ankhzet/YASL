//
//  YASLAPI.h
//  YASL
//
//  Created by Ankh on 26.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#ifndef YASL_YASLAPI_h
#define YASL_YASLAPI_h

#define _YASLBuiltInTypeIdentifierVoid @"void"
#define _YASLBuiltInTypeIdentifierInt @"int"
#define _YASLBuiltInTypeIdentifierFloat @"float"
#define _YASLBuiltInTypeIdentifierBool @"bool"
#define _YASLBuiltInTypeIdentifierChar @"char"

typedef int YASLInt;
typedef YASLInt YASLBool;
typedef float YASLFloat;
typedef unichar YASLChar;

typedef NS_ENUM(NSUInteger, YASLBuiltInType) {
	YASLBuiltInTypeVoid = 0,
	YASLBuiltInTypeUnknown = 0,
	YASLBuiltInTypeInt,
	YASLBuiltInTypeFloat,
	YASLBuiltInTypeBool,
	YASLBuiltInTypeChar,

	YASLBuiltInTypeMAX,
};

extern NSString *const YASLBuiltInTypeIdentifierUnknown;
extern NSString *const YASLBuiltInTypeIdentifierVoid;
extern NSString *const YASLBuiltInTypeIdentifierInt;
extern NSString *const YASLBuiltInTypeIdentifierFloat;
extern NSString *const YASLBuiltInTypeIdentifierBool;
extern NSString *const YASLBuiltInTypeIdentifierChar;

extern NSString *YASLAPITypeHandle;

extern YASLInt YASL_INVALID_HANDLE;

extern YASLInt WEI_INFINITE;

#endif
