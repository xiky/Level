//
//  AnimationBlockDelegate.m
//  Level
//
//  Created by dog_47 on 4/20/15.
//  Copyright (c) 2015 dog_47. All rights reserved.
//

#import "AnimationBlockDelegate.h"

@implementation AnimationBlockDelegate

+ (instancetype)animationDelegateWithBeginning:(void (^)(void))beginning
                                    completion:(void (^)(BOOL))completion
{
    AnimationBlockDelegate *result = [AnimationBlockDelegate new];
    result.start = beginning;
    result.stop  = completion;
    return result;
}

- (void)animationDidStart:(CAAnimation *)anim
{
    if (self.start) {
        self.start();
    }
    self.start = nil;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (self.stop) {
        self.stop(flag);
    }
    self.stop = nil;
}

@end

