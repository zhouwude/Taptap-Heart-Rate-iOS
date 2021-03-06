//
//  TTHRHeartIndicatorView.m
//  Taptap Heart Rate
//
//  Created by Zhang Honghao on 6/28/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "TTHRHeartIndicatorView.h"

@implementation TTHRHeartIndicatorView {
    UIImage *_image;
    UIImage *_dimmedImage;
    UIImageView *_dimmedImageView;
    UIView *_maskView;
    UIImageView *_imageView;
    float _percent;
    
    BOOL _isBlinking;
    CGFloat _initPercent;
    CGFloat _initAlpha;
}

- (instancetype)initWithFrame:(CGRect)frame {
    UIColor *whiteColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.85];
    return [self initWithFrame:frame color:whiteColor imageNamed:@"Heart"];
}

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor *)color imageNamed:(NSString *)imageName {
    self = [super initWithFrame:frame];
    if (self) {
        _image = [self changeColorForImage:[UIImage imageNamed:imageName] toColor:color];
        CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha =0.0;
        [color getRed:&red green:&green blue:&blue alpha:&alpha];
        _dimmedImage = [self changeColorForImage:[UIImage imageNamed:imageName] toColor:[UIColor colorWithRed:red green:green blue:blue alpha:alpha * 0.5]];
        _percent = 0;
        CGRect newFrame = CGRectMake(frame.origin.x, frame.origin.y, _image.size.width, _image.size.height);
        [self setFrame:newFrame];
        
        _dimmedImageView = [[UIImageView alloc] initWithImage:_dimmedImage];
        _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, _imageView.frame.size.height * (1 - _percent), _imageView.frame.size.width, _percent * _imageView.frame.size.height)];
        [_maskView setClipsToBounds:YES];
        
        _imageView = [[UIImageView alloc] initWithImage:_image];
        [_imageView setFrame:CGRectMake(0, - _imageView.frame.size.height * (1 - _percent), _imageView.frame.size.width, _imageView.frame.size.height)];
        
        [self addSubview:_dimmedImageView];
        [self addSubview:_maskView];
        [_maskView addSubview:_imageView];
        [self setBackgroundColor:[UIColor clearColor]];
        
        _isBlinking = NO;
        _initAlpha = 0;
        _initPercent = 0;
    }
    return self;
}

//- (void)drawRect:(CGRect)rect {
////    // Draw dimmed image
////    [_dimmedImage drawAtPoint:CGPointMake(0, 0)];
////    // Cover normal image
////    CGFloat height = (1 - _percent) * self.bounds.size.height;
////    UIRectClip(CGRectMake(0, 0, self.bounds.size.width, height));
////    [_dimmedImage drawAtPoint:CGPointMake(0, 0)];
//}

- (void)setPercent:(float)percent withDuration:(float)duration {
//    LogMethod;
    if (percent > 1.0) {
        percent = 1.0;
    } else if (percent < 0.0) {
        percent = 0.0;
    }
    _percent = percent;
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState |UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         // Update maskView and imageView frame
                         [_maskView setFrame:CGRectMake(0, _imageView.frame.size.height * (1 - _percent), _imageView.frame.size.width, _percent * _imageView.frame.size.height)];
                         [_imageView setFrame:CGRectMake(0, - _imageView.frame.size.height * (1 - _percent), _imageView.frame.size.width, _imageView.frame.size.height)];
                     }
                     completion:nil];
}

- (void)setBlink:(BOOL)toBlink
{
//    LogMethod;
    void (^blinkAnimationBlock)() = ^{
        [_imageView setAlpha:0.0];
        [self setPercent:1.0 withDuration:0];
        [UIView animateWithDuration:1.0
                              delay:0.0
                            options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [_imageView setAlpha:1.0];
                         }
                         completion:NULL];
    };
    void (^restoreAnimationBlock)() = ^{
        [_imageView.layer removeAllAnimations];
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [_imageView setAlpha:_initAlpha];/////////
                         } completion:^(BOOL finished) {
//                             [self setPercent:_initPercent withDuration:0.0];
                         }];
    };
    if (toBlink) {
//        NSLog(@"UnBlink -> Blink");
        if (_isBlinking == NO) {
            _initAlpha = _imageView.alpha;
            _initPercent = _percent;
//            NSLog(@"per: %f, alpha: %f", _initPercent, _initAlpha);
        }
        _isBlinking = toBlink;
        blinkAnimationBlock();
    } else {
//        NSLog(@"Blink -> UnBlink");
        _isBlinking = toBlink;
        restoreAnimationBlock();
    }
}

- (void)setAlpha:(CGFloat)alpha withDuration:(float)duration
{
//    LogMethod;
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         [_imageView setAlpha:alpha];
//                         NSLog(@"imageView alpha: %f", alpha);
                     }
                     completion:nil];
}

#pragma mark - Helper methods

- (UIImage *) changeColorForImage:(UIImage *)mask toColor:(UIColor*)color {
    
    CGImageRef maskImage = mask.CGImage;
    CGFloat width = mask.scale * mask.size.width;
    CGFloat height = mask.scale * mask.size.height;
    CGRect bounds = CGRectMake(0,0,width,height);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL, width, height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    CGContextClipToMask(bitmapContext, bounds, maskImage);
    CGContextSetFillColorWithColor(bitmapContext, color.CGColor);
    CGContextFillRect(bitmapContext, bounds);
    
    CGImageRef mainViewContentBitmapContext = CGBitmapContextCreateImage(bitmapContext);
    CGContextRelease(bitmapContext);
    
    return [UIImage imageWithCGImage:mainViewContentBitmapContext scale:mask.scale orientation:UIImageOrientationUp];
}
//
//+(UIImage *) newImageFromMaskImage:(UIImage *)mask inColor:(UIColor *) color {
//    CGImageRef maskImage = mask.CGImage;
//    CGFloat width = mask.size.width;
//    CGFloat height = mask.size.height;
//    CGRect bounds = CGRectMake(0,0,width,height);
//    
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGContextRef bitmapContext = CGBitmapContextCreate(NULL, width, height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
//    CGContextClipToMask(bitmapContext, bounds, maskImage);
//    CGContextSetFillColorWithColor(bitmapContext, color.CGColor);
//    CGContextFillRect(bitmapContext, bounds);
//    
//    CGImageRef mainViewContentBitmapContext = CGBitmapContextCreateImage(bitmapContext);
//    CGContextRelease(bitmapContext);
//    
//    UIImage *result = [UIImage imageWithCGImage:mainViewContentBitmapContext];
//    return result;
//}

@end
