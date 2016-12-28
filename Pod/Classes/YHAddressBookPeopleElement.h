//
//  YHAddressBookPeopleElement.h
//  YaoHe
//
//  Created by baidu on 2016/12/28.
//
//



#import <ElementKit/EKAdjustCellElement.h>
#import <UIKit/UIKit.h>

@class DZAddressPeople;

@interface YHAddressBookPeopleElement : EKAdjustCellElement
@property  (nonatomic, strong, readonly) DZAddressPeople * people;

- (instancetype) initWithPeople:(DZAddressPeople *)people;
@end
