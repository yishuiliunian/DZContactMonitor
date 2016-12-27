//
// Created by baidu on 2016/12/27.
//

#import <Foundation/Foundation.h>


@interface DZAddressPeople : NSObject
@property  (nonatomic, strong) NSString * identifier;
@property  (nonatomic, strong) NSString * name;
@property  (nonatomic, strong) NSArray<NSString*> * phoneNumbers;
@property  (nonatomic, strong) NSString * userID;
@property  (nonatomic, assign) BOOL firend;
@end