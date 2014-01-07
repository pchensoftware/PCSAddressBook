//====================================================================================================
// Author: Peter Chen
// Created: 10/19/13
// Copyright 2013 Hidoodle
//====================================================================================================

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface PCSAddressBookPerson : NSObject

@property (nonatomic, assign) ABRecordID recordId;
@property (nonatomic, assign) ABRecordRef recordRef;

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSMutableArray *emails;
@property (nonatomic, strong) NSMutableArray *phoneNumbers;
@property (nonatomic, strong) NSString *companyName;
@property (nonatomic, assign) BOOL isCompany;
@property (nonatomic, strong) UIImage *photoThumbnail;

@property (nonatomic, readonly) NSString *fullName;
@property (nonatomic, readonly) NSString *displayName;

- (id)initWithRecordRef:(ABRecordRef)recordRef;
- (NSComparisonResult)compareByName:(PCSAddressBookPerson *)person; // uses fullName or companyName

@end
