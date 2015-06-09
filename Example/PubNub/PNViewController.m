//
//  PNViewController.m
//  PubNub
//
//  Created by Jordan Zucker on 06/03/2015.
//  Copyright (c) 2014 Jordan Zucker. All rights reserved.
//

#import <JSZVCR/JSZVCR.h>

#import "PNViewController.h"

@interface PNViewController ()
@property (nonatomic, weak) IBOutlet UIButton *saveButton;
@end

@implementation PNViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.saveButton addTarget:self action:@selector(saveButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveButtonTapped:(UIButton *)saveButton {
    [[JSZVCR sharedInstance] dumpRecordingsToFile:@"test"];
}

@end
