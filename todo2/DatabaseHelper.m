//
//  DatabaseHelper.m
//  todo2
//
//  Created by Oliver Lennartsson on 2020-01-30.
//  Copyright © 2020 Oliver Lennartsson. All rights reserved.
//

#import "DatabaseHelper.h"
@import Firebase;
@import FirebaseDatabase;

@implementation DatabaseHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.ref = [[FIRDatabase database] reference];
    }
    return self;
}

#pragma mark - Add item to database
-(void)addItemToDatabase:(NSDictionary*)item{
    [[[self.ref child:@"tasks"] childByAutoId]setValue:item];
}
#pragma mark - Get item from database
-(NSDictionary*)getItemFromDatabase{
    [[self.ref child:@"tasks"]observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
     
     self.temp = snapshot.value;
     
    }];
    return self.temp;
}


@end
