//
//  DVAssetLoaderDelegatesDelegate.h
//  DVAssetLoaderDelegate
//
//  Created by Vladislav Dugnist on 07/01/2018.
//

#import <AVFoundation/AVFoundation.h>
@class DVAssetLoaderDelegate;

@protocol DVAssetLoaderDelegatesDelegate <NSObject>
@optional

/**
 Called when the file downloaded completely.
 May not be called when the file contains information not relevant to playback.
 */
- (void)dvAssetLoaderDelegate:(DVAssetLoaderDelegate *)loaderDelegate
                  didLoadData:(NSData *)data
                       forURL:(NSURL *)url;

/**
 Called when the file downloaded completely.
 May not be called when the file contains information not relevant to playback.
 */
- (void)dvAssetLoaderDelegate:(DVAssetLoaderDelegate *)loaderDelegate
                  didLoadData:(NSData *)data
                       forURL:(NSURL *)url
                     withMIMEType:(NSString*)mimeType;

/**
 Called when loader delegate downloaded data range so you can manually operate with a cache.
 */
- (void)dvAssetLoaderDelegate:(DVAssetLoaderDelegate *)loaderDelegate
                  didLoadData:(NSData *)data
                     forRange:(NSRange)range
                          url:(NSURL *)url;

/**
 Called when loader delegate recieved loading error.
 */
- (void)dvAssetLoaderDelegate:(DVAssetLoaderDelegate *)loaderDelegate
       didRecieveLoadingError:(NSError *)error
                 withDataTask:(NSURLSessionDataTask *)dataTask
                   forRequest:(AVAssetResourceLoadingRequest *)request;

@end
