//
//  DVAssetLoaderDelegate.h
//
//  Created by Vladislav Dugnist on 31/12/2017.
//  Copyright © 2017 vdugnist. All rights reserved.
//

#import <AVFoundation/AVAssetResourceLoader.h>

@class DVAssetLoaderDelegate;

@protocol DVAssetLoaderDelegateDelegate
@optional

/**
 Called when the file downloaded completely.
 May not be called when the file contains information not relevant to playback.
 */
- (void)dvAssetLoaderDelegate:(DVAssetLoaderDelegate *)loaderDelegate
                     didLoadData:(NSData *)data
                          forURL:(NSURL *)url;
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

@interface DVAssetLoaderDelegate : NSObject <AVAssetResourceLoaderDelegate>

+ (NSString *)scheme;
- (instancetype)initWithURL:(NSURL *)url NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype) new NS_UNAVAILABLE;

@property (nonatomic, weak) NSObject<DVAssetLoaderDelegateDelegate> *delegate;
@property (nonatomic) NSURLSession *session;

@end
