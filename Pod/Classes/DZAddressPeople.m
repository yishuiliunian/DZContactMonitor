//
// Created by baidu on 2016/12/27.
//

#import "DZAddressPeople.h"


@implementation DZAddressPeople

- (BOOL)isEqual:(DZAddressPeople *)object {
    if  (![object isKindOfClass:[self class]]) return  NO;
    return [object.identifier isEqualToString:self.identifier];
}
@end