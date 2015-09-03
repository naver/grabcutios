//
//  ViewController.m
//  GrabCutIOS
//
//  Created by EunchulJeon on 2015. 8. 29..
//  Copyright (c) 2015 Naver Corp.
//  @Author Eunchul Jeon
//

#import "ViewController.h"
#import "GrabCutManager.h"
#import "TouchDrawView.h"
#import <MobileCoreServices/UTCoreTypes.h>

static inline double radians (double degrees) {return degrees * M_PI/180;}
const static int MAX_IMAGE_LENGTH = 450;

@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *resultImageView;
@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGPoint endPoint;
@property (weak, nonatomic) IBOutlet TouchDrawView *touchDrawView;
@property (nonatomic, strong) GrabCutManager* grabcut;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UIButton *rectButton;
@property (weak, nonatomic) IBOutlet UIButton *plusButton;
@property (weak, nonatomic) IBOutlet UIButton *minusButton;
@property (weak, nonatomic) IBOutlet UIButton *doGrabcutButton;
@property (nonatomic, assign) TouchState touchState;
@property (nonatomic, assign) CGRect grabRect;
@property (nonatomic, strong) UIImage* originalImage;
@property (nonatomic, strong) UIImage* resizedImage;
@property (nonatomic, strong) UIImagePickerController* imagePicker;

@property (nonatomic) UIActivityIndicatorView *spinner;
@property (nonatomic) UIView* dimmedView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _grabcut = [[GrabCutManager alloc] init];
    
    _originalImage = [UIImage imageNamed:@"test.jpg"];
    _resizedImage = [self getProperResizedImage:_originalImage];
    
    [self initStates];
}

-(void) initStates{
    _touchState = TouchStateNone;
    [self updateStateLabel];
    
    _rectButton.enabled = YES;
    _plusButton.enabled = NO;
    _minusButton.enabled = NO;
    _doGrabcutButton.enabled = NO;
    
}
                     
-(UIImage *) getProperResizedImage:(UIImage*)original{
    float ratio = original.size.width/original.size.height;
    
    if(original.size.width > original.size.height){
        if(original.size.width > MAX_IMAGE_LENGTH){
            return [self resizeWithRotation:original size:CGSizeMake(MAX_IMAGE_LENGTH, MAX_IMAGE_LENGTH/ratio)];
        }
    }else{
        if(original.size.height > MAX_IMAGE_LENGTH){
            return [self resizeWithRotation:original size:CGSizeMake(MAX_IMAGE_LENGTH*ratio, MAX_IMAGE_LENGTH)];
        }
    }
    
    return original;
}

-(NSString*) getTouchStateToString{
    NSString* state = @"Touch State : ";
    NSString* suffix;
    
    switch (_touchState) {
        case TouchStateNone:
            suffix = @"None";
            break;
        case TouchStateRect :
            suffix = @"Rect";
            break;
        case TouchStatePlus :
            suffix = @"Plus";
            break;
        case TouchStateMinus :
            suffix = @"Minus";
            break;
        default:
            break;
    }
    
    return [NSString stringWithFormat:@"%@%@", state, suffix];
}

-(void) updateStateLabel{
    [self.stateLabel setText:[self getTouchStateToString]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CGRect) getTouchedRectWithImageSize:(CGSize) size{
    CGFloat widthScale = size.width/self.imageView.frame.size.width;
    CGFloat heightScale = size.height/self.imageView.frame.size.height;
    return [self getTouchedRect:_startPoint endPoint:_endPoint widthScale:widthScale heightScale:heightScale];
}

-(CGRect) getTouchedRect:(CGPoint)startPoint endPoint:(CGPoint)endPoint{
    return [self getTouchedRect:startPoint endPoint:endPoint widthScale:1.0 heightScale:1.0];
}

-(CGRect) getTouchedRect:(CGPoint)startPoint endPoint:(CGPoint)endPoint widthScale:(CGFloat)widthScale heightScale:(CGFloat)heightScale{
    CGFloat minX = startPoint.x > endPoint.x ? endPoint.x*widthScale : startPoint.x*widthScale;
    CGFloat maxX = startPoint.x < endPoint.x ? endPoint.x*widthScale : startPoint.x*widthScale;
    CGFloat minY = startPoint.y > endPoint.y ? endPoint.y*heightScale : startPoint.y*heightScale;
    CGFloat maxY = startPoint.y < endPoint.y ? endPoint.y*heightScale : startPoint.y*heightScale;
    
    return CGRectMake(minX, minY, maxX - minX, maxY - minY);
}

-(UIImage*) resizeImage:(UIImage*)image size:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextDrawImage(context, CGRectMake(0.0, 0.0, size.width, size.height), [image CGImage]);
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

-(UIImage*) resizeWithRotation:(UIImage *) sourceImage size:(CGSize) targetSize
{
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGImageRef imageRef = [sourceImage CGImage];
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    
    if (bitmapInfo == kCGImageAlphaNone) {
        bitmapInfo = kCGImageAlphaNoneSkipLast;
    }
    
    CGContextRef bitmap;
    
    if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown) {
        bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    } else {
        bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    }
    
    if (sourceImage.imageOrientation == UIImageOrientationLeft) {
        CGContextRotateCTM (bitmap, radians(90));
        CGContextTranslateCTM (bitmap, 0, -targetHeight);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationRight) {
        CGContextRotateCTM (bitmap, radians(-90));
        CGContextTranslateCTM (bitmap, -targetWidth, 0);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationUp) {
        // NOTHING
    } else if (sourceImage.imageOrientation == UIImageOrientationDown) {
        CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
        CGContextRotateCTM (bitmap, radians(-180.));
    }
    
    CGContextDrawImage(bitmap, CGRectMake(0, 0, targetWidth, targetHeight), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return newImage; 
}

-(UIImage *) masking:(UIImage*)sourceImage mask:(UIImage*) maskImage{
    //Mask Image
    CGImageRef maskRef = maskImage.CGImage;
    
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef masked = CGImageCreateWithMask([sourceImage CGImage], mask);
    CGImageRelease(mask);
    
    UIImage *maskedImage = [UIImage imageWithCGImage:masked];
    
    CGImageRelease(masked);
    
    return maskedImage;
}

-(CGSize) getResizeForTimeReduce:(UIImage*) image{
    CGFloat ratio = image.size.width/ image.size.height;
    
    if([image size].width > [image size].height){

        
        if(image.size.width > 400){
            return CGSizeMake(400, 400/ratio);
        }else{
            return image.size;
        }
        
    }else{
        if(image.size.height > 400){
            return CGSizeMake(ratio/400, 400);
        }else{
            return image.size;
        }
    }
}

-(void) doGrabcut{
    [self showLoadingIndicatorView];

    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             (unsigned long)NULL), ^(void) {
        UIImage* resultImage= [weakSelf.grabcut doGrabCut:weakSelf.resizedImage foregroundBound:weakSelf.grabRect iterationCount:5];
        resultImage = [weakSelf masking:weakSelf.originalImage mask:[weakSelf resizeImage:resultImage size:weakSelf.originalImage.size]];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [weakSelf.resultImageView setImage:resultImage];
            [weakSelf.imageView setAlpha:0.2];
            
            [weakSelf hideLoadingIndicatorView];
        });
    });
}

-(void) doGrabcutWithMaskImage:(UIImage*)image{
    [self showLoadingIndicatorView];

    __weak typeof(self)weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             (unsigned long)NULL), ^(void) {
        UIImage* resultImage= [weakSelf.grabcut doGrabCutWithMask:weakSelf.resizedImage maskImage:[weakSelf resizeImage:image size:weakSelf.resizedImage.size] iterationCount:5];
        resultImage = [weakSelf masking:weakSelf.originalImage mask:[weakSelf resizeImage:resultImage size:weakSelf.originalImage.size]];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [weakSelf.resultImageView setImage:resultImage];
            [weakSelf.imageView setAlpha:0.2];
            [weakSelf hideLoadingIndicatorView];
        });
    });
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"began");
    UITouch *touch = [touches anyObject];
    self.startPoint = [touch locationInView:self.imageView];
    
    if(_touchState == TouchStateNone || _touchState == TouchStateRect){
        [self.touchDrawView clear];
    }else if(_touchState == TouchStatePlus || _touchState == TouchStateMinus){
        [self.touchDrawView touchStarted:self.startPoint];
    }
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"moved");
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.imageView];
    
    if(_touchState == TouchStateRect){
        CGRect rect = [self getTouchedRect:_startPoint endPoint:point];
        [self.touchDrawView drawRectangle:rect];
    }else if(_touchState == TouchStatePlus || _touchState == TouchStateMinus){
        [self.touchDrawView touchMoved:point];
    }
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"ended");
    UITouch *touch = [touches anyObject];
    self.endPoint = [touch locationInView:self.imageView];
    
    if(_touchState == TouchStateRect){
        _grabRect = [self getTouchedRectWithImageSize:_resizedImage.size];
    }else if(_touchState == TouchStatePlus || _touchState == TouchStateMinus){
        [self.touchDrawView touchEnded:self.endPoint];
        _doGrabcutButton.enabled = YES;
    }
}

- (IBAction)tapOnReset:(id)sender {
    [self.imageView setImage:_originalImage];
    [self.resultImageView setImage:nil];
    [self.imageView setAlpha:1.0];
    _touchState = TouchStateNone;
    [self updateStateLabel];
    
    _rectButton.enabled = YES;
    _plusButton.enabled = NO;
    _minusButton.enabled = NO;
    _doGrabcutButton.enabled = NO;
    
    [self.touchDrawView clear];
    [self.grabcut resetManager];
}
- (IBAction)tapOnRect:(id)sender {
    _touchState = TouchStateRect;
    [self updateStateLabel];
    
    _plusButton.enabled = NO;
    _minusButton.enabled = NO;
    _doGrabcutButton.enabled = YES;
}

- (IBAction)tapOnPlus:(id)sender {
    _touchState = TouchStatePlus;
    [self updateStateLabel];
    
    [_touchDrawView setCurrentState:TouchStatePlus];
}

- (IBAction)tapOnMinus:(id)sender {
    _touchState = TouchStateMinus;
    [self updateStateLabel];
    [_touchDrawView setCurrentState:TouchStateMinus];
}

-(IBAction)tapOnDoGrabcut:(id)sender{
    if(_touchState == TouchStateRect){
        if([self isUnderMinimumRect]){
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Opps" message:@"More bigger rect for operation" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK"  , nil];
            [alert show];
            
            return;
        }
        
        [self doGrabcut];
        [self.touchDrawView clear];
        
        _rectButton.enabled = NO;
        _plusButton.enabled = YES;
        _minusButton.enabled = YES;
        _doGrabcutButton.enabled = NO;
    }else if(_touchState == TouchStatePlus || _touchState == TouchStateMinus){
        UIImage* touchedMask = [self.touchDrawView maskImageWithPainting];
        [self doGrabcutWithMaskImage:touchedMask];
        
        [self.touchDrawView clear];
        _rectButton.enabled = NO;
        _plusButton.enabled = YES;
        _minusButton.enabled = YES;
        _doGrabcutButton.enabled = YES;
    }
}

-(BOOL) isUnderMinimumRect{
    if(_grabRect.size.width <20.0 || _grabRect.size.height < 20.0){
        return YES;
    }
    
    return NO;
}

#pragma mark - Image Picker

-(IBAction) tapOnPhoto:(id)sender{
    [self startMediaBrowserFromViewController: self
                                usingDelegate: self];
}

-(IBAction) tapOnCamera:(id)sender{
    [self startCameraControllerFromViewController: self
                                    usingDelegate: self];

}

-(void) setImageToTarget:(UIImage*)image{
    _originalImage = [self resizeWithRotation:image size:image.size];
    _resizedImage = [self getProperResizedImage:_originalImage];
    _imageView.image = _originalImage;
    [self initStates];
    [self.grabcut resetManager];
}

- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
//    self.imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];

    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    self.imagePicker.allowsEditing = NO;
    
    self.imagePicker.delegate = delegate;
    
    [controller presentViewController:self.imagePicker animated:YES completion:nil];
    return YES;
}

- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller
                               usingDelegate: (id <UIImagePickerControllerDelegate,
                                               UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    // Displays saved pictures and movies, if both are available, from the
    // Camera Roll album.
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
//    [UIImagePickerController availableMediaTypesForSourceType:
//     UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    self.imagePicker.allowsEditing = NO;
    
    self.imagePicker.delegate = delegate;
    
    [controller presentViewController:self.imagePicker animated:YES completion:nil];
    return YES;
}

// For responding to the user tapping Cancel.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    self.imagePicker =nil;
}

// For responding to the user accepting a newly-captured picture or movie
- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *resultImage;
    
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            resultImage = editedImage;
        } else {
            resultImage = originalImage;
        }
    }
    
    [self setImageToTarget:resultImage];
    
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    self.imagePicker = nil;
    
}

#pragma mark - Indicator

CG_INLINE CGRect
CGRectSetOrigin(CGRect rect, CGPoint origin)
{
    rect.origin = origin;
    return rect;
}

- (void)showLoadingIndicatorView
{
    [self showLoadingIndicatorViewWithStyle:UIActivityIndicatorViewStyleWhite];
}

- (void)showLoadingIndicatorViewWithStyle:(UIActivityIndicatorViewStyle)activityIndicatorViewStyle
{
    if (self.spinner != nil) {
        [self hideLoadingIndicatorView];
    }
    
    self.dimmedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.dimmedView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]];
    [self.view addSubview:self.dimmedView];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:activityIndicatorViewStyle];
    spinner.frame = CGRectSetOrigin(spinner.frame, CGPointMake(floorf(CGRectGetMidX(self.view.bounds) - CGRectGetMidX(spinner.bounds)), floorf(CGRectGetMidY(self.view.bounds) - CGRectGetMidY(spinner.bounds))));
    spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [spinner startAnimating];
    [self.view addSubview:spinner];
    self.spinner = spinner;
    
    [self.view setUserInteractionEnabled:NO];
}

- (void)hideLoadingIndicatorView
{
    [self.spinner stopAnimating];
    [self.spinner removeFromSuperview];
    self.spinner = nil;
    
    [self.dimmedView removeFromSuperview];
    self.dimmedView = nil;
    
    [self.view setUserInteractionEnabled:YES];
}


@end
