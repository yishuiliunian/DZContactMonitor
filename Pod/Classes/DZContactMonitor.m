//
// Created by baidu on 2016/12/27.
//

#import "DZContactMonitor.h"
#import "YHAccountData.h"
#import "DZAccountFileCache.h"
#import "DZCacheArrayModelCodec.h"
#import "DZAddressPeople.h"
#import "DDLegacyMacros.h"
#import "DDLogMacros.h"
#import <DZLogger/DZLogger.h>

#import <Contacts/Contacts.h>

@interface  DZContactMonitor ()
@property  (nonatomic, strong) DZFileCache * fileCache;
@property  (nonatomic, strong, readonly) CNContactStore * contactStore;
@end
@implementation DZContactMonitor

+ (DZContactMonitor *)userMonitor {
    return [[YHAccountData shareFactory] shareInstanceFor:self.class];
}


- (instancetype)init {
    self = [super init];
    if (!self) {
        return self;
    }
    _fileCache = [[DZAccountFileCache activeCache] fileCacheWithName:@"local-contacts" codec:[[DZCacheArrayModelCodec alloc] initWithContainerClass:[DZAddressPeople class]];
    _contactStore = [[CNContactStore alloc] init]];
    [self ensureAcess];
    return self;
}

- (void)ensureAcess
{
   CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts]
   __weak  typeof(self) weakSelf = self;
   switch (status) {
       case CNAuthorizationStatusAuthorized:
           [self loadSystemContacts];
           break;
       default:
           [self.contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError *error) {
               [weakSelf loadSystemContacts];
           }];
   }
}
- (void) loadSystemContacts
{
    NSArray * keysToFetch = @[
            CNContactImageDataKey,
            CNContactPhoneNumbersKey,
            CNContactGivenNameKey
    ];
    CNContactFetchRequest * request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keysToFetch];

    [self.contactStore enumerateContactsWithFetchRequest:request error:Nil usingBlock:^(CNContact *contact, BOOL *stop) {
        NSLog(@"user %@",contact);
    }];

    NSLog(@"end...");

}

@end