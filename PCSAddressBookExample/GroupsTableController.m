//====================================================================================================
// Author: Peter Chen
// Created: 1/7/14
// Copyright 2014 Peter Chen
//====================================================================================================

#import "GroupsTableController.h"
#import "PCSAddressBook.h"
#import "PCSAddressBookGroup.h"
#import "PCSAddressBookPerson.h"
#import "PeopleTableController.h"

typedef NS_ENUM(int, Sections) {
   Section_Hello,
   Section_Count
};

@interface GroupsTableController()

@property (nonatomic, strong) NSMutableArray *groups;

@end

@implementation GroupsTableController

- (id)init {
   if ((self = [super initWithStyle:UITableViewStylePlain])) {
      self.groups = [NSMutableArray array];
   }
   return self;
}

- (void)viewDidLoad {
   [super viewDidLoad];
   self.title = @"Groups";
   
   [[PCSAddressBook addressBook] requestAccessWithCompletion:^(BOOL granted, NSError *error) {
      [self.groups setArray:[PCSAddressBook addressBook].groups];
      [self.tableView reloadData];
   }];
}

//====================================================================================================
#pragma mark - Table view
//====================================================================================================

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   return Section_Count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return [self.groups count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   static NSString *CellIdentifier = @"Cell";
   
   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   if (cell == nil) {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
   }
   
   if (indexPath.row == [self.groups count]) {
      cell.textLabel.text = @"All Contacts";
   }
   else {
      PCSAddressBookGroup *group = self.groups[indexPath.row];
      cell.textLabel.text = group.name;
   }
   
   return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   if (Section_Hello == indexPath.section) {
      if (indexPath.row == [self.groups count]) {
         PeopleTableController *controller = [[PeopleTableController alloc] initWithGroup:nil];
         [self.navigationController pushViewController:controller animated:YES];
      }
      else {
         PCSAddressBookGroup *group = self.groups[indexPath.row];
         PeopleTableController *controller = [[PeopleTableController alloc] initWithGroup:group];
         [self.navigationController pushViewController:controller animated:YES];
      }
   }
}

//====================================================================================================
#pragma mark - Events
//====================================================================================================



@end
