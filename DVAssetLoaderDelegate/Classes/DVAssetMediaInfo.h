//
//  DVAssetMediaInfo.h
//  DVAssetLoaderDelegate
//
//  Created by Vladislav Dugnist on 28/09/2018.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DVAssetMediaInfo : NSObject <NSCoding>

@property (nonatomic, copy) NSString *contentType;
@property (nonatomic) long long contentLength;
@property (nonatomic) BOOL byteRangedAccessSupported;

@end

NS_ASSUME_NONNULL_END
