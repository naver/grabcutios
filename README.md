# GrabCutIOS
Image segmentation using GrabCut algorithm in IOS 

## Overview
GrabCut is an image segmentation method based on graph cuts. The algorithm was designed by Carsten Rother, Vladimir Kolmogorov & Andrew Blake from Microsoft Research Cambridge, UK. in their paper, "GrabCut": interactive foreground extraction using iterated graph cuts . An algorithm was needed for foreground extraction with minimal user interaction, and the result was GrabCut.

## Screenshot
![screenshot.png](/docs/screenshot.png)

## Requirement
1. OpenCV Framework

## Usage
1. Import GrabCutManager
```objectiveC
#import "GrabCutManager.h"
GrabCutManager* grabcut = [[GrabCutManager alloc] init];
```

2. Set foreground boundary with a rect.
```objectiveC
-(UIImage*) doGrabCut:(UIImage*)sourceImage foregroundBound:(CGRect) rect iterationCount:(int)iterCount;
```
```objectiveC
-(void) doGrabcut{
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             (unsigned long)NULL), ^(void) {
        UIImage* resultImage= [weakSelf.grabcut doGrabCut:weakSelf.resizedImage foregroundBound:weakSelf.grabRect iterationCount:5];
        resultImage = [weakSelf masking:weakSelf.originalImage mask:[weakSelf resizeImage:resultImage size:weakSelf.originalImage.size]];        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [weakSelf.resultImageView setImage:resultImage];
        });
    });
}
```

3. Make masking image with the adding or removing parts from result.
```objectiveC
-(UIImage*) doGrabCutWithMask:(UIImage*)sourceImage maskImage:(UIImage*)maskImage iterationCount:(int) iterCount;
```
```objectiveC
-(void) doGrabcutWithMaskImage:(UIImage*)image{
    __weak typeof(self)weakSelf = self;    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             (unsigned long)NULL), ^(void) {
        UIImage* resultImage= [weakSelf.grabcut doGrabCutWithMask:weakSelf.resizedImage maskImage:[weakSelf resizeImage:image size:weakSelf.resizedImage.size] iterationCount:5];
        resultImage = [weakSelf masking:weakSelf.originalImage mask:[weakSelf resizeImage:resultImage size:weakSelf.originalImage.size]];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [weakSelf.resultImageView setImage:resultImage];
        });
    });
}
```

## Limitation
This program use OpenCV library.
It is not use GPU in IOS. it is obviously more slower than library that it use GPU.
So I want to improve this code to use GPU like GPUImage.

This algorithm is based on color value distribution. 
There is a limitation when foreground and background color are similar.

## References
* C. Rother, V. Kolmogorov, and A. Blake, GrabCut: Interactive foreground extraction using iterated graph cuts, ACM Trans. Graph., vol. 23, pp. 309–314, 2004.
* http://docs.opencv.org/master/d8/d83/tutorial_py_grabcut.html#gsc.tab=0

## License
GrabCutIOS is licensed under the Apache License, Version 2.0.
See [LICENSE](/LICENSE) for full license text.

        Copyright (c) 2015 Naver Corp.
        @Author Eunchul Jeon

        Licensed under the Apache License, Version 2.0 (the "License");
        you may not use this file except in compliance with the License.
        You may obtain a copy of the License at

                http://www.apache.org/licenses/LICENSE-2.0

        Unless required by applicable law or agreed to in writing, software
        distributed under the License is distributed on an "AS IS" BASIS,
        WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
        See the License for the specific language governing permissions and
        limitations under the License.

