//
//  TweetComposeViewController.h
//  TweetBG
//
//  Created by Artur Shinkevich on 11-12-02.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Accounts/Accounts.h>

@class TweetComposeViewController;

enum TweetComposeResult {
    TweetComposeResultCancelled,
    TweetComposeResultSent,
    TweetComposeResultFailed
};
typedef enum TweetComposeResult TweetComposeResult;

@protocol TweetComposeViewControllerDelegate <NSObject>
- (void)tweetComposeViewController:(TweetComposeViewController *)controller didFinishWithResult:(TweetComposeResult)result;
@end




@interface TweetComposeViewController : UIViewController < UITextViewDelegate >

@property (strong, nonatomic) ACAccount *account;
@property CGFloat shiftForKeyboard;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *closeButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *sendButton;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UINavigationItem *titleView;

- (IBAction)sendTweet:(id)sender;
- (IBAction)cancel:(id)sender;



@property (nonatomic, assign) id<TweetComposeViewControllerDelegate> tweetComposeDelegate; 

@end
