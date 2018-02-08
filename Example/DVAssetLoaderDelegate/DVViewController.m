//
//  DVViewController.m
//  DVAssetLoaderDelegate
//
//  Created by vdugnist on 01/02/2018.
//  Copyright (c) 2018 vdugnist. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <DVAssetLoaderDelegate/DVAssetLoader.h>
#import "DVViewController.h"

@interface DVViewController () <DVAssetLoaderDelegatesDelegate>

@property (nonatomic, weak) AVPlayerLayer *playerLayer;

@end

@implementation DVViewController

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    NSURL *url = [NSURL URLWithString:@"http://www.sample-videos.com/video/mp4/720/big_buck_bunny_720p_5mb.mp4"];
    DVURLAsset *asset = [[DVURLAsset alloc] initWithURL:url options:nil];
    asset.loaderDelegate = self;
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    AVPlayer *player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    [self.view.layer addSublayer:playerLayer];
    self.playerLayer = playerLayer;
    [player play];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:playerItem
                                                       queue:nil
                                                  usingBlock:^(NSNotification * _Nonnull note) {
        [player seekToTime:kCMTimeZero];
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.playerLayer.frame = self.view.bounds;
}

- (void)dvAssetLoaderDelegate:(DVAssetLoaderDelegate *)loaderDelegate
                  didLoadData:(NSData *)data
                       forURL:(NSURL *)url {
    NSLog(@"data loaded completely 🎉");
}

- (void)dvAssetLoaderDelegate:(DVAssetLoaderDelegate *)loaderDelegate
                  didLoadData:(NSData *)data
                     forRange:(NSRange)range
                          url:(NSURL *)url {
    NSLog(@"data loaded for range: %@", [NSValue valueWithRange:range]);
}

- (void)dvAssetLoaderDelegate:(DVAssetLoaderDelegate *)loaderDelegate
       didRecieveLoadingError:(NSError *)error
                 withDataTask:(NSURLSessionDataTask *)dataTask
                   forRequest:(AVAssetResourceLoadingRequest *)request {
    NSLog(@"loader delegate did receive error: %@", error.localizedDescription);
}


@end
