//
//  GameView.h
//  One Dreamer Company
//  www.one-dreamer.com
//  Copyright (c) 2014 One Dreamer Company. All rights reserved.


//-- Import Required Frameworks/Header Files
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <StoreKit/StoreKit.h>
#import <GameKit/GameKit.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "Settings.h"


@interface GameView : UIViewController <GKGameCenterControllerDelegate, AVAudioPlayerDelegate>
{
    
    // Object Array
    NSMutableArray *ObjectArray;
    
    // Misc Varibles
    CGSize screenSize;
    int Phase;
    int Points;
    int Difficulty;
    BOOL ScoreAnimation;
    float Ratio;
    
    // Timers - Control the game loops
    NSTimer *objTimer;
    NSTimer *gameTimer;
    float ObjTimer;

    // Game Duration
    NSTimer *gameOverTimer;
    int GameTimeCount;
    
    // Core
    UIImageView *ani_text1;
    dispatch_queue_t playQueue ;
    UIViewController *vc;
    SLComposeViewController *mySLComposerSheet;
    
}


// The Settings Property
@property (nonatomic, strong) Settings *Settings;


// Game Properties
@property (weak, nonatomic) IBOutlet UIImageView *Floor;
@property (weak, nonatomic) IBOutlet UIImageView *Flash;


// UI Properties
@property (weak, nonatomic) IBOutlet UIImageView *Brief;
@property (weak, nonatomic) IBOutlet UILabel *ScoreLabel;
@property (weak, nonatomic) IBOutlet UIButton *GameCenterButton;
@property (weak, nonatomic) IBOutlet UILabel *GameTimerLabel;
@property (weak, nonatomic) IBOutlet UIButton *RateButton;
@property (weak, nonatomic) IBOutlet UIButton *FacebookButton;
@property (weak, nonatomic) IBOutlet UIButton *TwitterButton;
@property (weak, nonatomic) IBOutlet UIImageView *BestImg;
@property (weak, nonatomic) IBOutlet UIButton *MusicButton;


// Audio Player
@property (strong, nonatomic) AVAudioPlayer *player;


@end
