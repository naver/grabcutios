# GrabCutIOS

## Overview
GrabCut is an image segmentation method based on graph cuts. The algorithm was designed by Carsten Rother, Vladimir Kolmogorov & Andrew Blake from Microsoft Research Cambridge, UK. in their paper, "GrabCut": interactive foreground extraction using iterated graph cuts . An algorithm was needed for foreground extraction with minimal user interaction, and the result was GrabCut.

## Screenshot
![screenshot.png](/files/79285)

## Usage

## Limitation
This program use OpenCV library.
It is too big to use for real service.(76.8MB)
So I'm going to implement the GrabCut Algorithm without OpenCV to reduce App size.

This algorithm is based on color value distribution. 
There is a limitation when foreground and background color are similar.

## References
* C. Rother, V. Kolmogorov, and A. Blake, GrabCut: Interactive foreground extraction using iterated graph cuts, ACM Trans. Graph., vol. 23, pp. 309–314, 2004.
* http://docs.opencv.org/master/d8/d83/tutorial_py_grabcut.html#gsc.tab=0

## License
GrabCutIOS is licensed under the Apache License, Version 2.0.
See [LICENSE](/files/79302) for full license text.

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
