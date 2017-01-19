//
// Created by baidu on 2016/12/27.
//

#import "DZContactMonitor.h"
#import "YHAccountData.h"
#import "DZAccountFileCache.h"
#import "DZCacheArrayModelCodec.h"
#import "DZAddressPeople.h"
#import "YHContactStateRequest.h"
#import "DZAuthSession.h"
#import "DZCacheKeyModelCodec.h"
#import <DZLogger/DZLogger.h>
#import <Contacts/Contacts.h>
#import <YHCommonCache.h>
#import <Bugly/Bugly/Bugly.h>
#import "DZCacheKeyModelCodec.h"
#import "EKAdjustTableElement.h"
#import "HNKCache.h"
#import "YHImageURLAdapter.h"
#import "YHContactsManager.h"

@interface  DZContactMonitor ()
{
    NSRecursiveLock * _lock;
}
@property  (nonatomic, strong) DZFileCache * fileCache;

@property  (nonatomic, strong, readonly) YHObserverContainer * observerContainer;
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
    _observerContainer = [YHObserverContainer new];
    _fileCache = [[DZAccountFileCache activeCache] fileCacheWithName:@"local-contacts" codec:[[DZCacheKeyModelCodec alloc] initWithModelClass:[DZAddressPeople class]]];
    _contactStore = [[CNContactStore alloc] init];
    _lock = [NSRecursiveLock new];
    return self;
}


- (void) startSync
{
    NSArray * observers = [_observerContainer allDefaultObservers];
    for (NSObject <DZContactsObserver>* ob in observers) {
        if ([ob respondsToSelector:@selector(contactMonitorStartSync:)]) {
            [ob contactMonitorStartSync:self];
        }
    }
}


- (void) endSync
{
    NSArray * observers = [_observerContainer allDefaultObservers];
    for (NSObject <DZContactsObserver>* ob in observers) {
        if ([ob respondsToSelector:@selector(contactMonitorEndSync:)]) {
            [ob contactMonitorEndSync:self];
        }
    }
    [_fileCache flush:nil];
}
- (void) asyncLoadSystemContacts
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0) , ^{
        [self loadSystemContacts];
        dispatch_async(dispatch_get_main_queue(), ^{
           [self startSync];
        });
    });
}

- (void) loadSystemContacts
{
    NSArray * keysToFetch = @[
            CNContactThumbnailImageDataKey,
            CNContactPhoneNumbersKey,
            CNContactGivenNameKey,
            CNContactMiddleNameKey,
            CNContactFamilyNameKey,
            CNContactNicknameKey,
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey
    ];
    CNContactFetchRequest * request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keysToFetch];

    NSDictionary* olderContacts = [_fileCache.cachedDictionary copy];
    NSArray* olderIndexs = olderContacts.allKeys;
    NSMutableArray * comingContacts = [NSMutableArray new];
    NSMutableDictionary * contacts = [NSMutableDictionary new];
    [contacts addEntriesFromDictionary:olderContacts];
    [self.contactStore enumerateContactsWithFetchRequest:request error:Nil usingBlock:^(CNContact *contact, BOOL *stop) {
        NSData * data = [contact thumbnailImageData];
        if (data) {
            UIImage * image = [UIImage imageWithData:data];
            if (image) {
                NSString * key = [NSString stringWithFormat:@"https://%@",contact.identifier];
                [[HNKCache sharedCache] setImage:image forKey:key formatName:LTHanekeCacheFormatAvatar().name];
            }
        }
        if (![olderIndexs containsObject:contact.identifier]) {
            DZAddressPeople * people = [DZAddressPeople new];
            people.identifier = contact.identifier;
            people.name = contact.nickname.length?contact.nickname:[NSString stringWithFormat:@"%@%@%@",contact.familyName,contact.middleName,contact.givenName];
            NSMutableArray * numbers = [NSMutableArray new];
            for (CNLabeledValue * number in contact.phoneNumbers) {
                if ([number.value isKindOfClass:[CNPhoneNumber class]]) {
                    CNPhoneNumber * phoneNumber = number.value;
                    NSString * phone = [number.value stringValue];
                    phone = [phone stringByReplacingOccurrencesOfString:@"-" withString:@""];
                    if (phone.length >= 11) {
                        [numbers addObject:[phone substringFromIndex:phone.length-11]];
                    }
                }
            }
            people.phoneNumbers = numbers;
            people.userID = nil;
            people.firend = NO;


            if (people.phoneNumbers.count) {
                [comingContacts addObject:people];
                contacts[people.identifier] = people;
            }
        } else {
            DZAddressPeople * p = olderContacts[contact.identifier];
            if (p.userID.length == 0 ) {
                [comingContacts addObject:p];
            } else {
                p.firend = [[YHContactsManager shareManager] existContact:p.userID];
            }
        }
    }];
    _fileCache.cachedDictionary = contacts;
    [self syncStatus:comingContacts];
}

- (void) syncStatus:(NSArray *)contacts
{
    if (contacts.count < 1) {
        dispatch_async(dispatch_get_main_queue(), ^ {
            [self endSync];
        });
        return;
    }
    NSArray * willSyncContacts = nil;
    int maxLength = 40;
    if (contacts.count > maxLength) {
        willSyncContacts = [contacts subarrayWithRange:NSMakeRange(0, maxLength)];
        contacts = [contacts subarrayWithRange:NSMakeRange(maxLength,contacts.count-maxLength)];
    } else {
        willSyncContacts = [contacts copy];
        contacts = nil;
    }

    YHContactStateRequest * req = [YHContactStateRequest new];
    NSMutableArray<NSString*> * array = [NSMutableArray new];
    NSMutableDictionary * map = [NSMutableDictionary new];
    for (DZAddressPeople * people in willSyncContacts) {
        for (NSString * number in people.phoneNumbers) {
            [array addObject:number];
            if (people.identifier) {
                map[number] = people;
            }
        }
    }
    req.query.mobileNoArray = array;
    req.skey = DZActiveAuthSession.token;

    __weak  typeof(self) weakSelf = self;
    [req setErrorHandler:^(NSError *error) {
        [weakSelf endSync];
    }];

    [req setSuccessHanlder:^(QueryAddressBookResponse* object) {
        NSMutableArray * changedPeople = [NSMutableArray new];
        for (AddressBook * book in object.addressBookArray) {
            DZAddressPeople * people = map[book.mobileNo];
            people.userID = book.userName;
            people.firend = book.isFriend;
            if (people) {
                [changedPeople addObject:people];
            }
        }
        [weakSelf updateWithServerModel:changedPeople];
        [weakSelf syncStatus:contacts];
    }];

    [req start];
}

- (void) updateWithServerModel:(NSArray *)models
{
    NSMutableDictionary* dictionary= [NSMutableDictionary new];
    [dictionary addEntriesFromDictionary:_fileCache.lastCachedObject];
    for(DZAddressPeople * people in models) {
        dictionary[people.identifier] = people;
    }
    _fileCache.lastCachedObject = dictionary;

    NSArray * observers = _observerContainer.allDefaultObservers;

    for (NSObject<DZContactsObserver>* observer in observers) {
        if ([observer respondsToSelector:@selector(contactMonitor:receiveChangedStates:)]) {
            [observer contactMonitor:self receiveChangedStates:models];
        }
    }
}

- (void)registerObserver:(id <DZContactsObserver>)observer {
    [self.observerContainer addDefaultObserver:observer];
}

- (NSArray <DZAddressPeople *>*)peoples {
    return [_fileCache.cachedDictionary allValues];
}

@end
