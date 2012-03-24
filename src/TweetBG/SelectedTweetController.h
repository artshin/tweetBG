//
//  SelectedTweetController.h
//  TweetBG
//
//  Created by Artur Shinkevich on 11-12-02.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectedTweetController : UIViewController


@property (retain, nonatomic) IBOutlet UIImageView *UserImage;
@property (retain, nonatomic) IBOutlet UILabel *UserName;
@property (retain, nonatomic) IBOutlet UITextView *UserTweet;

@property (nonatomic, retain) NSManagedObject *referringObject;
@property (nonatomic, retain) UIImage *tempImage;
@property (nonatomic, retain) NSString *tempName;
@property (nonatomic, retain) NSString *tempTweet;

@end
