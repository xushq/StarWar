//
//  SRSpaceLayer.m
//  StarWar
//
//  Created by XuShuangqing on 14-4-12.
//  Copyright (c) 2014年 XuShuangqing. All rights reserved.
//
#import "GB2ShapeCache.h"

#import "SRSpaceLayer.h"
#import "SRSpaceShip.h"
#import "SRConstants.h"
#import "SRControlLayer.h"
#import "SREarth.h"
#import "SRStar.h"
#import "SRContactListener.h"

#import "SRBullet.h"
#import "SRBulletBatch.h"

#import "SRLaser.h"
#import "SRPlaneBatch.h"
#import "SRPlane.h"

@interface SRSpaceLayer(){
    b2World* _world;
    SRSpaceShip* _spaceShip;
    SREarth* _earth;
    SRStar *_star;
    SRLaser *_laser;
    SRPlaneBatch* _planeBatch;
    
    GLESDebugDraw *m_debugDraw;
    b2RayCastInput _input;
    b2RayCastOutput _output;
    
    SRContactListener *listener;
}
@end


@implementation SRSpaceLayer

+(CCScene *) scene
{
    //Create a new Scene which is the main scene of this game.
    CCScene *scene = [CCScene node];
    
    SRSpaceLayer *layer = [SRSpaceLayer node];
    [scene addChild: layer];
    
    SRControlLayer *controlLayer = [SRControlLayer node];
    [scene addChild:controlLayer z:zControlLayer tag:kTagControlLayer];
    
    return scene;
}

-(id) init
{
    if (self = [super init]) {
        
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"test.plist"];
        
        [self initPhysics];
        [self registerNotifications];
        [self initEarth];
        [self initSpaceShip];
        [self initStars];
        [self initLaser];
        [self initPlaneBatch];
        
        [self setAnchorPoint:ccp(0.5,PTM_RATIO*_earth.geocentric.y/[UIScreen mainScreen].bounds.size.width)];
        
        /* Only set scheduleUpdate, the update function can work*/
        [self scheduleUpdate];
    }
    return self;
}

-(void) registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameOver:) name:NSNotificationNameSpaceShipDown object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameOver:) name:NSNotificationNameSpaceShipTouchPlane object:nil];
}

-(void) initPhysics
{
    //Create the world
    b2Vec2 gravity(0,0);
    _world = new b2World(gravity);
    
    _world->SetAllowSleeping(true);
	_world->SetContinuousPhysics(true);
    
    m_debugDraw = new GLESDebugDraw(PTM_RATIO);
	_world->SetDebugDraw(m_debugDraw);

    m_debugDraw->SetFlags(b2Draw::e_shapeBit);
    
    listener = new SRContactListener();
    _world->SetContactListener(listener);
}

-(void) initSpaceShip
{
    _spaceShip = [SRSpaceShip spriteWithFile:@"spaceShip.png"];
    //_spaceShip.scale = 0.15;
    
    b2Vec2 position(2, 3);
    b2Vec2 velocity(0.7, 0.7);
    
    [_spaceShip createBodyForWorld:_world withPosition:position withGeocentric:_earth.geocentric withVelocity:velocity];
    
    [self addChild:_spaceShip];
}

-(void) initEarth
{
    _earth = [SREarth spriteWithFile:@"blocks.png"];
    _earth.scale = 0.57;
    [_earth createBodyForWorld:_world withRadius:11.5f withAngularVelocity:0];
    
    [self addChild:_earth];
}

-(void) initStars
{
    _star = [SRStar node];
    b2Vec2 p(0,0);
    [_star createBodyForWorld:_world withPosition:p];
}

/*This function will not be used now*/
-(void) initBullets
{
    SRBulletBatch *bulletBatch = [SRBulletBatch batchNodeWithFile:@"blocks.png"];
    [bulletBatch createBulletBatchForWorld:_world withSpaceShip:_spaceShip];
    [self addChild:bulletBatch];
}

-(void) initLaser
{
    _laser = [SRLaser node];
    [_laser createBodyForWorld:_world withPosition:_spaceShip.b2Body->GetPosition() withRotation:0];
    [self addChild:_laser];
}

-(void) initPlaneBatch
{
    _planeBatch = [SRPlaneBatch batchNodeWithFile:@"plane.png"];
    [_planeBatch createPlaneBatchForWorld:_world withGeocentric:_earth.geocentric];
    [self addChild:_planeBatch];
}

-(void) gameOver: (NSNotification *) notification
{
    NSLog(@"Game Over!!!!!");
    for (CCNode* node in self.children) {
        [node unscheduleAllSelectors];
        [node unscheduleUpdate];
    }
    [self unscheduleAllSelectors];
    [self unscheduleUpdate];
    
    SRControlLayer* controlLayer = [[[CCDirector sharedDirector] runningScene] getChildByTag:kTagControlLayer];
    controlLayer.gameOverMenu.visible = true;
    
}

-(void) draw {
    [super draw];
	
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
	
	kmGLPushMatrix();
	
	_world->DrawDebugData();
	
	kmGLPopMatrix();
}

-(void) update: (ccTime) dt
{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	_world->Step(dt, velocityIterations, positionIterations);

    float angle = atan(([[UIScreen mainScreen] bounds].size.height/2-_spaceShip.position.x)/(_spaceShip.position.y-_earth.geocentric.y*PTM_RATIO));
    angle = CC_RADIANS_TO_DEGREES(angle);
    
    if ((_spaceShip.position.y-_earth.geocentric.y*PTM_RATIO) >= 0)
        [self setRotation:angle];
    else
        [self setRotation:180+angle];
    
    float velocityAngle = atan((_spaceShip.b2Body->GetLinearVelocity()).y/(_spaceShip.b2Body->GetLinearVelocity()).x);
    velocityAngle = CC_RADIANS_TO_DEGREES(velocityAngle);
    _laser.position = _spaceShip.position;
    
    if ((_spaceShip.b2Body->GetLinearVelocity()).x >= 0)
    {
        _laser.rotation = velocityAngle;
        _spaceShip.rotation = velocityAngle;
    }
    else
    {
        _laser.rotation = velocityAngle + 180;
        _spaceShip.rotation = velocityAngle + 180;
    }
    
    [self destoryPlane];
}

-(void) destoryPlane
{
    _input.p1 = _spaceShip.b2Body->GetPosition();
    _input.p2 = b2Vec2((_spaceShip.b2Body->GetPosition()).x+(_spaceShip.b2Body->GetLinearVelocity()).x, (_spaceShip.b2Body->GetPosition()).y+(_spaceShip.b2Body->GetLinearVelocity()).y);
    _input.maxFraction = 100;
    
    float minFraction = _input.maxFraction;
    SRPlane* touchedPlane = nil;
    
    for (SRPlane* plane in _planeBatch.children) {
        for (b2Fixture* fixture = plane.b2Body->GetFixtureList(); fixture; fixture = fixture->GetNext()) {
            if (fixture->RayCast(&_output, _input, 0)) {
                if (_output.fraction < minFraction) {
                    minFraction = _output.fraction;
                    touchedPlane = plane;
                }
            }
        }
    }
    
    if (touchedPlane) {
        _world->DestroyBody(touchedPlane.b2Body);
        [_planeBatch removeChild:touchedPlane];
    }
}

-(void) dealloc
{
	delete _world;
	_world = NULL;
    
    delete listener;
	
	delete m_debugDraw;
	m_debugDraw = NULL;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}


@end
