//
//  DSMRViewController.m
//  TiledLayerSnapTest
//
//  Created by Justin Miller on 2/2/12.
//  Copyright (c) 2012 Development Seed. All rights reserved.
//

#import "DSMRViewController.h"

#import "RMMapView.h"

#import <QuartzCore/QuartzCore.h>

@implementation DSMRViewController

@synthesize segmentedControl;
@synthesize containerView;

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.segmentedControl addTarget:self action:@selector(changedSegment:) forControlEvents:UIControlEventValueChanged];

    [self changedSegment:self];
    
    [RMMapView class]; // avoid code stripping
}

- (void)changedSegment:(id)sender
{
    UIView *newView = nil;
    
    if (self.segmentedControl.selectedSegmentIndex == 0)
    {
        // switch to normal UIView
        //
        newView = [[UIView alloc] initWithFrame:self.containerView.bounds];
        
        newView.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.2];
    }
    else
    {
        // switch to UIScrollView-based map view
        //
        newView = [[RMMapView alloc] initWithFrame:self.containerView.bounds];
    }

    [self.containerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    [self.containerView addSubview:newView];
}

- (IBAction)tappedGetSnapshot:(id)sender
{
    UIGraphicsBeginImageContext(self.view.bounds.size);
    
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    [UIImagePNGRepresentation(image) writeToFile:[NSString stringWithFormat:@"/tmp/snapshot.png"] atomically:YES];

    [[[UIAlertView alloc] initWithTitle:@"Snapshot Saved" message:@"Check /tmp/snapshot.png" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
}

@end