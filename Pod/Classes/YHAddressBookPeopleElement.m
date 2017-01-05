//
//  YHAddressBookPeopleElement.m
//  YaoHe
//
//  Created by baidu on 2016/12/28.
//
//

#import <DZAlertPool/DZAlertPool.h>
#import "YHAddressBookPeopleElement.h"
#import "YHAddressBookCell.h"
#import "DZAddressPeople.h"
#import "Haneke.h"
#import "YHNetCore.h"
#import "YHUtils.h"
#import "YHImageURLAdapter.h"
#import "YHCommonCache.h"
#import "YHButtonAppearance.h"
#import "YHAddContactReqeust.h"
#import "DZAuthSession.h"
#import "YHContactsManager.h"
#import "DZURLRoute.h"
#import "YHURLRouteDefines.h"
#import <MessageUI/MessageUI.h>
#import "YHURLRouteDefines.h"
@interface YHAddressBookPeopleElement () <YHCacheFetcherObsever, MFMessageComposeViewControllerDelegate>
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
        self.activeCell.nickLabel.text = profile.readNick;
        [self.activeCell.avatarView loadAvatarURL:DZ_STR_2_URL(profile.faceURL)];
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
            [responser.avatarView loadAvatarURL:[NSURL URLWithString:key]];
            responser.nickLabel.text = _people.name;
            [[YHCommonCache shareCache] fetchUserProfile:_people.userID observer:self];
        }
    } else {
        NSString * key = [NSString stringWithFormat:@"https://%@",_people.identifier];
        [responser.avatarView hnk_setImageFromURL:[NSURL URLWithString:key]];
        responser.nickLabel.text = _people.name;
    }
    [self decorateWithState];
    [responser.actionButton addTarget:self action:@selector(handleAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void) decorateWithState
{
    if (_people.firend) {
        self.activeCell.indicatorLabel.text = [NSString stringWithFormat:@"已经是哟呵好友:%@", _people.phoneNumbers.firstObject];
        DZButtonStyle * style = DZStyleWhiteButton();
        style.disabledStyle.titleColor = [UIColor lightGrayColor];
        [style decorateView:self.activeCell.actionButton];
        [self.activeCell.actionButton setTitle:@"已添加" forState:UIControlStateNormal];
        self.activeCell.actionButton.enabled = NO;
    } else if (_people.userID.length) {
        self.activeCell.indicatorLabel.text = [NSString stringWithFormat:@"手机联系人:%@", _people.phoneNumbers.firstObject];
        self.activeCell.actionButton.enabled = YES;
        [DZStyleBlueButton() decorateView:self.activeCell.actionButton];
        [self.activeCell.actionButton setTitle:@"关注" forState:UIControlStateNormal];
    } else {
        self.activeCell.indicatorLabel.text = [NSString stringWithFormat:@"手机联系人:%@", _people.phoneNumbers.firstObject];
        self.activeCell.actionButton.enabled = YES;
        [self.activeCell.actionButton setTitle:@"邀请" forState:UIControlStateNormal];
        [DZStyleBlueButton() decorateView:self.activeCell.actionButton];
    }

}

- (void)willRegsinHandleResponser:(YHAddressBookCell*)responser {
    [super willRegsinHandleResponser:responser];
}

- (void) handleAction
{
    if (!_people.firend) {
        if (_people.userID) {
            [self firendWithThisMan];
        } else {
            [self inviteThisMan];
        }
    }
}

- (void) inviteThisMan
{

    UIActivityViewController* activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[@"校园里面的事情都在这里，下载哟呵校园开启新生活：https://www.8mclub.com/1895/download.html"] applicationActivities:nil];
    [self.hostViewController presentViewController:activityViewController animated:YES completion:^{

    }];
}

- (void) firendWithThisMan
{
    __weak typeof(self) weakSelf = self;
    YHAddContactReqeust* req = [YHAddContactReqeust new];
    req.addContanct.contactUserName = _people.userID;
    req.skey = DZActiveAuthSession.token;

    __weak typeof(req) weakReq= req;
    [req setErrorHandler:^(NSError * error) {
        DZAlertShowError(error.localizedDescription);
    }];

    [req setSuccessHanlder:^(id object) {
        weakSelf.people.firend = YES;
        [weakSelf decorateWithState];
        [[YHContactsManager shareManager] addContact:weakReq.addContanct.contactUserName];
    }];
    [req start];
}


- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [controller dismissViewControllerAnimated:YES completion:^{

    }];
}

- (void)handleSelectedInViewController:(UIViewController *)vc {
    if (_people.userID.length) {
        NSMutableDictionary* info = [NSMutableDictionary new];
        [info setObject:_people.userID forKey:kYHURLQueryParamterUID];
        [[DZURLRoute defaultRoute] routeURL:DZURLRouteQueryLink(kYHURLUserDetail, info)];
    }
}
@end
