//
//  DVAssetLoaderDelegatesDataSource.h
//  DVAssetLoaderDelegate
//
//  Created by Vladislav Dugnist on 28/09/2018.
//

#import <Foundation/Foundation.h>

@class DVAssetLoaderDelegate;
@class DVAssetMediaInfo;

NS_ASSUME_NONNULL_BEGIN

@protocol DVAssetLoaderDelegatesDataSource <NSObject>

/**
 Called to retrieve media info from cache.
 Loader delegate will perform HEAD request if method is not implemented or returns nil.
 */
- (nullable DVAssetMediaInfo *)mediaInfoForLoaderDelegate:(DVAssetLoaderDelegate *)loaderDelegate
                                                      url:(NSURL *)url;

/**
 Called to retrieve data from cache.
 Loader delegate will perform request if method is not implemented,
 returns nil or returns only part of the requested range.
 */
- (nullable NSData *)dataForLoaderDelegate:(DVAssetLoaderDelegate *)loaderDelegate
                                     range:(NSRange)range
                                       url:(NSURL *)url;

/**
 Called to retrieve data from cache.
 Loader delegate will perform request if method is not implemented or returns nil.
 */
- (nullable NSData *)dataForLoaderDelegate:(DVAssetLoaderDelegate *)loaderDelegate
                                withOffset:(long long)offset
                                       url:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
