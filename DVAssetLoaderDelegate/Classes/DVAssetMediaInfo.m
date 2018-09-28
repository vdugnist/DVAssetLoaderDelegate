//
//  DVAssetMediaInfo.m
//  DVAssetLoaderDelegate
//
//  Created by Vladislav Dugnist on 28/09/2018.
//

#import "DVAssetMediaInfo.h"

@implementation DVAssetMediaInfo

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.contentType forKey:@"contentType"];
    [aCoder encodeObject:@(self.contentLength) forKey:@"contentLength"];
    [aCoder encodeBool:self.byteRangedAccessSupported forKey:@"byteRangedAccessSupported"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.contentType = [aDecoder decodeObjectForKey:@"contentType"];
        self.contentLength = [[aDecoder decodeObjectForKey:@"contentLength"] longLongValue];
        self.byteRangedAccessSupported = [aDecoder decodeBoolForKey:@"byteRangedAccessSupported"];
    }
    
    return self;
}

@end
