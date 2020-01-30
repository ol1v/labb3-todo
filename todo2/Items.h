//
//  Items.h
//  todo2
//
//  Created by Oliver Lennartsson on 2020-01-30.
//  Copyright © 2020 Oliver Lennartsson. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Items : NSObject

@property (nonatomic) NSMutableArray *items;
@property (nonatomic) NSMutableArray *completed;
@property (nonatomic) NSMutableArray *sections;

@end

NS_ASSUME_NONNULL_END
