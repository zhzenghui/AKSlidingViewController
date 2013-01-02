AKSlidingViewController
=======================

A combination of the plain old SplitViewController (in landscape) and SlidingViewController (in portrait) for iOS.

The principal is the following: On the iPhone the root is the AKSlidingViewController, which has a left and a right navigation controller, where you can push view controllers at each of them. On the iPad the root is a UISplitViewController, which has a left navigation controller and a right AKSlidingViewController. This AKSlidingViewController again has a left and a right navigation controller (like on the iPhone). The big advantage of this is that you only need to care for the two navigation controllers on the iPad as well as on the iPhone.

*** A further description will follow. ***


# Thanks to:
This project is an extension of the [ECSlidingViewController Github project](https://github.com/edgecase/ECSlidingViewController), big thanks to Michael Enriquez from EdgeCase.


# MIT License
Copyright (C) 2012 Orderbird

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.