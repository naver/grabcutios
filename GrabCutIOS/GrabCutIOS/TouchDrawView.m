//
//  TouchDrawView.m
//  OpenCVTest
//
//  Created by EunchulJeon on 2015. 8. 29..
//  Copyright (c) 2015 Naver Corp.
//  @Author Eunchul Jeon
//

#import "TouchDrawView.h"

@interface TouchDrawView ()

@property (nonatomic, assign) CGRect rectangle;

@property (nonatomic, strong) UIBezierPath *plusPath;
@property (nonatomic, strong) UIBezierPath *minusPath;
@property (nonatomic, strong) UIImage *incrementalImage;

@end

@implementation TouchDrawView
@synthesize currentState = _currentState;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self initTouchView];
    }
    return self;
    
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initTouchView];
    }
    return self;
}

-(void) initTouchView{
    _plusPath = [UIBezierPath bezierPath];
    [_plusPath setLineWidth:6.0];
    [_plusPath setLineCapStyle:kCGLineCapRound];
    
    _minusPath = [UIBezierPath bezierPath];
    [_minusPath setLineWidth:6.0];
    [_minusPath setLineCapStyle:kCGLineCapRound];
    
    _currentState = TouchStateNone;
}

-(void) touchStarted:(CGPoint) p;
{
    if(_currentState == TouchStatePlus || _currentState == TouchStateMinus){
        ctr = 0;
        pts[0] = p;
    }
    
}

- (void)touchMoved:(CGPoint) p
{
    if(_currentState == TouchStatePlus || _currentState == TouchStateMinus){
        ctr++;
        pts[ctr] = p;
        if (ctr == 4)
        {
            pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0, (pts[2].y + pts[4].y)/2.0); // move the endpoint to the middle of the line joining the second control point of the first Bezier segment and the first control point of the second Bezier segment
            
            if(_currentState == TouchStatePlus){
                [_plusPath moveToPoint:pts[0]];
                [_plusPath addCurveToPoint:pts[3] controlPoint1:pts[1] controlPoint2:pts[2]]; // add a cubic Bezier from pt[0] to pt[3], with control points pt[1] and pt[2]
                
            }else if(_currentState == TouchStateMinus){
                [_minusPath moveToPoint:pts[0]];
                [_minusPath addCurveToPoint:pts[3] controlPoint1:pts[1] controlPoint2:pts[2]]; // add a cubic Bezier from pt[0] to pt[3], with control points pt[1] and pt[2]
            }
            
            [self setNeedsDisplay];
            // replace points and get ready to handle the next segment
            pts[0] = pts[3];
            pts[1] = pts[4]; 
            ctr = 1;
        }
    }
}

- (void)touchEnded:(CGPoint) p
{
    if(_currentState == TouchStatePlus || _currentState == TouchStateMinus){
    }
}

-(void) drawRectangle:(CGRect) rect{
    _currentState = TouchStateRect;
    _rectangle = rect;
    [self setNeedsDisplay];
}
-(void) clear{
    _currentState = TouchStateNone;
    [_plusPath removeAllPoints];
    [_minusPath removeAllPoints];
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    if(_currentState == TouchStateRect){
        //Get the CGContext from this view
        CGContextRef context = UIGraphicsGetCurrentContext();
        //Draw a rectangle
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:1.0 green:0 blue:0 alpha:0.4].CGColor);
        //Define a rectangle
        CGContextAddRect(context, _rectangle);
        //Draw it
        CGContextFillPath(context);
    }else if(_currentState == TouchStatePlus || _currentState == TouchStateMinus){
//        [_incrementalImage drawInRect:rect];
        
        [[UIColor whiteColor] setStroke];
        [_plusPath stroke];
        [[UIColor blackColor] setStroke];
        [_minusPath stroke];
    }
}

- (UIImage *) maskImageWithPainting
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end
