//
//  Tweet.h
//  TweetBG
//
//  Created by Artur Shinkevich on 11-12-02.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Account;

@interface Tweet : NSManagedObject

@property (nonatomic, retain) NSString * owner;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) Account *account;

@end
