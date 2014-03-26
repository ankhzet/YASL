//
//  YASLCIOverride.c
//  YASL
//
//  Created by Ankh on 26.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#include <objc/objc.h>
#include <objc/objc-runtime.h>

id const noARCCreateInstanceOfClass(Class const class) {
	id instance = class_createInstance(class, 0);
	return instance;
}