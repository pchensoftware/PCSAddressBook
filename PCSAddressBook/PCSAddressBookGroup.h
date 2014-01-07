//====================================================================================================
// Author: Peter Chen
// Created: 10/19/13
// Copyright 2013 Hidoodle
//====================================================================================================

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@class PCSAddressBookPerson;

@interface PCSAddressBookGroup : NSObject

@property (nonatomic, assign) ABRecordID recordId;
@property (nonatomic, assign) ABRecordRef recordRef;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) int numMembers;

- (id)initWithRecordRef:(ABRecordRef)recordRef;
- (NSArray *)getAllMembers;
- (NSComparisonResult)compareByName:(PCSAddressBookGroup *)group;
- (BOOL)addPersonToGroup:(PCSAddressBookPerson *)person;

@end
