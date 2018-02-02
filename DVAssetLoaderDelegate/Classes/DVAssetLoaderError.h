//
//  DVAssetLoaderError.h
//
//  Created by Vladislav Dugnist on 31/12/2017.
//  Copyright © 2017 vdugnist. All rights reserved.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DVAssetLoaderError : NSObject

+ (instancetype)loaderErrorWithError:(NSError *)error;

@property (nonatomic, readonly) NSError *error;
@property (nonatomic, readonly) NSDate *date;

@end

NS_ASSUME_NONNULL_END
