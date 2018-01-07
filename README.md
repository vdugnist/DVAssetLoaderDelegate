# DVAssetLoaderDelegate

[![Version](https://img.shields.io/cocoapods/v/DVAssetLoaderDelegate.svg?style=flat)](http://cocoapods.org/pods/DVAssetLoaderDelegate)
[![License](https://img.shields.io/cocoapods/l/DVAssetLoaderDelegate.svg?style=flat)](http://cocoapods.org/pods/DVAssetLoaderDelegate)
[![Platform](https://img.shields.io/cocoapods/p/DVAssetLoaderDelegate.svg?style=flat)](http://cocoapods.org/pods/DVAssetLoaderDelegate)

## Description

With DVAssetLoaderDelegate you can implement caching data downloaded by AVPlayer for AVURLAsset. DVAssetLoaderDelegate provides you delegate method you can use to save downloaded data:

```
- (void)dvAssetLoaderDelegate:(DVAssetLoaderDelegate *)resourceLoader
                  didLoadData:(NSData *)data
                       forURL:(NSURL *)url;
```

For other methods check [DVAssetLoaderDelegatesDelegate.h](https://github.com/vdugnist/DVAssetLoaderDelegate/blob/master/DVAssetLoaderDelegate/Classes/DVAssetLoaderDelegatesDelegate.h).

## Usage

### Easy way (subclassing AVURLAsset)

1. Create `DVURLAsset`.
2. Implement `DVURLAsset`'s loaderDelegate.

### Manual way (without subclassing)

1. Create `DVAssetLoaderDelegate` object using URL for AVURLAsset.
2. Set `DVAssetLoaderDelegate` delegate for receiving cache data.
3. Before creating `AVURLAsset`, change URL scheme to `[DVAssetLoaderDelegate scheme]`.
4. Create `AVURLAsset` with URL with updated scheme.
5. Set `AVURLAsset`'s resource loader delegate to created `DVAssetLoaderDelegate` object.


```
NSURL *URL = ...;

DVAssetLoaderDelegate *resourceLoaderDelegate = [[DVAssetLoaderDelegate alloc] initWithURL:URL];
resourceLoaderDelegate.delegate = self;


NSURLComponents *components = [[NSURLComponents alloc] initWithURL:URL resolvingAgainstBaseURL:NO];
components.scheme = [DVAssetLoaderDelegate scheme];

AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[components URL] options:options];
[asset.resourceLoader setDelegate:resourceLoaderDelegate queue:dispatch_get_main_queue()];
```

## Installation

DVAssetLoaderDelegate is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'DVAssetLoaderDelegate'
```

## Author

vdugnist, vdugnist@gmail.com

## License

DVAssetLoaderDelegate is available under the MIT license. See the LICENSE file for more info.
