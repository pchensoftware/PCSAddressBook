//====================================================================================================
// Author: Peter Chen
// Created: 10/19/13
// Copyright 2013 Hidoodle
//====================================================================================================

#import "PCSAddressBookPerson.h"

@interface PCSAddressBookPerson()



@end

@implementation PCSAddressBookPerson

- (id)initWithRecordRef:(ABRecordRef)recordRef {
   if ((self = [super init])) {
      self.recordRef = recordRef;
      self.recordId = ABRecordGetRecordID(self.recordRef);
      
      self.firstName = (__bridge_transfer  NSString *) ABRecordCopyValue(self.recordRef, kABPersonFirstNameProperty);
      self.lastName = (__bridge_transfer  NSString *) ABRecordCopyValue(self.recordRef, kABPersonLastNameProperty);
      self.photoThumbnail = nil;
      self.emails = [NSMutableArray array];
      self.phoneNumbers = [NSMutableArray array];
      [self _loadEmails];
      [self _loadNumbers];
      [self _loadCompanyInfo];
   }
   return self;
}

- (id)init {
   if ((self = [super init])) {
      self.emails = [NSMutableArray array];
      self.phoneNumbers = [NSMutableArray array];
   }
   return self;
}

- (NSString *)description {
   return [NSString stringWithFormat:@"%@, %@, %@, %@",
           self.firstName, self.lastName, [self.emails componentsJoinedByString:@"/"], [self.phoneNumbers componentsJoinedByString:@"/"]];
}

- (NSString *)fullName {
   return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

- (NSString *)displayName {
   return self.isCompany ? self.companyName : [self fullName];
}

- (NSComparisonResult)compareByName:(PCSAddressBookPerson *)person {
   return [[self fullName] compare:[person fullName]];
}

//====================================================================================================
#pragma mark - Load info
//====================================================================================================

- (void)_loadEmails {
   ABMutableMultiValueRef emailValueRefs = ABRecordCopyValue(self.recordRef, kABPersonEmailProperty);
   [self.emails setArray:(__bridge_transfer NSArray *)ABMultiValueCopyArrayOfAllValues(emailValueRefs)];
}

- (void)_loadNumbers {
   ABMutableMultiValueRef phoneValueRefs = ABRecordCopyValue(self.recordRef, kABPersonPhoneProperty);
   [self.phoneNumbers setArray:(__bridge_transfer NSArray *)ABMultiValueCopyArrayOfAllValues(phoneValueRefs)];
}

- (void)_loadCompanyInfo {
   self.companyName = (__bridge_transfer NSString *) ABRecordCopyValue(self.recordRef, kABPersonOrganizationProperty);
   self.isCompany = (kCFCompareEqualTo == CFNumberCompare(ABRecordCopyValue(self.recordRef, kABPersonKindProperty), kABPersonKindOrganization, NULL));
   
   // Double-check if it's really a company b/c the person kind property might not be set properly
   if (! self.isCompany)
      self.isCompany = ([self.companyName length] > 0 && [self.firstName length] == 0 && [self.lastName length] == 0);
}

- (void)_loadPhotoThumbnail {
   if (! ABPersonHasImageData(self.recordRef)) {
      self.photoThumbnail = nil;
      return;
   }
   
   NSData *imageData = (__bridge_transfer NSData *) ABPersonCopyImageDataWithFormat(self.recordRef, kABPersonImageFormatThumbnail);
   self.photoThumbnail = [UIImage imageWithData:imageData];
}

@end
