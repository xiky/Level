//
//  ViewController.m
//  Level
//
//  Created by XiaoJing Li on 5/20/15.
//  Copyright (c) 2015 XiaoJingLi. All rights reserved.
//

#import "ViewController.h"
#import "LevelView.h"

@interface ViewController ()

@end

@implementation ViewController{
    LevelView *theView;
    UIButton *back;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    UILabel *theLabel=[[UILabel alloc]initWithFrame:CGRectMake(150, 50, 200, 40)];
    theLabel.text=@"升级页面";

    theLabel.textColor=[UIColor blackColor];
    [self.view addSubview:theLabel];
    

    for (int i=0; i<10; i++) {
        UIButton *theButton=[[UIButton alloc]initWithFrame:CGRectMake((i%3)*100+50, (i/3)*100+150, 50, 50)];
        theButton.backgroundColor=[UIColor grayColor];
        theButton.tag=i+1;
        theButton.layer.cornerRadius=25;
        [theButton addTarget:self action:@selector(LevelUpto:) forControlEvents:UIControlEventTouchDown];
        [theButton setTitle:[NSString stringWithFormat:@"%ld",theButton.tag] forState:UIControlStateNormal];
        
        [self.view addSubview:theButton];
    }
}

-(void)LevelUpto:(UIButton *)theButton{
    
    int Level=(int)theButton.tag;
    theView=[[LevelView alloc]initWithLevel:Level Animated:YES];
    [self.view addSubview:theView];
    
    back=[[UIButton alloc]initWithFrame:CGRectMake(20, 20, 50, 50)];
    back.backgroundColor=[UIColor whiteColor];
    back.layer.cornerRadius=25;
    [back setTitle:@"返回" forState:UIControlStateNormal];
    [back setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:back];
    
    [back addTarget:self action:@selector(removeView) forControlEvents:UIControlEventTouchDown];
}
-(void)removeView{
    [theView removeFromSuperview];
    [back removeFromSuperview];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
