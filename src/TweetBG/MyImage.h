//
//  MyImage.h
//  TweetBG
//
//  Created by Artur Shinkevich on 11-12-01.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (MyImage)

+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;

@end
