//====================================================================================================
// Author: Peter Chen
// Created: 1/7/14
// Copyright 2014 Peter Chen
//====================================================================================================

#import "PeopleTableController.h"

typedef NS_ENUM(int, Sections) {
   Section_Hello,
   Section_Count
};

@interface PeopleTableController()

@property (nonatomic, strong) NSArray *people;

@end

@implementation PeopleTableController

- (id)initWithGroup:(PCSAddressBookGroup *)group {
   if ((self = [super initWithStyle:UITableViewStylePlain])) {
      self.group = group;
   }
   return self;
}

- (void)viewDidLoad {
   [super viewDidLoad];
   self.people = self.group ? [self.group getAllMembers] : [[PCSAddressBook addressBook] getAllPeople];
}

//====================================================================================================
#pragma mark - Table view
//====================================================================================================

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   return Section_Count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return [self.people count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   static NSString *CellIdentifier = @"Cell";
   
   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   if (cell == nil) {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
   }
   
   PCSAddressBookPerson *person = self.people[indexPath.row];
   cell.textLabel.text = person.fullName;
   
   return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   if (Section_Hello == indexPath.section) {
      
   }
}

//====================================================================================================
#pragma mark - Events
//====================================================================================================



@end
