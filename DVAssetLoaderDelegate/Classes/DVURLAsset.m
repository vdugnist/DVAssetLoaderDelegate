//
//  DVURLAsset.m
//  DVAssetLoaderDelegate
//
//  Created by Vladislav Dugnist on 07/01/2018.
//

#import "DVURLAsset.h"
#import "DVAssetLoaderDelegate.h"

static NSTimeInterval const kDefaultLoadingTimeout = 15;

@interface DVURLAsset()

@property (nonatomic, readonly) DVAssetLoaderDelegate *resourceLoaderDelegate;

@end

@implementation DVURLAsset

- (instancetype)initWithURL:(NSURL *)URL options:(NSDictionary<NSString *,id> *)options {
    return [self initWithURL:URL options:options networkTimeout:kDefaultLoadingTimeout];
}

- (instancetype)initWithURL:(NSURL *)URL
                    options:(NSDictionary<NSString *,id> *)options
             networkTimeout:(NSTimeInterval)networkTimeout {
    NSParameterAssert(![URL isFileURL]);
    if ([URL isFileURL]) {
        return [super initWithURL:URL options:options];
    }
    
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:URL resolvingAgainstBaseURL:NO];
    components.scheme = [DVAssetLoaderDelegate scheme];
    
    if (self = [super initWithURL:[components URL] options:options]) {
        DVAssetLoaderDelegate *resourceLoaderDelegate = [[DVAssetLoaderDelegate alloc] initWithURL:URL];
        resourceLoaderDelegate.networkTimeout = networkTimeout;
        [self.resourceLoader setDelegate:resourceLoaderDelegate queue:dispatch_get_main_queue()];
    }
    
    return self;
}

- (void)setLoaderDelegate:(NSObject<DVAssetLoaderDelegatesDelegate> *)loaderDelegate {
    self.resourceLoaderDelegate.delegate = loaderDelegate;
}

- (NSObject<DVAssetLoaderDelegatesDelegate> *)loaderDelegate {
    return self.resourceLoaderDelegate.delegate;
}

- (DVAssetLoaderDelegate *)resourceLoaderDelegate {
    if ([self.resourceLoader.delegate isKindOfClass:[DVAssetLoaderDelegate class]]) {
        return (DVAssetLoaderDelegate *)self.resourceLoader.delegate;
    }
    return nil;
}

- (void)dealloc {
    [self.resourceLoaderDelegate cancelRequests];
}

@end
