//
//  ViewController.m
//  FMShrinkableScrollableImageViewDemo
//
//  Created by Andrea Ottolina on 26/01/2013.
//  Copyright (c) 2013 Flubber Media. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) NSArray *images;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	_images = [NSArray arrayWithObjects:[UIImage imageNamed:@"image-01.jpg"], [UIImage imageNamed:@"image-02.jpg"], nil];
	
	_scrollableImageView.minimumZoomType = FMShrinkableScrollableImageViewMinimumZoomTypeShrink;
	_scrollableImageView.clipsToBounds = YES;
	_scrollableImageView.layer.borderWidth = 5.;
	_scrollableImageView.layer.borderColor = [UIColor blackColor].CGColor;
	_scrollableImageView.imageView.image = [_images objectAtIndex:0];
}

- (IBAction)didTapChangeImage:(id)sender
{
	_scrollableImageView.imageView.image = (_scrollableImageView.imageView.image == [_images objectAtIndex:0]) ? [_images objectAtIndex:1] : [_images objectAtIndex:0];
	NSLog(@"Changed image to: %@", _scrollableImageView.imageView.image);
}

- (IBAction)didTapChangeZoom:(id)sender
{
	int randomPicker = arc4random() % 3;
	_scrollableImageView.minimumZoomType = randomPicker;
	NSLog(@"Changed minimumZoomType to: %d", _scrollableImageView.minimumZoomType);
}

@end
