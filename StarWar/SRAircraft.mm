//
//  SRAircraft.m
//  StarWar
//
//  Created by XuShuangqing on 14-4-23.
//  Copyright (c) 2014年 XuShuangqing. All rights reserved.
//

#import "SRAircraft.h"
#import "SRConstants.h"

@implementation SRAircraft

- (void)update:(ccTime)delta
{
    float sqrRadius = powf((self.b2Body->GetPosition()).x-_geocentric.x, 2.0) + powf((self.b2Body->GetPosition()).y-_geocentric.y, 2.0);
    float radius = sqrtf(sqrRadius);
    
    float force = GM/sqrRadius;
    float forceY = force/radius*(_geocentric.y-(self.b2Body->GetPosition()).y)*(self.b2Body->GetMass());
    float forceX = force/radius*(_geocentric.x-(self.b2Body->GetPosition()).x)*(self.b2Body->GetMass());
    
    b2Vec2 forceVec(forceX, forceY);
    
    self.b2Body->ApplyForce(forceVec, self.b2Body->GetWorldCenter());
}

@end
