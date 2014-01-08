//====================================================================================================
// Author: Peter Chen
// Created: 10/19/13
// Copyright 2013 Hidoodle
//====================================================================================================

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface PCSAddressBook : NSObject

@property (nonatomic, readonly) ABAddressBookRef addressBookRef;
@property (nonatomic, readonly) NSArray *groups;
@property (nonatomic, readonly) NSArray *sortedGroups;
@property (nonatomic, readonly) int numTotalContacts;

+ (PCSAddressBook *)addressBook;
- (void)requestAccessWithCompletion:(void(^)(BOOL granted, NSError *error))completion;
- (NSArray *)getAllPeople;
- (NSArray *)getPeopleForGroups:(NSArray *)groups;
- (PCSAddressBookPerson *)getPersonWithRecordId:(ABRecordID)recordId;

@end
