//
//  AnimationBlockDelegate.h
//  Level
//
//  Created by dog_47 on 4/20/15.
//  Copyright (c) 2015 dog_47. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>


@interface AnimationBlockDelegate : NSObject

@property (copy) void(^start)(void);
@property (copy) void(^stop)(BOOL);

+(instancetype)animationDelegateWithBeginning:(void(^)(void))beginning
                                   completion:(void(^)(BOOL finished))completion;

@end

