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

#import "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.7.sdk/System/Library/Frameworks/Foundation.framework/Versions/C/Headers/NSTask.h"

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

- (void)writeAndOpenImage:(UIImage *)image
{
    NSString *filename = [[NSProcessInfo processInfo] globallyUniqueString];
    
    [UIImagePNGRepresentation(image) writeToFile:[NSString stringWithFormat:@"/tmp/%@.png", filename] atomically:YES];
    
    [NSTask launchedTaskWithLaunchPath:@"/usr/bin/open" arguments:[NSArray arrayWithObject:[NSString stringWithFormat:@"/tmp/%@.png", filename]]];
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
    
//        float scale = scrollView.zoomScale;
//        NSLog(@"scale: %f", scale);
        
        float zoom = ceilf(log2f(scrollView.zoomScale));
//        NSLog(@"zoom: %f", zoom);

        float factor = tiledView.frame.size.width / (tileSize.width * powf(2, zoom));
//        NSLog(@"factor: %f", factor);

        int perceivedTileSize = (int)(tileSize.width * factor);
//        NSLog(@"perceived tile size: %i", perceivedTileSize);

        float xoffset = scrollView.contentOffset.x;
        float yoffset = scrollView.contentOffset.y;
//        NSLog(@"offset: %f, %f", xoffset, yoffset);
        
//        float xtile = roundf((xoffset * (tileSize.width  / perceivedTileSize)) / tileSize.width);
//        float ytile = roundf((yoffset * (tileSize.height / perceivedTileSize)) / tileSize.height);
//        NSLog(@"tile: %f, %f", xtile, ytile);

        int tilesX = ceil(scrollView.frame.size.width  / perceivedTileSize) + 1;
        int tilesY = ceil(scrollView.frame.size.height / perceivedTileSize) + 1;
//        NSLog(@"tiles: %ix%i", tilesX, tilesY);
        
        UIGraphicsBeginImageContext(CGSizeMake(tilesX * perceivedTileSize, tilesY * perceivedTileSize));
        
//        CGContextRef destinationContext = UIGraphicsGetCurrentContext();
        
        CGRect clipRect;
        
        // TODO: parallelize
        //
        for (int col = 0; col < tilesX; col++)
        {
            for (int row = 0; row < tilesY; row++)
            {
                UIGraphicsBeginImageContext(tileSize);

                CGContextRef sourceContext = UIGraphicsGetCurrentContext();
                
                clipRect = CGRectMake(((xoffset / factor) + (col * tileSize.width)), 
                                      ((yoffset / factor) + (row * tileSize.height)), 
                                      tileSize.width, 
                                      tileSize.height);

                CGContextTranslateCTM(sourceContext, -clipRect.origin.x, -clipRect.origin.y);
                       
                CGContextScaleCTM(sourceContext, scrollView.zoomScale / factor, scrollView.zoomScale / factor);

                [tiledLayer renderInContext:sourceContext];
                       
                UIImage *tileImage = UIGraphicsGetImageFromCurrentImageContext();
                
                UIGraphicsEndImageContext();

//                [self writeAndOpenImage:tileImage];
                
                [tileImage drawInRect:CGRectMake(col * perceivedTileSize, 
                                                 row * perceivedTileSize,
                                                 perceivedTileSize, 
                                                 perceivedTileSize)];
            }
        }

//        CGContextSetLineWidth(destinationContext, 2);
//        CGContextSetStrokeColorWithColor(destinationContext, [[UIColor redColor] CGColor]);
//        CGContextMoveToPoint(destinationContext, final, 0);
//        CGContextAddLineToPoint(destinationContext, final, tilesY * perceivedTileSize);
//        CGContextStrokePath(destinationContext);
        
//        CGContextAddRect(destinationContext, CGRectMake(left, top, scrollView.bounds.size.width, scrollView.bounds.size.height));
//        CGContextSetFillColorWithColor(destinationContext, [[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.2] CGColor]);
//        CGContextFillPath(destinationContext);
        
        UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();

        UIGraphicsEndImageContext();
        
        [self writeAndOpenImage:finalImage];
    }
}

@end