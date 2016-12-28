//
//  YHAddressBookCell.m
//  YaoHe
//
//  Created by baidu on 2016/12/28.
//
//

#import "YHAddressBookCell.h"
#import "Haneke.h"
#import <DZProgrameDefines.h>
#import <DZGeometryTools/DZGeometryTools.h>
#import "YHAppearance.h"
@implementation YHAddressBookCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return self;
    }
    INIT_SUBVIEW_UIButton(self.contentView , _actionButton);
    INIT_SUBVIEW_UIImageView(self.contentView, _avatarView);
    INIT_SUBVIEW_UILabel(self.contentView, _nickLabel);
    INIT_SUBVIEW_UILabel(self.contentView, _indicatorLabel);
    _avatarView.hnk_cacheFormat = LTHanekeCacheFormatAvatar();
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = CGRectCenterSubSize(self.contentView.bounds, CGSizeMake(30, 16));
    CGSize buttonSize = {100, 30};
    CGFloat  avatarHeight = (CGRectGetHeight(contentRect));
    CGSize avatarSize = {avatarHeight, avatarHeight};
    CGRect avatarR;
    CGRect nickR;
    CGRect indicatorR;
    CGRect buttonR;

    CGRectDivide(contentRect, &avatarR, &contentRect, avatarSize.width, CGRectMinXEdge);

    avatarR = CGRectCenter(avatarR, avatarSize);

    CGRectDivide(contentRect, &buttonR, &contentRect, buttonSize.width, CGRectMaxXEdge);
    buttonR = CGRectCenter(buttonR, buttonSize);

    CGRect labelRs[2];
    CGRectVerticalSplit(contentRect, labelRs, 2, 2);

    nickR = labelRs[0];
    indicatorR = labelRs[1];

    _avatarView.frame = avatarR;
    _nickLabel.frame = nickR;
    _indicatorLabel.frame = indicatorR;
    _actionButton.frame = buttonR;
}
@end
