//
//  GrabCutManager.m
//  OpenCVTest
//
//  Created by Eunchul Jeon on 2015. 8. 21..
//  Copyright (c) 2015년 EunchulJeon. All rights reserved.
//

#import "GrabCutManager.h"
#import <opencv2/opencv.hpp>

@implementation GrabCutManager

- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

- (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

- (cv::Mat1b)cvMatMaskerFromUIImage:(UIImage *) image prevResult:(cv::Mat1b)prevResult{
    
    // First get the image into your data buffer
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    cv::Mat1b markers((int)height, (int)width);
    markers.setTo(cv::GC_PR_BGD);
//    cv::Mat1b markers = prevResult;
    
    uchar* data =  markers.data;

    int countFGD=0, countBGD=0, countRem = 0;
    
    for(int x = 0; x < width; x++){
        for( int y = 0; y < height; y++){
            NSUInteger byteIndex = ((image.size.width  * y) + x ) * 4;
            UInt8 red   = rawData[byteIndex];
            UInt8 green = rawData[byteIndex + 1];
            UInt8 blue  = rawData[byteIndex + 2];
            UInt8 alpha = rawData[byteIndex + 3];
            
            if(red == 255 && green == 255 && blue == 255 && alpha == 255){
                data[width*y + x] = cv::GC_PR_FGD;
                countFGD++;
            }else if(red == 0 && green == 0 && blue == 0 && alpha == 255){
                data[width*y + x] = cv::GC_PR_BGD;
                countBGD++;
            }else{
                countRem++;
            }
        }
    }
    
    free(rawData);
    
    NSLog(@"Count %d %d %d sum : %d width*height : %d", countFGD, countBGD, countRem, countFGD+countBGD + countRem, width*height);
    
    return markers;
}


-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}


cv::Mat prevResult;
cv::Mat bgModel,fgModel; // the models (internally used)

-(UIImage*) doGrabCut:(UIImage*)sourceImage foregroundBound:(CGRect)rect iterationCount:(int) iterCount{
    cv::Mat img=[self cvMatFromUIImage:sourceImage];
    cv::cvtColor(img , img , CV_RGBA2RGB);
    cv::Rect rectangle(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    cv::Mat result; // segmentation (4 possible values)


    
    // GrabCut segmentation
    cv::grabCut(img,    // input image
                result,      // segmentation result
                rectangle,   // rectangle containing foreground
                bgModel,fgModel, // models
                iterCount,           // number of iterations
                cv::GC_INIT_WITH_RECT); // use rectangle
    // Get the pixels marked as likely foreground
    prevResult = result;
    
    cv::compare(result,cv::GC_PR_FGD,result,cv::CMP_EQ);

    // Generate output image
    cv::Mat foreground(img.size(),CV_8UC3,
                       cv::Scalar(255,255,255));

    result=result&1;
    

    img.copyTo(foreground, result);
    
    UIImage* resultImage=[self UIImageFromCVMat:foreground];
    
    return resultImage;
}

-(UIImage*) doGrabCutWithMask:(UIImage*)sourceImage maskImage:(UIImage*)maskImage iterationCount:(int) iterCount{
    cv::Mat img=[self cvMatFromUIImage:sourceImage];
    cv::cvtColor(img , img , CV_RGBA2RGB);
    
    cv::Mat1b markers=[self cvMatMaskerFromUIImage:maskImage prevResult:prevResult];
    cv::Rect rectangle(0,0,0,0);
    
//    cv::Mat result; // segmentation (4 possible values)
//    cv::Mat bgModel,fgModel; // the models (internally used)
    
    // GrabCut segmentation
    cv::grabCut(img, markers, rectangle, bgModel, fgModel, iterCount, cv::GC_INIT_WITH_MASK);
//
//    // Get the pixels marked as likely foreground
    cv::compare(markers,cv::GC_PR_FGD,markers,cv::CMP_EQ);
    // Generate output image
    cv::Mat foreground(img.size(),CV_8UC3,
                       cv::Scalar(255,255,255));
    markers=markers&1;
    img.copyTo(foreground, markers);

    UIImage* resultImage=[self UIImageFromCVMat:foreground];

    
//    cv::Mat1b mask_fgpf = ( markers == cv::GC_FGD) | ( markers == cv::GC_PR_FGD);
//    // and copy all the foreground-pixels to a temporary image
//    cv::Mat3b tmp = cv::Mat3b::zeros(img.rows, img.cols);
//    img.copyTo(tmp, mask_fgpf);

    
//    UIImage* resultImage=[self UIImageFromCVMat:tmp];
    
    return resultImage;
}
@end
