//
//  DatabaseHelper.h
//  todo2
//
//  Created by Oliver Lennartsson on 2020-01-30.
//  Copyright © 2020 Oliver Lennartsson. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Firebase;
@import FirebaseDatabase;

NS_ASSUME_NONNULL_BEGIN

@interface DatabaseHelper : NSObject
@property (nonatomic) FIRDatabaseReference *ref;
@property (nonatomic) FIRDatabaseHandle *handle;
@property (nonatomic) NSDictionary *temp;

-(void)addItemToDatabase:(NSDictionary*)item;

-(NSDictionary*)getItemFromDatabase;

@end

NS_ASSUME_NONNULL_END
