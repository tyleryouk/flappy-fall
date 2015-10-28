#import <Foundation/Foundation.h>

@interface Settings : NSObject <NSCoding>

//--- Edit Settings

@property (nonatomic, strong) NSNumber *GameCenterEnabled;
@property (nonatomic, strong) NSString *LeaderboardId;
@property (nonatomic, strong) NSString *SocialMessage;
@property (nonatomic, strong) NSString *AppId;

//--- Edit Animations

@property (nonatomic, strong) NSNumber *SplashFrames;
@property (nonatomic, strong) NSNumber *SplashDur;


//--- Game Customization
@property (nonatomic, strong) NSNumber *GameDuration;
@property (nonatomic, strong) NSNumber *RushActive;

@property (nonatomic, strong) NSString *FontName;
@property (nonatomic, strong) NSNumber *FontSize;
@property (nonatomic, strong) NSNumber *FontSizeTime;







@end