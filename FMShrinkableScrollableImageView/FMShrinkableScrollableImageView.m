//
//  FMShrinkableScrollableImageView.m
//  test
//
//  Created by Andrea Ottolina on 21/01/2013.
//  Copyright (c) 2013 Andrea Ottolina. All rights reserved.
//

#import "FMShrinkableScrollableImageView.h"

@interface FMShrinkableScrollableImageViewDelegate : NSObject <UIScrollViewDelegate> {

@public
	id<UIScrollViewDelegate> publicDelegate;
	
}

@end

@interface FMShrinkableScrollableImageView ()

@property (nonatomic, assign) CGSize maxFrameSize;

@end

@implementation FMShrinkableScrollableImageView
{
    FMShrinkableScrollableImageViewDelegate *privateDelegate;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
	[self initDelegate];
	
	_minimumZoomType = FMShrinkableScrollableImageViewMinimumZoomTypeShrink;
	_maxFrameSize = self.frame.size;
	_zoomScaleMultiplier = 2.;
	
	_imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
	[self addSubview:_imageView];
	
	UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
	
	[_imageView addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:@"imageView.image"];
}

- (void)dealloc
{
    [_imageView removeObserver:self forKeyPath:@"image" context:@"imageView.image"];
}

#pragma mark - Custom getter/setter

- (void)setMinimumZoomType:(FMShrinkableScrollableImageViewMinimumZoomType)minimumZoomType
{
	_minimumZoomType = minimumZoomType;
	[self update];
}

#pragma mark - Private Methods

- (void)update
{
	[self updateContent];
	[self updateFrame:NO];
}

- (void)updateContent
{
	
	[_imageView sizeToFit];
	
	CGFloat widthRatio = _maxFrameSize.width / _imageView.image.size.width;
    CGFloat heightRatio = _maxFrameSize.height / _imageView.image.size.height;
	
	CGFloat minZoomScale;
	CGFloat maxZoomScale;
	
	switch (_minimumZoomType)
	{
		case FMShrinkableScrollableImageViewMinimumZoomTypeFill:
            minZoomScale = (widthRatio < heightRatio) ? heightRatio : widthRatio;
            break;
			
		case FMShrinkableScrollableImageViewMinimumZoomTypeFit:
		case FMShrinkableScrollableImageViewMinimumZoomTypeShrink:
		default:
            minZoomScale = (widthRatio > heightRatio) ? heightRatio : widthRatio;
            break;
    }
	
	CGRect imageViewFrame = _imageView.frame;
	imageViewFrame.origin = CGPointZero;
	_imageView.frame = imageViewFrame;
	
	maxZoomScale = _zoomScaleMultiplier * minZoomScale;
		
    self.contentSize = _imageView.image.size;
    self.minimumZoomScale = minZoomScale;
	self.maximumZoomScale = maxZoomScale;
	if (_imageView.image != nil)
	{
		self.zoomScale = self.minimumZoomScale;
	}

}

- (void)updateFrame:(BOOL)animated
{
	CGSize newFrameSize = CGSizeZero;
	
	if (_minimumZoomType == FMShrinkableScrollableImageViewMinimumZoomTypeShrink)
	{
		newFrameSize.width = (self.contentSize.width < _maxFrameSize.width) ? self.contentSize.width : _maxFrameSize.width;
		newFrameSize.height = (self.contentSize.height < _maxFrameSize.height) ? self.contentSize.height : _maxFrameSize.height;
	}
	else
	{
		newFrameSize = _maxFrameSize;
	}
	
	CGPoint savedCenter = self.center;
	CGRect newFrame = CGRectZero;
	newFrame.size = newFrameSize;
	
	self.frame = newFrame;
	self.center = savedCenter;
	
	if (_minimumZoomType == FMShrinkableScrollableImageViewMinimumZoomTypeFit)
	{
		_imageView.frame = [self centerFrame:self subview:_imageView];
	}
}

- (CGRect)centerFrame:(UIScrollView *)scrollView subview:(UIView *)subview
{
    CGSize boundsSize = scrollView.bounds.size;
    CGRect frameToCenter = subview.frame;
    
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    return frameToCenter;
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    zoomRect.size.height = self.frame.size.height / scale;
    zoomRect.size.width  = self.frame.size.width  / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}

#pragma mark - Gestures

- (void)doubleTap:(UITapGestureRecognizer *)gesture
{	
	CGFloat zoomScale = (self.zoomScale < self.maximumZoomScale) ? self.maximumZoomScale : self.minimumZoomScale;
	
	CGPoint location = [gesture locationInView:_imageView];
	CGRect rect = [self zoomRectForScale:zoomScale withCenter:location];
	[self zoomToRect:rect animated:YES];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([(__bridge NSString *)context isEqualToString:@"imageView.image"] && object == _imageView)
    {
        [self update];
    }
}

#pragma mark - Private Delegate accessors and initialization

- (void)initDelegate
{
    privateDelegate = [[FMShrinkableScrollableImageViewDelegate alloc] init];
    [super setDelegate:privateDelegate];
}

- (void)setDelegate:(id<UIScrollViewDelegate>)delegate
{
    privateDelegate->publicDelegate = delegate;
    // Scroll view delegate caches whether the delegate responds to some of the delegate
    // methods, so we need to force it to re-evaluate if the delegate responds to them
    super.delegate = nil;
    super.delegate = (id)privateDelegate;
}

- (id<UIScrollViewDelegate>)delegate
{
    return privateDelegate->publicDelegate;
}

#pragma mark - Private Delegate

- (UIView *)FMViewForZoomingInScrollView
{
	return _imageView;
}

- (void)FMScrollViewDidZoom:(UIScrollView *)scrollView
{
	[self updateFrame:NO];
}

@end

#pragma mark - Private Delegate implementation 

@implementation FMShrinkableScrollableImageViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return [(FMShrinkableScrollableImageView *)scrollView FMViewForZoomingInScrollView];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [(FMShrinkableScrollableImageView *)scrollView FMScrollViewDidZoom:scrollView];
    if ([publicDelegate respondsToSelector:_cmd]) {
        [publicDelegate scrollViewDidZoom:scrollView];
    }
}

// EXAMPLE
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    [(FMShrinkableScrollableImageView *)scrollView FMScrollViewDidEndDecelerating:scrollView];
//    if ([publicDelegate respondsToSelector:_cmd]) {
//        [publicDelegate scrollViewDidEndDecelerating:scrollView];
//    }
//}

#pragma mark - Public Delegate forwarding 

- (BOOL)respondsToSelector:(SEL)selector {
    return [publicDelegate respondsToSelector:selector] || [super respondsToSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    // This should only ever be called from `UIScrollView`, after it has verified
    // that `_userDelegate` responds to the selector by sending me
    // `respondsToSelector:`.  So I don't need to check again here.
    [invocation invokeWithTarget:publicDelegate];
}

@end
