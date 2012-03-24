//
//  TweetsViewController.h
//  TweetBG
//
//  Created by Artur Shinkevich on 11-12-01.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetsViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) ACAccount *account;
@property (strong, nonatomic) id timeline;


@property (nonatomic, retain) NSManagedObject *referringObject;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
- (void)fetchData;
@end
