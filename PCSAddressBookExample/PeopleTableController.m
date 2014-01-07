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



@end

@implementation PeopleTableController

- (id)init {
   if ((self = [super initWithStyle:UITableViewStylePlain])) {
   }
   return self;
}

- (void)viewDidLoad {
   [super viewDidLoad];
}

//====================================================================================================
#pragma mark - Table view
//====================================================================================================

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   return Section_Count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   static NSString *CellIdentifier = @"Cell";
   
   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   if (cell == nil) {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
   }
   
   cell.textLabel.text = @"hello";
   
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
