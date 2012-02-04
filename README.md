This is a demo to show the difficulty in grabbing a snapshot of a `CATiledLayer`-backed view. 

**NOTE:** As of 813fcb68f537ac99bab2f517a1cb6af90356c87a this has been worked around using manual re-rendering of each tile making up the current image. To see the non-working example, start at c3e00f6b2c67581e149440fd5394f1c13ff133ca instead. 


Relevant discussions: 

 * http://stackoverflow.com/questions/9122388/taking-image-snapshot-of-catiledlayer-backed-view-in-uiscrollview
 * https://devforums.apple.com/message/612341

Note the difference between the first segment, which renders the main view including the pink subview, and the second segment, which renders a blank gray area instead of the map view. 

The map view is from the [Alpstein Route-Me fork](https://github.com/Alpstein/route-me), which is essentially, in order: 

 1. A generic `UIView` containing
 1. A `UIScrollView` that pans & zooms containing
 1. A `UIView` subview backed by a `CATiledLayer`. 

Note that the private API `UIGetScreenImage()` captures the whole snapshot accurately in both cases. I've not found another method yet which does. 