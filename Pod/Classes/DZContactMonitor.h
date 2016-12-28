//
// Created by baidu on 2016/12/27.
//

#import <Foundation/Foundation.h>


#import "DZAddressPeople.h"
@class DZContactMonitor;
@protocol DZContactsObserver
- (void) contactMonitor:(DZContactMonitor *)monitor receiveChangedStates:(NSArray *)changedContacts;
@end

@interface DZContactMonitor : NSObject
@property  (nonatomic, strong, readonly) NSArray<DZAddressPeople *> * peoples;
+ (DZContactMonitor *) userMonitor;

- (void) registerObserver:(id<DZContactsObserver>)observer;
@end