This is a demo to show the difficulty in grabbing a snapshot of a `CATiledLayer`-backed view. 

Relevant discussions: 

 * http://stackoverflow.com/questions/9122388/taking-image-snapshot-of-catiledlayer-backed-view-in-uiscrollview
 * https://devforums.apple.com/message/612341

Note the difference between the first segment, which renders the main view including the pink subview, and the second segment, which renders a blank gray area instead of the map view. 

The map view is from the [Alpstein Route-Me fork](https://github.com/Alpstein/route-me), which is essentially, in order: 

 1. A generic `UIView` containing
 1. A `UIScrollView` that pans & zooms containing
 1. A `UIView` subview backed by a `CATiledLayer`. 

Note that the private API `UIGetScreenImage()` captures the whole snapshot accurately in both cases. I've not found another method yet which does. 