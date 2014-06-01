//
//  YASLDataTypes.h
//  YASL
//
//  Created by Ankh on 28.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YASLDataTypesManagerProtocol.h"

@interface YASLDataTypesManager : NSObject <YASLDataTypesManagerProtocol>

@property (nonatomic, weak) YASLDataTypesManager *parentManager;

+ (instancetype) datatypesManagerWithParentManager:(YASLDataTypesManager *)parent;

@end
