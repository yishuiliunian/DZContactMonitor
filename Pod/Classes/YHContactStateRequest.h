//
//  YHContactStateRequest.h
//  YaoHe
//
//  Created by stonedong on 16/12/27.
//
//



#import <YHNetCore/YHAuthedRequest.h>
#import <YHNetCore.h>
@interface YHContactStateRequest : YHAuthedRequest
@property  (nonatomic, strong, readonly) QueryAddressBookRequest* query;
@end
