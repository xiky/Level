//
//  LevelView.m
//  Level
//
//  Created by dog_47 on 4/20/15.
//  Copyright (c) 2015 dog_47. All rights reserved.
//

#import "LevelView.h"
static int Level;
static BOOL AnimatedBool;
static float TheScale;

@implementation LevelView

-(id)initWithLevel:(int)theLevel Animated:(BOOL)value{
    Level=theLevel;
    AnimatedBool=value;
    
    self=[super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    
    if (self) {
        UIImage *image=[UIImage imageNamed:@"level_map_bg.png"];
        TheScale=[UIScreen mainScreen].bounds.size.width/320.0;
//        NSLog(@"缩放比例%f",TheScale);
        BGimage=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320*TheScale, 1124*TheScale)];
        [BGimage setImage:image];
        UIColor *color=[UIColor colorWithRed:114/255.0 green:214/255.0 blue:214/255.0 alpha:1];
        [BGimage setBackgroundColor:color];
        [self setUserInteractionEnabled:YES];
        [self setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 1124*TheScale)];
        [self addSubview:BGimage];
        self.scrollEnabled=NO;
        self.bounces=NO;
        self.showsVerticalScrollIndicator=NO;
        self.delaysContentTouches=YES;
        
        if (Level==1) {
            [self performSelector:@selector(LevelOneAnimation) withObject:nil afterDelay:1];
        }else{
            
        if (AnimatedBool==NO) {
            [self DrawLevel];
        }else{
            [self AnimateLevel];
        }
        }
    }
    return self;
}



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    UITouch *touch=[touches anyObject];
//    CGPoint location=[touch locationInView:self];
//    NSLog(@"%@",NSStringFromCGPoint(location));
}

-(void)DrawLevel{
    ArrayOfRoles=[NSMutableArray array];
    for (int i=1; i<=10; i++) {
        CALayer *theRole=[self RoleOfLevel:i];
        [ArrayOfRoles addObject:theRole];
    }
    if (Level-1>0) {
        for (int i=0; i<Level-1; i++) {
            [BGimage.layer insertSublayer:[ArrayOfRoles objectAtIndex:i] atIndex:0];
        }
    }
}

-(void)AnimateLevel{
    ArrayOfRoles=[NSMutableArray array];
    for (int i=1; i<=10; i++) {
        CALayer *theRole=[self RoleOfLevel:i];
        [ArrayOfRoles addObject:theRole];
    }
    if (Level-2>0) {
        for (int i=0; i<Level-2; i++) {
            [BGimage.layer insertSublayer:[ArrayOfRoles objectAtIndex:i] atIndex:0];
            
            //延迟执行每个角色动画
             [[ArrayOfRoles objectAtIndex:i] performSelector:@selector(addAnimation:forKey:) withObject:[self RoleAnimation] afterDelay:i*0.3];
        }
    }
    
    pointLayer=[CAShapeLayer layer];
    pointLayer.contents=(id)[UIImage imageNamed:[NSString stringWithFormat:@"level_map_bear_%d.png",Level-1]].CGImage;
    CAShapeLayer *modelLayer=[ArrayOfRoles objectAtIndex:Level-2];
    
    pointLayer.position=modelLayer.position;
    pointLayer.frame=modelLayer.frame;
    [BGimage.layer insertSublayer:pointLayer atIndex:1];
    [self performSelector:@selector(scroll) withObject:nil afterDelay:1];
}

-(CABasicAnimation *)RoleAnimation{
    CABasicAnimation *move=[CABasicAnimation animation];
    move.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    move.keyPath=@"position.x";
    move.byValue=@20;
    move.autoreverses=YES;
    move.duration=1;
    move.repeatDuration=9999;
    
    return move;
}

-(void)scroll{
    CALayer *theLayer=[ArrayOfRoles objectAtIndex:Level-1];
    if (theLayer.position.y-300>0) {
        
        if (Level==10) {
            [self setContentOffset:CGPointMake(0, (theLayer.position.y-400)/TheScale) animated:YES];
        }else{
            [self setContentOffset:CGPointMake(0, (theLayer.position.y-300)/TheScale) animated:YES];
        }
    }
    
    [self performSelector:@selector(Rotate) withObject:nil afterDelay:1];
}

-(void)Rotate{
    
    CABasicAnimation *zPosition = [CABasicAnimation animation];
    zPosition.keyPath = @"zPosition";
    zPosition.fromValue = @-1;
    zPosition.toValue = @2;
    zPosition.duration = 2;
    
    [pointLayer addAnimation:zPosition forKey:nil];
    
    [lightLayer removeFromSuperlayer];
    CABasicAnimation *FlipHorAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    FlipHorAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    FlipHorAnimation.fromValue = [NSNumber numberWithFloat:0];
    FlipHorAnimation.byValue = [NSNumber numberWithFloat:  10*M_PI];
    FlipHorAnimation.duration = 0.5;
    FlipHorAnimation.cumulative = YES;
    FlipHorAnimation.fillMode = kCAFillModeForwards;
    FlipHorAnimation.removedOnCompletion = NO;
    FlipHorAnimation.repeatCount=1;
    FlipHorAnimation.delegate = [AnimationBlockDelegate animationDelegateWithBeginning:^{
        
    } completion:^(BOOL finished) {
        
        CATransition *anim = [CATransition animation];
        anim.type = kCATransitionFade;
        anim.subtype = kCATransitionFromLeft;
        anim.duration = 0.5;
        anim.repeatCount=1;
        anim.delegate = [AnimationBlockDelegate animationDelegateWithBeginning:^{
            CALayer *current=[ArrayOfRoles objectAtIndex:Level-1];
            float boundsScale=current.bounds.size.width/32;
            
            pointLayer.contents = (id)[UIImage imageNamed:@"level_map_point.png"].CGImage;
            pointLayer.bounds = CGRectMake(0, 0, 32*boundsScale*0.5, 44*boundsScale*0.5);
            
        } completion:^(BOOL finished) {
            CALayer *theLayer=[ArrayOfRoles objectAtIndex:Level-2];
            [BGimage.layer addSublayer:theLayer];
            theLayer.zPosition=-1;
            [self startAnimation];
        }];;
        
        [pointLayer addAnimation:anim forKey:@"chompAnimation"];
        
        
    }];;
    
    [pointLayer addAnimation:FlipHorAnimation forKey:@"flipHor"];
}

- (void)startAnimation {
    UIBezierPath *path=[self GetPath:Level-1];
    
    CAKeyframeAnimation *moveAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    moveAnimation.path = path.CGPath;
    moveAnimation.duration = 2;
    
    moveAnimation.removedOnCompletion=NO;
    //moveAnimation.delegate=self;
    moveAnimation.fillMode=kCAFillModeForwards;
    //shapeLayer.path=path.CGPath;
    
    CABasicAnimation *scale=[CABasicAnimation animation];
    scale.keyPath=@"bounds";
    scale.byValue=[NSValue valueWithCGRect:CGRectMake(0, 0, 32/2.0, 44/2.0)];
    scale.duration=0.5;
    scale.autoreverses=YES;
    scale.repeatDuration=2;
    
    CABasicAnimation *zPosition = [CABasicAnimation animation];
    zPosition.keyPath = @"zPosition";
    zPosition.fromValue = @-1;
    zPosition.toValue = @2;
    zPosition.duration = 2;
    
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    animGroup.animations = [NSArray arrayWithObjects:moveAnimation,zPosition,scale, nil];
    animGroup.duration = 2;
    animGroup.removedOnCompletion=NO;
    animGroup.delegate=[AnimationBlockDelegate animationDelegateWithBeginning:^{
        [[ArrayOfRoles objectAtIndex:Level-2] addAnimation:[self RoleAnimation] forKey:nil];
    } completion:^(BOOL finished) {
        CABasicAnimation *FlipHorAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
        FlipHorAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        FlipHorAnimation.fromValue = [NSNumber numberWithFloat:0];
        FlipHorAnimation.byValue = [NSNumber numberWithFloat:  10*M_PI];
        FlipHorAnimation.duration = 0.5;
        FlipHorAnimation.cumulative = YES;
        FlipHorAnimation.fillMode = kCAFillModeForwards;
        FlipHorAnimation.removedOnCompletion = NO;
        FlipHorAnimation.repeatCount=0;
        FlipHorAnimation.delegate = [AnimationBlockDelegate animationDelegateWithBeginning:^{
            
        } completion:^(BOOL finished) {
            if(finished){
                CATransition *anim = [CATransition animation];
                anim.type = kCATransitionFade;
                anim.subtype = kCATransitionFromLeft;
                anim.duration = 0.5;
                anim.repeatCount=0;
                anim.delegate = [AnimationBlockDelegate animationDelegateWithBeginning:^{
                    CALayer *model=[ArrayOfRoles objectAtIndex:Level-1];
                    pointLayer.contents=model.contents;
                    pointLayer.position=model.position;
                    pointLayer.frame=model.frame;
                } completion:^(BOOL finished) {
                    if (finished) {
                    
                        self.scrollEnabled=YES;
                        lightLayer=[CAShapeLayer layer];
                        lightLayer.contents=(id)[UIImage imageNamed:@"level_map_light.png"].CGImage;
                        CALayer *model2=[ArrayOfRoles objectAtIndex:Level-1];
                        lightLayer.position=model2.position;
                        lightLayer.bounds=CGRectMake(0, 0, model2.frame.size.width*TheScale*2, model2.frame.size.width*TheScale*2);
                        
                        CABasicAnimation *light=[CABasicAnimation animationWithKeyPath:@"transform.rotation"];
                        light.fromValue = [NSNumber numberWithFloat:0];
                        light.byValue = [NSNumber numberWithFloat:  2*M_PI];
                        light.duration = 1.5;
                        light.cumulative = YES;
                        light.fillMode = kCAFillModeForwards;
                        light.removedOnCompletion = YES;
                        light.repeatCount=9999;
                        light.delegate=[AnimationBlockDelegate animationDelegateWithBeginning:^{
                        } completion:^(BOOL finished){
                            [lightLayer removeFromSuperlayer];
                        }];
                        [BGimage.layer insertSublayer:lightLayer atIndex:100];
                        [lightLayer addAnimation:light forKey:nil];
                    }
                }];
                [pointLayer addAnimation:anim forKey:@"chompAnimation"];
            }
        }];
        [pointLayer addAnimation:FlipHorAnimation forKey:@"chompAnimation"];
    }];;
    ;
    animGroup.fillMode=kCAFillModeForwards;
    [pointLayer addAnimation:animGroup forKey:@"moveAnimation"];
}


-(UIBezierPath *)GetPath:(int)theLevel{
    UIBezierPath *path = [UIBezierPath bezierPath];
    switch (theLevel) {
        case 1:
            [path moveToPoint:[self GetPosition:CGPointMake(180, 70)]];
            [path addLineToPoint:[self GetPosition:CGPointMake(220, 80)]];
            [path addLineToPoint:[self GetPosition:CGPointMake(180, 150)]];
            break;
        case 2:
            [path moveToPoint:[self GetPosition:CGPointMake(180, 150)]];
            [path addLineToPoint:[self GetPosition:CGPointMake(170, 180)]];
            [path addLineToPoint:[self GetPosition:CGPointMake(180, 210)]];
            break;
        case 3:
            [path moveToPoint:[self GetPosition:CGPointMake(180, 210)]];
            [path addLineToPoint:[self GetPosition:CGPointMake(143, 235)]];
            [path addLineToPoint:[self GetPosition:CGPointMake(175, 265)]];
            [path addLineToPoint:[self GetPosition:CGPointMake(162, 300)]];
            break;
        case 4:
            [path moveToPoint:[self GetPosition:CGPointMake(162, 300)]];
            [path addLineToPoint:[self GetPosition:CGPointMake(96, 341)]];
            [path addLineToPoint:[self GetPosition:CGPointMake(95, 375)]];
            [path addLineToPoint:[self GetPosition:CGPointMake(230, 395)]];
            break;
        case 5:
            [path moveToPoint:[self GetPosition:CGPointMake(230, 395)]];
            [path addLineToPoint:[self GetPosition:CGPointMake(226, 462)]];
            [path addLineToPoint:[self GetPosition:CGPointMake(190, 480)]];
            break;
        case 6:
            [path moveToPoint:[self GetPosition:CGPointMake(190, 480)]];
            [path addLineToPoint:[self GetPosition:CGPointMake(232, 541)]];
            [path addLineToPoint:[self GetPosition:CGPointMake(220, 580)]];
            break;
        case 7:
            [path moveToPoint:[self GetPosition:CGPointMake(220, 580)]];
            [path addLineToPoint:[self GetPosition:CGPointMake(170, 640)]];
            [path addLineToPoint:[self GetPosition:CGPointMake(150, 680)]];
            break;
        case 8:
            [path moveToPoint:[self GetPosition:CGPointMake(150, 680)]];
            [path addLineToPoint:[self GetPosition:CGPointMake(130, 750)]];
            [path addLineToPoint:[self GetPosition:CGPointMake(210, 770)]];
            break;
        case 9:
            [path moveToPoint:[self GetPosition:CGPointMake(210, 770)]];
            [path addLineToPoint:[self GetPosition:CGPointMake(200, 850)]];
            [path addLineToPoint:[self GetPosition:CGPointMake(180, 950)]];
            break;
    }
    return path;
}

-(CALayer *)RoleOfLevel:(int)theLevel{
    CALayer *role= [CALayer layer];
    switch (theLevel) {
        case 1:
            role.frame = CGRectMake(0, 0, 37, 35);
            role.position = [self GetPosition:CGPointMake(180, 70)];
            break;
        case 2:
            role.frame = CGRectMake(0, 0, 41, 39);
            role.position = [self GetPosition:CGPointMake(180,150)];
            break;
        case 3:
            role.frame = CGRectMake(0, 0, 55, 53);
            role.position = [self GetPosition:CGPointMake(180, 210)];
            break;
        case 4:
            role.frame = CGRectMake(0, 0, 68, 52);
            role.position = [self GetPosition:CGPointMake(162, 300)];
            break;
        case 5:
            role.frame = CGRectMake(0, 0, 56, 50);
            role.position = [self GetPosition:CGPointMake(230, 395)];
            break;
        case 6:
            role.frame = CGRectMake(0, 0, 76, 71);
            role.position = [self GetPosition:CGPointMake(190, 480)];
            break;
        case 7:
            role.frame = CGRectMake(0, 0, 80, 70);
            role.position = [self GetPosition:CGPointMake(220, 580)];
            break;
        case 8:
            role.frame = CGRectMake(0, 0, 101, 88);
            role.position =[self GetPosition: CGPointMake(150, 680)];
            break;
        case 9:
            role.frame = CGRectMake(0, 0, 115, 95);
            role.position = [self GetPosition:CGPointMake(210, 770)];
            break;
        case 10:
            role.frame = CGRectMake(0, 0, 128, 109);
            role.position = [self GetPosition:CGPointMake(180, 950)];
            break;
    }
    NSString *name=[NSString stringWithFormat:@"level_map_bear_%d.png",theLevel];
    role.contents = (id)[UIImage imageNamed:name].CGImage;
    return role;
}

-(void)LevelOneAnimation{
     CALayer *theRole=[self RoleOfLevel:1];
    //[BGimage.layer addSublayer:theRole];
    pointLayer=[CAShapeLayer layer];
    pointLayer.contents=(id)[UIImage imageNamed:@"level_map_point.png"].CGImage;
    pointLayer.frame=CGRectMake(0, 0, 32, 44);
    pointLayer.position=theRole.position;
    [BGimage.layer addSublayer:pointLayer];
    

    CABasicAnimation *FlipHorAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    FlipHorAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    FlipHorAnimation.fromValue = [NSNumber numberWithFloat:0];
    FlipHorAnimation.byValue = [NSNumber numberWithFloat:  10*M_PI];
    FlipHorAnimation.duration = 0.5;
    FlipHorAnimation.cumulative = YES;
    FlipHorAnimation.fillMode = kCAFillModeForwards;
    FlipHorAnimation.removedOnCompletion = NO;
    FlipHorAnimation.repeatCount=1;
    FlipHorAnimation.delegate = [AnimationBlockDelegate animationDelegateWithBeginning:^{
        
    } completion:^(BOOL finished) {
        
        CATransition *anim = [CATransition animation];
        anim.type = kCATransitionFade;
        anim.subtype = kCATransitionFromLeft;
        anim.duration = 0.5; 
        anim.repeatCount=1;
        anim.delegate = [AnimationBlockDelegate animationDelegateWithBeginning:^{
            
            pointLayer.contents = (id)[UIImage imageNamed:@"level_map_point.png"].CGImage;
            pointLayer.bounds = CGRectMake(0, 0, 32, 44);
            
        } completion:^(BOOL finished) {
            self.scrollEnabled=YES;
            pointLayer.contents = (id)[UIImage imageNamed:@"level_map_bear_1.png"].CGImage;
            pointLayer.bounds = CGRectMake(0, 0, 37, 35);
            pointLayer.zPosition=2;
            lightLayer=[CAShapeLayer layer];
            lightLayer.contents=(id)[UIImage imageNamed:@"level_map_light.png"].CGImage;
        
            lightLayer.position=theRole.position;
            lightLayer.bounds=CGRectMake(0, 0, 70*TheScale, 70*TheScale);
            [BGimage.layer addSublayer:lightLayer];
            
            CABasicAnimation *light=[CABasicAnimation animationWithKeyPath:@"transform.rotation"];
            light.fromValue = [NSNumber numberWithFloat:0];
            light.byValue = [NSNumber numberWithFloat:2*M_PI];
            light.duration = 1.5;
            light.cumulative = YES;
            light.fillMode = kCAFillModeForwards;
            light.removedOnCompletion = YES;
            light.repeatCount=999;
            light.delegate=[AnimationBlockDelegate animationDelegateWithBeginning:^{
            } completion:^(BOOL finished){
                [lightLayer removeFromSuperlayer];
            }];
            [lightLayer addAnimation:light forKey:nil];
            
    
        }];;
        
        [pointLayer addAnimation:anim forKey:@"chompAnimation"];
        
        
    }];;
    
    [pointLayer addAnimation:FlipHorAnimation forKey:@"flipHor"];

    
}

-(CGPoint)GetPosition:(CGPoint)thePoint{
    CGPoint RealPoint=CGPointMake(thePoint.x*TheScale, thePoint.y*TheScale);
    return RealPoint;
}



@end
