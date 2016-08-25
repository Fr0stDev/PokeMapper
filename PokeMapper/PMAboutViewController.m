//
//  PMAboutViewController.m
//  PokeMapper
//
//  Created by Guillermo Moran on 7/24/16.
//  Copyright © 2016 Guillermo Moran. All rights reserved.
//

#import "PMAboutViewController.h"

@interface PMAboutViewController ()

@end

@implementation PMAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews {
    [textView setContentOffset:CGPointZero animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
