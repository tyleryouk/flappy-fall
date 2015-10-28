//
//  Object.h
//  One Dreamer Company
//  www.one-dreamer.com
//  Copyright (c) 2014 One Dreamer Company. All rights reserved.


/*    Object Class
  ---------
 |  0   0  |
 |    X    |
 |         |
  ---------
*/


//-- Import Required Frameworks/Header Files
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Settings.h"


@interface Object : UIImageView
{
}


//-- Properties
@property float Vely;
@property BOOL CollideFloor;
@property int Type;


//-- Settings Property
@property (nonatomic, strong) Settings *Settings;


//-- Methodes
-(UIImageView*)createObj:(int)posx posy:(int)posy;
-(CGRect)updateObj:(CGRect)FloorFrame;


@end
