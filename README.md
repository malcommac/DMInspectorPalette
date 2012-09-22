# DMInspectorPalette

DMInspectorPalette is an NSScrollView that supports dynamic loading of NSView grouped by section as like in XCode Inspector Window.
You can collapse or expand an item in order to hide or show it's relative section.
All state changes are animatable using Core Animation.

Daniele Margutti, <http://www.danielemargutti.com>

![DMInspectorPalette Example Project](http://danielemargutti.com/wp-content/uploads/2012/06/Untitled.png)

## How to get started

* Create NSView subclass inside your nib file
* Connect each NSView via outlets to your view controller class 
* For each NSView (/section) create a DMPaletteSectionView object and assign it to the view with a title
* Set your views to the palette container using DMPaletteContainer.sectionViews = yourArray
* Done!

## Donations

If you found this project useful, please donate.
There’s no expected amount and I don’t require you to.
[MAKE YOUR DONATION](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=GS3DBQ69ZBKWJ)

## License (MIT)

Copyright (c) 2012 Daniele Margutti

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
