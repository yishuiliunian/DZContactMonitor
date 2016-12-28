//
//  YHAddressBookPeopleElement.m
//  YaoHe
//
//  Created by baidu on 2016/12/28.
//
//

#import "YHAddressBookPeopleElement.h"
#import "YHAddressBookCell.h"
#import "DZAddressPeople.h"
#import "Haneke.h"
#import "YHNetCore.h"
#import "YHUtils.h"
#import "YHImageURLAdapter.h"
#import "YHCommonCache.h"

@interface YHAddressBookPeopleElement () <YHCacheFetcherObsever>
{
    UserProfile * _userProfile;
}
@property  (nonatomic, strong, readonly, getter=uiEventPool) YHAddressBookCell* activeCell;
@end

@implementation YHAddressBookPeopleElement

- (instancetype)init {
    self = [super init];
    if (!self) {
        return self;
    }
    _viewClass = [YHAddressBookCell class];
    self.cellHeight = 55;
    return self;
}

- (instancetype)initWithPeople:(DZAddressPeople *)people {
    self = [self init];
    if (!self) {
        return self;
    }
    _people = people;
    return self;
}

- (int64_t)compareIdentifier {
    if (_people.firend) {
        return 3;
    } else if (_people.userID) {
        return 2;
    } else {
        return 0;
    }
}

- (void)commonCacheFetchUID:(NSString *)modelId withModel:(id)model {
    SUPER_COMMON_CACHE(modelId, model);
    if ([modelId isEqualToString:_people.userID] && [model isKindOfClass:[UserProfile class]]) {
        UserProfile * profile = (UserProfile *)model;

    }
}

- (void)willBeginHandleResponser:(YHAddressBookCell*)responser {
    [super willBeginHandleResponser:responser];
    responser.nickLabel.text = _people.name;
    responser.indicatorLabel.text = @"手机联系人";
    if (_people.userID)  {
        if (_userProfile) {
            responser.nickLabel.text = _userProfile.readNick;
            [responser.avatarView loadAvatarURL:DZ_STR_2_URL(_userProfile.faceURL)];
        } else {
            NSString * key = [NSString stringWithFormat:@"https://%@",_people.identifier];
            [responser.avatarView hnk_setImageFromURL:[NSURL URLWithString:key]];
            responser.nickLabel.text = _people.name;
            [[YHCommonCache shareCache] fetchUserProfile:_people.userID observer:self];
        }
    } else {
        NSString * key = [NSString stringWithFormat:@"https://%@",_people.identifier];
        [responser.avatarView hnk_setImageFromURL:[NSURL URLWithString:key]];
        responser.nickLabel.text = _people.name;
    }

    if (_people.firend) {
        responser.indicatorLabel.text = [NSString stringWithFormat:@"已经是哟呵好友:%@", _people.phoneNumbers.firstObject];
    } else if (_people.userID.length) {
        responser.indicatorLabel.text = [NSString stringWithFormat:@"手机联系人:%@", _people.phoneNumbers.firstObject];
    } else {
        responser.indicatorLabel.text = [NSString stringWithFormat:@"手机联系人:%@", _people.phoneNumbers.firstObject];
    }


}
@end
