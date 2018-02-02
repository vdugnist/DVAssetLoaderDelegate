//
//  DVURLAsset.h
//  DVAssetLoaderDelegate
//
//  Created by Vladislav Dugnist on 07/01/2018.
//

#import <AVFoundation/AVFoundation.h>
#import "DVAssetLoaderDelegatesDelegate.h"

@interface DVURLAsset : AVURLAsset

- (instancetype)initWithURL:(NSURL *)URL options:(NSDictionary<NSString *,id> *)options networkTimeout:(NSTimeInterval)networkTimeout;

@property (nonatomic, weak) NSObject <DVAssetLoaderDelegatesDelegate> *loaderDelegate;

@end
