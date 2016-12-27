//
//  YHContactStateRequest.m
//  YaoHe
//
//  Created by stonedong on 16/12/27.
//
//

#import "YHContactStateRequest.h"

@implementation YHContactStateRequest
- (instancetype) init
{
    self = [super init];
    if (!self) {
        return self;
    }
    _responseClass = [QueryAddressBookResponse class];
    return self;
}
- (NSString*) method
{
    return M_QUERY_ADDESSBOOK;
}

- (NSString*) servant
{
    return S_CLIENTWRAP_SERVER;
}

- (InfoWallRequest*) infoWall
{
    if (!_requestData) {
        _requestData = [InfoWallRequest new];
    }
    return (InfoWallRequest*)_requestData;
}
@end
