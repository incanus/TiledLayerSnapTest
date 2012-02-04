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

#import "/Developer/SDKs/MacOSX10.7.sdk/System/Library/Frameworks/Foundation.framework/Versions/C/Headers/NSTask.h"

@implementation DSMRViewController

@synthesize segmentedControl;
@synthesize containerView;

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSAssert([[[UIDevice currentDevice] model] isEqualToString:@"iPhone Simulator"], @"must run in simulator in order to use NSTask");
    
    [self.segmentedControl addTarget:self action:@selector(changedSegment:) forControlEvents:UIControlEventValueChanged];

    [self changedSegment:self];
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
        
        ((RMMapView *)newView).decelerationMode = RMMapDecelerationFast;
    }

    [self.containerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    [self.containerView addSubview:newView];
}

- (IBAction)tappedGetSnapshot:(id)sender
{
    if ([[self.containerView.subviews lastObject] isKindOfClass:[RMMapView class]])
    {
        RMMapView *mapView       = (RMMapView *)[self.containerView.subviews lastObject];
        UIScrollView *scrollView = (UIScrollView *)[mapView.subviews objectAtIndex:1];
        UIView *tiledView        = (UIView *)[scrollView.subviews lastObject];
        CATiledLayer *tiledLayer = (CATiledLayer *)tiledView.layer;
        
        CGSize tileSize = tiledLayer.tileSize;
    
        int tilesX, tilesY = 0;
    
        tilesX = ceil(scrollView.frame.size.width  / tileSize.width);
        tilesY = ceil(scrollView.frame.size.height / tileSize.height);
        
        UIGraphicsBeginImageContext(CGSizeMake(tilesX * tileSize.width, tilesY * tileSize.height));
        
        for (int col = 0; col < tilesX; col++)
        {
            for (int row = 0; row < tilesY; row++)
            {
                UIGraphicsBeginImageContext(tileSize);

                CGContextRef sourceContext = UIGraphicsGetCurrentContext();
    
                CGRect clipRect = CGRectMake(scrollView.contentOffset.x + (col * tileSize.width), 
                                             scrollView.contentOffset.y + (row * tileSize.height), 
                                             tileSize.width, 
                                             tileSize.height);
                       
                CGContextTranslateCTM(sourceContext, -clipRect.origin.x, -clipRect.origin.y);
                       
                CGContextScaleCTM(sourceContext, scrollView.zoomScale, scrollView.zoomScale);

                [tiledLayer renderInContext:sourceContext];
                       
                UIImage *tileImage = UIGraphicsGetImageFromCurrentImageContext();
                
                UIGraphicsEndImageContext();

                [tileImage drawInRect:CGRectMake(col * tileSize.width, 
                                                 row * tileSize.height,
                                                 tileSize.width, 
                                                 tileSize.height)];
            }
        }
        
        UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();

        UIGraphicsEndImageContext();
        
        [UIImagePNGRepresentation(finalImage) writeToFile:[NSString stringWithFormat:@"/tmp/snapshot.png"] atomically:YES];

        [NSTask launchedTaskWithLaunchPath:@"/usr/bin/open" arguments:[NSArray arrayWithObject:@"/tmp/snapshot.png"]];
    }
}

@end