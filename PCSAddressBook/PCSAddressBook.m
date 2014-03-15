//====================================================================================================
// Author: Peter Chen
// Created: 10/19/13
// Copyright 2013 Hidoodle
//====================================================================================================

#import "PCSAddressBook.h"
#import "PCSAddressBookPerson.h"
#import "PCSAddressBookGroup.h"

@interface PCSAddressBook()

@property (nonatomic, assign) ABAddressBookRef addressBookRef; // NOTE: ABAddressBookRef is not thread-safe
@property (nonatomic, strong) NSArray *groups;
@property (nonatomic, strong) NSArray *sortedGroups;
@property (nonatomic, assign) int numTotalContacts;

@end

@implementation PCSAddressBook

+ (PCSAddressBook *)addressBook {
   static PCSAddressBook *sAddressBook = nil;
   static dispatch_once_t onceToken;
   dispatch_once(&onceToken, ^{
      sAddressBook = [[PCSAddressBook alloc] init];
   });
   return sAddressBook;
}

+ (CFMutableArrayRef)sortPeople:(CFArrayRef)peopleRef {
   CFMutableArrayRef sortedPeople = CFArrayCreateMutableCopy(kCFAllocatorDefault, CFArrayGetCount(peopleRef), peopleRef);
   CFArraySortValues(sortedPeople, CFRangeMake(0, CFArrayGetCount(peopleRef)), (CFComparatorFunction) ABPersonComparePeopleByName, (void*) ABPersonGetSortOrdering());
   return sortedPeople;
}

+ (NSArray *)convertPeopleRefsToObjects:(CFArrayRef)peopleRefs {
   NSMutableArray *allPeople = [NSMutableArray array];
   for (CFIndex i=0; i<CFArrayGetCount(peopleRefs); i++) {
      ABRecordRef ref = CFArrayGetValueAtIndex(peopleRefs, i);
      PCSAddressBookPerson *person = [[PCSAddressBookPerson alloc] initWithRecordRef:ref];
      [allPeople addObject:person];
   }
   return allPeople;
}

+ (NSArray *)recordIDsForPeopleRefs:(NSArray *)peopleRefs {
   NSMutableArray *recordIDs = [NSMutableArray array];
   [peopleRefs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      ABRecordID recordID = ABRecordGetRecordID((__bridge ABRecordRef) obj);
      [recordIDs addObject:@(recordID)];
   }];
   return recordIDs;
}

- (id)init {
   if ((self = [super init])) {
      self.addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
      self.numTotalContacts = ABAddressBookGetPersonCount(self.addressBookRef);
      self.groups = nil;
      self.sortedGroups = nil;
   }
   return self;
}

- (void)requestAccessWithCompletion:(void(^)(BOOL granted, NSError *error))completion {
   ABAddressBookRequestAccessWithCompletion(self.addressBookRef, ^(bool granted, CFErrorRef error) {
      if (completion) {
         dispatch_async(dispatch_get_main_queue(), ^{
            completion(granted, (__bridge_transfer NSError *) error);
         });
      }
   });
}

- (NSArray *)groups {
   if (! _groups) {
      NSMutableArray *groups = [NSMutableArray array];
      CFArrayRef recordRefs = ABAddressBookCopyArrayOfAllGroups(self.addressBookRef);
      for (CFIndex i=0; i<CFArrayGetCount(recordRefs); i++) {
         ABRecordRef ref = CFArrayGetValueAtIndex(recordRefs, i);
         PCSAddressBookGroup *group = [[PCSAddressBookGroup alloc] initWithRecordRef:ref];
         [groups addObject:group];
      }
      _groups = groups;
   }
   return _groups;
}

- (NSArray *)sortedGroups {
   if (! _sortedGroups) {
      _sortedGroups = [self.groups sortedArrayUsingSelector:@selector(compareByName:)];
   }
   return _sortedGroups;
}

- (NSArray *)getAllPeople {
   CFArrayRef peopleRef = ABAddressBookCopyArrayOfAllPeople(self.addressBookRef);
   CFMutableArrayRef sortedPeople = [PCSAddressBook sortPeople:peopleRef];
   NSArray *allPeople = [PCSAddressBook convertPeopleRefsToObjects:sortedPeople];
   return allPeople;
}

- (NSArray *)getPeopleForGroups:(NSArray *)groups {
   if ([groups count] == 0)
      return @[];
   
   else if ([groups count] == 1)
      return [((PCSAddressBookGroup *) groups[0]) getAllMembers];
   
   CFMutableArrayRef membersOfGroupsRef = CFArrayCreateMutable(kCFAllocatorDefault, 0, NULL);
   for (PCSAddressBookGroup *group in groups) {
      CFArrayRef memberRef = ABGroupCopyArrayOfAllMembersWithSortOrdering(group.recordRef, kABPersonSortByFirstName);
      CFArrayAppendArray(membersOfGroupsRef, memberRef, CFRangeMake(0, CFArrayGetCount(memberRef)));
   }
   
   CFMutableArrayRef sortedPeople = [PCSAddressBook sortPeople:membersOfGroupsRef];
   NSArray *peopleObjects = [PCSAddressBook convertPeopleRefsToObjects:sortedPeople];
   return peopleObjects;
}

- (void)searchString:(NSString *)searchString foundPeople:(NSArray **)foundPeople inRanges:(NSArray **)foundRanges {
   NSMutableArray *foundPeopleMutable = [NSMutableArray array];
   NSMutableArray *foundRangesMutable = [NSMutableArray array];
   
   NSMutableSet *recordIdSet = [NSMutableSet set];
   
   NSArray *searchWords = [searchString componentsSeparatedByString:@" "];
   for (NSString *searchWord in searchWords) {
      CFArrayRef peopleWithSearchWord = ABAddressBookCopyPeopleWithName(self.addressBookRef, (__bridge CFStringRef) searchWord);
      NSArray *recordIDs = [PCSAddressBook recordIDsForPeopleRefs:(__bridge_transfer NSArray *)peopleWithSearchWord];
      [recordIdSet addObjectsFromArray:recordIDs];
   }
   
   NSArray *peopleRecordsMatchSingleWord = [[recordIdSet allObjects] convert:^id(id element) {
      return (__bridge id)(ABAddressBookGetPersonWithRecordID(self.addressBookRef, [element intValue]));
   }];
   NSArray *peopleMatchSingleWord = [PCSAddressBook convertPeopleRefsToObjects:(__bridge CFArrayRef)peopleRecordsMatchSingleWord];
   [peopleMatchSingleWord enumerateObjectsUsingBlock:^(PCSAddressBookPerson *person, NSUInteger idx, BOOL *stop) {
      NSString *fullName = person.fullName;
      if ([fullName length] == 0)
         return;
      
      NSRange range = [searchString rangeOfString:fullName options:NSCaseInsensitiveSearch];
      if (range.location != NSNotFound) {
         [foundPeopleMutable addObject:person];
         [foundRangesMutable addObject:[NSValue valueWithRange:range]];
      }
   }];
   
   *foundPeople = foundPeopleMutable;
   *foundRanges = foundRangesMutable;
}

- (PCSAddressBookPerson *)getPersonWithRecordId:(ABRecordID)recordId {
   ABRecordRef personRef = ABAddressBookGetPersonWithRecordID(self.addressBookRef, recordId);
   if (! personRef)
      return nil;
   
   PCSAddressBookPerson *person = [[PCSAddressBookPerson alloc] initWithRecordRef:personRef];
   return person;
}

@end
