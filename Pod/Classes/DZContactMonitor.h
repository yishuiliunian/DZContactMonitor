//
// Created by baidu on 2016/12/27.
//

#import <Foundation/Foundation.h>



@class DZContactMonitor;
@protocol DZContactsObserver
- (void) contactMonitor:(DZContactMonitor *)monitor receiveChangedStates:(NSArray *)changedContacts;
@end

@interface DZContactMonitor : NSObject

+ (DZContactMonitor *) userMonitor;

- (void) registerObserver:(id<DZContactsObserver>)observer;
@end