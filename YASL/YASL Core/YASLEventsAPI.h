//
//  YASLEventsAPI.h
//  YASL
//
//  Created by Ankh on 26.04.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YASLNativeInterface.h"
#import "YASLAPI.h"

@class YASLEvent;
@interface YASLEventsAPI : YASLNativeInterface

/*!
 Find existing event by its handle identifier or unique name.
 */
- (YASLEvent *) findByHandle:(YASLInt)handle;
- (YASLEvent *) findByName:(NSString *)name;

/*! Create event with specified initial parameters. If name is not nil and event with the same name already existing, than existing event will be returned and its link counter will be increased. */
- (YASLEvent *) createEventWithName:(NSString *)name initialState:(YASLInt)state autoreset:(BOOL)autoreset;

/*! 
 Set event in specified state.
 @return Old event state if event with specified handle found, YASL_INVALID_HANDLE otherwise.
 */
- (YASLInt) signalEvent:(YASLInt)handle withSignalState:(YASLInt)state;

/*! 
 Close event handle, decreasing its link count by 1. If counter goes to zero - event will be deleted and it's handle will become invalid.
 @return Links count if event with specified handle found, YASL_INVALID_HANDLE otherwise.
 */
- (YASLInt) closeEvent:(YASLInt)handle;

/*!
 Permanently delete event, ignoring its link counter. Event handle will become invalid.
 */
- (void) deleteEvent:(YASLEvent *)event;

@end
