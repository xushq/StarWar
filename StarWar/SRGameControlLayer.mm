//
//  SRGameControlLayer.m
//  StarWar
//
//  Created by Shuangqing on 14-10-26.
//  Copyright (c) 2014年 XuShuangqing. All rights reserved.
//

#import "cocos2d.h"
#import "SRGameControlLayer.h"

@implementation SRGameControlLayer
{
    CCLabelAtlas* _label;
    SRGameStatus _currentStatus;
    CCMenuItem *_pauseButton;
    CCMenuItem *_resumeButton;
    CCMenuItem *_restartButton;
    CCLayerColor *_mask;
}

- (id)init
{
    if (self = [super init]) {
        [self initButton];
        [self initMask];
        _currentStatus = SRStatusRunning;
        [self updateStatus];
    }
    return self;
}

- (void)initMask
{
    _mask = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 200)];
    [self addChild:_mask z:100];
    [_mask setVisible:NO];
}

- (void)initButton
{
    _pauseButton = [CCMenuItemImage itemWithNormalImage:@"buttonPause@2x.png" selectedImage:@"buttonPause@2x.png" target:self selector:@selector(pauseButtonPressed:)];
    _pauseButton.anchorPoint = ccp(0, 0.5);
    _pauseButton.position = ccp(20., [UIScreen mainScreen].bounds.size.width-35.);
    
    _resumeButton = [CCMenuItemImage itemWithNormalImage:@"buttonResume@2x.png" selectedImage:@"buttonResume@2x.png" target:self selector:@selector(resumeButtonPressed:)];
    _resumeButton.anchorPoint = ccp(0.5, 0.5);
    _resumeButton.position = ccp([UIScreen mainScreen].bounds.size.height/3., [UIScreen mainScreen].bounds.size.width/2.);
    
    _restartButton = [CCMenuItemImage itemWithNormalImage:@"buttonContinue@2x.png" selectedImage:@"buttonContinue@2x.png" target:self selector:@selector(restartButtonPressed:)];
    _restartButton.anchorPoint = ccp(0.5, 0.5);
    _restartButton.position = ccp([UIScreen mainScreen].bounds.size.height*2./3., [UIScreen mainScreen].bounds.size.width/2.);
    
    CCMenu *controlMenu = [CCMenu menuWithItems:_pauseButton,_resumeButton,_restartButton, nil];
    controlMenu.position = CGPointZero;
    [self addChild:controlMenu z:200];
}

- (void)updateStatus
{
    switch (_currentStatus) {
        case SRStatusRunning:
            _pauseButton.visible = YES;
            _resumeButton.visible = NO;
            _restartButton.visible = NO;
            [_mask setVisible:NO];
            break;
        case SRStatusPause:
            _pauseButton.visible = NO;
            _resumeButton.visible = YES;
            _restartButton.visible = YES;
            [_mask setVisible:YES];
            break;
        case SRStatusOther:
            break;
        default:
            break;
    }
}

- (void)changeGameStatusTo:(SRGameStatus)status
{
    _currentStatus = status;
    [self updateStatus];
}


#pragma mark - Buttons

- (void)pauseButtonPressed:(id)sender
{
    [self.delegate gameControlLayerDidPressPauseButton:self];
}

- (void)resumeButtonPressed:(id)sender
{
    [self.delegate gameControlLayerDidPressResumeButton:self];
}

- (void)restartButtonPressed:(id)sender
{
    [self.delegate gameControlLayerDidPressRestartButton:self];
}

@end