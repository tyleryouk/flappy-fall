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
#import "Object.h"


@implementation Object
@synthesize Vely;


//----- Create Object -----
-(UIImageView*)createObj:(int)posx posy:(int)posy{
    
    //-- Load the settings.plist file
    self.Settings = [[Settings alloc] init];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"Settings"]
                                                         ofType:@"plist"];
    
    self.Settings = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    
    //-- Determine Object Ratio (Device)
    float Ratio;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        Ratio = 1;
    }else{
        Ratio = 2;
    }
    
    //-- Create frame & Prepare to load images
    self.frame = CGRectMake(posx, posy, 40 * Ratio, 40 * Ratio);
    
    // Randomly Choose an image
    self.Type = 1;
    int rand = arc4random() % 3;
    self.image = [UIImage imageNamed:[NSString stringWithFormat:@"Object_%d", 1 + rand]];
    
    
    // Rotate Randomly
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    int temp = (arc4random() % 10);
    animation.fromValue = [NSNumber numberWithFloat:0.0f];
    if ((arc4random() % 2) == 1) temp = temp *-1;
    animation.toValue = [NSNumber numberWithFloat:(2+temp * M_PI)];
    animation.duration = 6.0f;
    animation.fillMode = kCAFillModeForwards;
    [self.layer addAnimation:animation forKey:@"Rotate"];
    
    //-- Determine Object Velocity/Speed
    self.Vely  = [self randomFloatBetween:1.5 and:3];
    self.Vely = self.Vely * Ratio;
    
    // Set Userinteraction
    self.userInteractionEnabled = TRUE;
    self.multipleTouchEnabled = TRUE;
    
    return self;
}


//----- Update Object -----
-(CGRect)updateObj:(CGRect)FloorFrame{
    
    //-- Return Object Position
    return CGRectMake(self.frame.origin.x, self.frame.origin.y + self.Vely, self.frame.size.width, self.frame.size.height);
    
}


//----- Return Random Number Between Float -----
-(float)randomFloatBetween:(float)smallNumber and:(float)bigNumber {
    
    float diff = bigNumber - smallNumber;
    return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
}


@end
