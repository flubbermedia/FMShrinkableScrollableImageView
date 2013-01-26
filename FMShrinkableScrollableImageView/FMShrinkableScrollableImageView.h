//
//  FMShrinkableScrollableImageView.h
//  test
//
//  Created by Andrea Ottolina on 21/01/2013.
//  Copyright (c) 2013 Andrea Ottolina. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    FMShrinkableScrollableImageViewMinimumZoomTypeFit,
    FMShrinkableScrollableImageViewMinimumZoomTypeFill,
	FMShrinkableScrollableImageViewMinimumZoomTypeShrink
} FMShrinkableScrollableImageViewMinimumZoomType;

@interface FMShrinkableScrollableImageView : UIScrollView

@property (nonatomic, strong) UIImageView *imageView;
@property (assign, nonatomic) FMShrinkableScrollableImageViewMinimumZoomType minimumZoomType;
@property (assign, nonatomic) CGFloat zoomScaleMultiplier;

@end
