//
//  YHAddressBookCell.h
//  YaoHe
//
//  Created by baidu on 2016/12/28.
//
//



#import <ElementKit/EKAdjustTableViewCell.h>

@interface YHAddressBookCell : EKAdjustTableViewCell
@property  (nonatomic, strong, readonly) UIImageView* avatarView;
@property  (nonatomic, strong, readonly) UILabel * nickLabel;
@property  (nonatomic, strong, readonly) UILabel * indicatorLabel;
@property  (nonatomic, strong, readonly) UIButton* actionButton;
@end
