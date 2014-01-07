//====================================================================================================
// Author: Peter Chen
// Created: 10/19/13
// Copyright 2013 Hidoodle
//====================================================================================================

#import "PCSAddressBookGroup.h"
#import "PCSAddressBookPerson.h"
#import "PCSAddressBook.h"

@interface PCSAddressBookGroup()



@end

@implementation PCSAddressBookGroup

- (id)initWithRecordRef:(ABRecordRef)recordRef {
   if ((self = [super init])) {
      self.recordRef = recordRef;
      self.recordId = ABRecordGetRecordID(self.recordRef);
      self.name = (__bridge_transfer NSString *) ABRecordCopyValue(self.recordRef, kABGroupNameProperty);
      
      CFArrayRef membersRef = ABGroupCopyArrayOfAllMembers(self.recordRef);
      self.numMembers = membersRef ? CFArrayGetCount(membersRef) : 0;
   }
   return self;
}

- (id)init {
   if ((self = [super init])) {
   }
   return self;
}

- (NSString *)description {
   return [NSString stringWithFormat:@"%d, %@", self.recordId, self.name];
}

- (NSArray *)getAllMembers {
   NSMutableArray *members = [NSMutableArray array];
   CFArrayRef recordRefs = ABGroupCopyArrayOfAllMembersWithSortOrdering(self.recordRef, kABPersonSortByFirstName);
   if (recordRefs) {
      for (CFIndex i=0; i<CFArrayGetCount(recordRefs); i++) {
         ABRecordRef ref = CFArrayGetValueAtIndex(recordRefs, i);
         PCSAddressBookPerson *person = [[PCSAddressBookPerson alloc] initWithRecordRef:ref];
         [members addObject:person];
      }
   }
   return members;
}

- (NSComparisonResult)compareByName:(PCSAddressBookGroup *)group {
   return [self.name compare:group.name];
}

- (BOOL)addPersonToGroup:(PCSAddressBookPerson *)person {
   CFErrorRef error;
   
   if (! ABAddressBookAddRecord([PCSAddressBook addressBook].addressBookRef, person.recordRef, NULL))
      return NO;
   
   if (! ABAddressBookSave([PCSAddressBook addressBook].addressBookRef, NULL))
      return NO;
   
   if (! ABGroupAddMember(self.recordRef, person.recordRef, &error)) {
      //NSError *nserror1 = (__bridge_transfer NSError *) error;
      //NSLog(@"ERROR Couldn't add member to group - %@", nserror1);
      return NO;
   }
   
   if (! ABAddressBookSave([PCSAddressBook addressBook].addressBookRef, NULL))
      return NO;
   
   return YES;
}

@end
