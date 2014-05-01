//
//  NSObject+TabbedDescription.h
//  YASL
//
//  Created by Ankh on 30.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (TabbedDescription)

/*! Split object description on lines and prepend them with tabulation. */
- (NSString *) descriptionTabbed:(NSString *)tab;
/*! Grow tabulation. */
+ (NSString *) progressTab:(NSString *)tab;

@end
