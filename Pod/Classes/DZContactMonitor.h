//
// Created by baidu on 2016/12/27.
//

#import <Foundation/Foundation.h>
#import "DZAddressPeople.h"
#import <Contacts/Contacts.h>

@class DZContactMonitor;
@protocol DZContactsObserver
- (void) contactMonitorStartSync:(DZContactMonitor *)monitor;
- (void) contactMonitorEndSync:(DZContactMonitor *)monitor;
- (void) contactMonitor:(DZContactMonitor *)monitor receiveChangedStates:(NSArray *)changedContacts;
@end

@interface DZContactMonitor : NSObject
@property  (nonatomic, strong, readonly) NSArray<DZAddressPeople *> * peoples;
@property  (nonatomic, strong, readonly) CNContactStore * contactStore;
+ (DZContactMonitor *) userMonitor;
- (void) asyncLoadSystemContacts;
- (void) registerObserver:(id<DZContactsObserver>)observer;
@end