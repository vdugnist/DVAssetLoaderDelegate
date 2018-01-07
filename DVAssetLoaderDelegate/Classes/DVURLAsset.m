//
//  DVURLAsset.m
//  DVAssetLoaderDelegate
//
//  Created by Vladislav Dugnist on 07/01/2018.
//

#import "DVURLAsset.h"
#import "DVAssetLoaderDelegate.h"

@implementation DVURLAsset

- (instancetype)initWithURL:(NSURL *)URL options:(NSDictionary<NSString *,id> *)options {
    NSParameterAssert(![URL isFileURL]);
    if ([URL isFileURL]) {
        return [super initWithURL:URL options:options];
    }
    
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:URL resolvingAgainstBaseURL:NO];
    components.scheme = [DVAssetLoaderDelegate scheme];
    
    if (self = [super initWithURL:[components URL] options:options]) {
        DVAssetLoaderDelegate *resourceLoaderDelegate = [[DVAssetLoaderDelegate alloc] initWithURL:URL];
        [self.resourceLoader setDelegate:resourceLoaderDelegate queue:dispatch_get_main_queue()];
    }
    
    return self;
}

- (void)setLoaderDelegate:(NSObject<DVAssetLoaderDelegatesDelegate> *)loaderDelegate {
    ((DVAssetLoaderDelegate *)self.resourceLoader.delegate).delegate = loaderDelegate;
}

- (NSObject<DVAssetLoaderDelegatesDelegate> *)loaderDelegate {
    return ((DVAssetLoaderDelegate *)self.resourceLoader.delegate).delegate;
}

@end
