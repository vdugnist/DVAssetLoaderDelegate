//
//  DVAssetLoaderError.m
//
//  Created by Vladislav Dugnist on 31/12/2017.
//  Copyright © 2017 vdugnist. All rights reserved.
//

#import "DVAssetLoaderError.h"

@implementation DVAssetLoaderError

+ (instancetype)loaderErrorWithError:(NSError *)error {
    return [[DVAssetLoaderError alloc] initWithError:error];
}

- (instancetype)initWithError:(NSError *)error {
    if (self = [super init]) {
        _error = error;
        _date = [NSDate date];
    }
    
    return self;
}

@end
