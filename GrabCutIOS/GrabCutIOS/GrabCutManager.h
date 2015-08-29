//
//  GrabCutManager.h
//  OpenCVTest
//
//  Created by Eunchul Jeon on 2015. 8. 21..
//  Copyright (c) 2015년 EunchulJeon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <opencv2/opencv.hpp>
#import <opencv2/imgproc/imgproc_c.h>
#import <opencv2/highgui/highgui_c.h>
#import <opencv2/core/core_c.h>
using namespace cv;


@interface GrabCutManager : NSObject{
    cv::Mat mask; // segmentation (4 possible values)
    cv::Mat bgModel,fgModel; // the models (internally used)
}
-(UIImage*) doGrabCut:(UIImage*)sourceImage foregroundBound:(CGRect) rect iterationCount:(int)iterCount;
-(UIImage*) doGrabCutWithMask:(UIImage*)sourceImage maskImage:(UIImage*)maskImage iterationCount:(int) iterCount;
-(void) resetManager;
@end
