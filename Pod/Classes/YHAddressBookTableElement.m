//
//  YHAddressBookTableElement.m
//  YaoHe
//
//  Created by baidu on 2016/12/28.
//
//

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
        YHAddressBookTableElement * ele = [YHAddressBookTableElement new];
        EKTableViewController * tableVC = [[EKTableViewController alloc] initWithElement:ele];
        tableVC.hidesBottomBarWhenPushed = YES;
        [request.context.topNavigationController pushViewController:tableVC animated:YES];
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
    [self reloadData];
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
    [self.tableView reloadData];
}
@end
