//
//  LevelView.h
//  Level
//
//  Created by dog_47 on 4/20/15.
//  Copyright (c) 2015 dog_47. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnimationBlockDelegate.h"

@interface LevelView : UIScrollView{
    UIImageView *BGimage;
    NSMutableArray *ArrayOfRoles;
    CAShapeLayer *pointLayer;
    CAShapeLayer *lightLayer;

}

-(id)initWithLevel:(int)theLevel Animated:(BOOL)value;

@end
