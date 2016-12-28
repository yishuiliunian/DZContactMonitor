//
//  YHAddressBookTableElement.m
//  YaoHe
//
//  Created by baidu on 2016/12/28.
//
//

#import <DZAlertPool/DZAlertPool.h>
#import "YHAddressBookTableElement.h"
#import "EKAdjustCellElement.h"
#import "DZContactMonitor.h"
#import "YHAddressBookPeopleElement.h"
#import "YHURLRouteDefines.h"
#import "EKTableViewController.h"

@interface YHAddressBookTableElement () <DZContactsObserver>
@end
@implementation YHAddressBookTableElement

+ (void)load {
    [[DZURLRoute defaultRoute] addRoutePattern:kYHURLShowAddressContacts handler:^DZURLRouteResponse *(DZURLRouteRequest *request) {

        void (^Action)() = ^{
            YHAddressBookTableElement * ele = [YHAddressBookTableElement new];
            EKTableViewController * tableVC = [[EKTableViewController alloc] initWithElement:ele];

            [tableVC registerLifeCircleAction:[DZVCOnceLifeCircleAction actionWithOnceBlock:^(UIViewController *vc, BOOL animated) {
                [[DZContactMonitor userMonitor] asyncLoadSystemContacts];
            }]];
            tableVC.title = @"手机联系人";
            tableVC.hidesBottomBarWhenPushed = YES;
            [request.context.topNavigationController pushViewController:tableVC animated:YES];
        };
            CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
            __weak  typeof(self) weakSelf = self;
            switch (status) {
                case CNAuthorizationStatusAuthorized:
                    Action();
                    break;
                default:
                    [[DZContactMonitor userMonitor].contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (granted) {
                                Action();
                            } else {
                                DZAlertShowError(@"请授权之后查看手机联系人");
                            }
                        });
                    }];
            }
        return [DZURLRouteResponse successResponse];
    }];
}

- (instancetype)init {
    self = [super init];
    if (!self) return self;
    [[DZContactMonitor userMonitor] registerObserver:self];
    return self;
}
- (void)contactMonitor:(DZContactMonitor *)monitor receiveChangedStates:(NSArray *)changedContacts {

}

- (void)willBeginHandleResponser:(UIResponder *)responser {
    [super willBeginHandleResponser:responser];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}

- (void)reloadData {
    NSArray * allPeoples= [DZContactMonitor userMonitor].peoples;
    NSMutableArray * eles = [NSMutableArray new];
    for (DZAddressPeople * p in allPeoples) {
        YHAddressBookPeopleElement * e = [[YHAddressBookPeopleElement alloc] initWithPeople:p];
        [eles addObject:e];
    }
    [_dataController clean];
    [_dataController updateObjects:eles];
    [_dataController sortUseBlock:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    [self.tableView reloadData];
}

- (void)contactMonitorStartSync:(DZContactMonitor *)monitor {
    DZAlertShowLoading(nil);
}

- (void)contactMonitorEndSync:(DZContactMonitor *)monitor {
    [self reloadData];
    DZAlertHideLoading;
}
@end
