//====================================================================================================
// Author: Peter Chen
// Created: 1/7/14
// Copyright 2014 Peter Chen
//====================================================================================================

#import <UIKit/UIKit.h>
#import "PCSAddressBook.h"
#import "PCSAddressBookGroup.h"
#import "PCSAddressBookPerson.h"

@interface PeopleTableController : UITableViewController

@property (nonatomic, strong) PCSAddressBookGroup *group;

- (id)initWithGroup:(PCSAddressBookGroup *)group;

@end
