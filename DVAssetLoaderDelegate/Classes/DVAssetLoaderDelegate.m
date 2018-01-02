//
//  DVURLAssetResourceLoader.m
//
//  Created by Vladislav Dugnist on 31/12/2017.
//  Copyright © 2017 vdugnist. All rights reserved.
//

#import <MobileCoreServices/UTType.h>
#import "DVAssetLoaderDelegate.h"
#import "DVAssetLoaderHelpers.h"

@interface DVAssetLoaderDelegate () <NSURLSessionDelegate, NSURLSessionDataDelegate>

@property (nonatomic, readonly) NSURL *originalURL;
@property (nonatomic, readonly) NSString *originalScheme;

@property (nonatomic) NSMutableArray<AVAssetResourceLoadingRequest *> *pendingRequests;
@property (nonatomic) NSMutableArray<NSURLSessionDataTask *> *dataTasks;
@property (nonatomic) NSMutableArray<NSMutableData *> *datas;
@property (nonatomic) NSMutableDictionary<NSValue *, NSData *> *datasForSavingToCache;

@end

@implementation DVAssetLoaderDelegate

#pragma mark - Public

- (instancetype)initWithURL:(NSURL *)url {
    NSParameterAssert([url.scheme.lowercaseString hasPrefix:@"http"]);

    if (self = [super init]) {
        _originalURL = url;
        _originalScheme = url.scheme;
        _pendingRequests = [NSMutableArray new];
        _dataTasks = [NSMutableArray new];
        _datas = [NSMutableArray new];
        _datasForSavingToCache = [NSMutableDictionary new];
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                 delegate:self
                                            delegateQueue:[NSOperationQueue mainQueue]];
    }

    return self;
}

- (instancetype)init {
    @throw [NSString stringWithFormat:@"Init unavailable. Use %@ instead.", NSStringFromSelector(@selector(initWithURL:))];
}

+ (instancetype) new {
    @throw [NSString stringWithFormat:@"New unavailable. Use alloc %@ instead.", NSStringFromSelector(@selector(initWithURL:))];
}

+ (NSString *)scheme {
    return NSStringFromClass(self);
}

#pragma mark - Resource loader delegate

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    if (![loadingRequest.request.URL.scheme isEqualToString:[[self class] scheme]]) {
        return NO;
    }

    NSUInteger loadingRequestIndex = NSNotFound;

    loadingRequestIndex = [self.pendingRequests indexOfObjectPassingTest:^BOOL(AVAssetResourceLoadingRequest *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if (![obj.request isEqual:loadingRequest.request]) {
            return NO;
        }

        if (obj.dataRequest.requestedOffset != loadingRequest.dataRequest.requestedOffset) {
            return NO;
        }

        if (obj.dataRequest.requestedLength != loadingRequest.dataRequest.requestedLength) {
            return NO;
        }

        return YES;
    }];

    if (loadingRequestIndex == NSNotFound) {
        NSURL *actualURL = [self urlForLoadingRequest:loadingRequest];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:actualURL];

        if (loadingRequest.contentInformationRequest) {
            request.HTTPMethod = @"HEAD"; // do not download data for content information request
        }
        else if (loadingRequest.dataRequest.requestsAllDataToEndOfResource) {
            long long requestedOffset = loadingRequest.dataRequest.requestedOffset;
            request.allHTTPHeaderFields = @{ @"Range" : [NSString stringWithFormat:@"bytes=%lld-", requestedOffset] };
        }
        else if (loadingRequest.dataRequest) {
            long long requestedOffset = loadingRequest.dataRequest.requestedOffset;
            long long requestedLength = loadingRequest.dataRequest.requestedLength;
            request.allHTTPHeaderFields = @{ @"Range" : [NSString stringWithFormat:@"bytes=%lld-%lld", requestedOffset, requestedOffset + requestedLength - 1] };
        }
        else {
            return NO;
        }

        // when resource loader generates new request it is not interested in previous, so we can safely cancel them to save traffic
        [self.dataTasks enumerateObjectsUsingBlock:^(NSURLSessionDataTask *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            [obj cancel];
        }];

        if (@available(iOS 11, *)) {
            request.cachePolicy = NSURLRequestUseProtocolCachePolicy;
        }
        else {
            // On iOS <= 10 NSURLCache ignores range header and can return wrong chunk of data
            // https://forums.developer.apple.com/thread/92119
            request.cachePolicy = [request.HTTPMethod isEqualToString:@"HEAD"] ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringCacheData;
        }

        NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request];
        [dataTask resume];

        [self.datas addObject:[NSMutableData new]];
        [self.dataTasks addObject:dataTask];
        [self.pendingRequests addObject:loadingRequest];

        return YES;
    }

    return NO;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSUInteger index = [self.pendingRequests indexOfObject:loadingRequest];

    NSParameterAssert(index != NSNotFound);
    if (index == NSNotFound) {
        return;
    }

    // should call delegate task:didCompleteWithError: that would cleanup resources
    [self.dataTasks[index] cancel];
}

#pragma mark - NSURLSession delegate

- (void)URLSession:(NSURLSession *)session
              dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveResponse:(NSURLResponse *)response
     completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    NSUInteger index = [self.dataTasks indexOfObject:dataTask];

    NSParameterAssert(index != NSNotFound);
    if (index == NSNotFound) {
        return;
    }

    AVAssetResourceLoadingRequest *loadingRequest = self.pendingRequests[index];
    loadingRequest.response = response;

    if (loadingRequest.contentInformationRequest) {
        [self fillInContentInformation:loadingRequest.contentInformationRequest fromResponse:response];
        [loadingRequest finishLoading];
        NSURLSessionDataTask *dataTask = self.dataTasks[index];
        [self.pendingRequests removeObjectAtIndex:index];
        [self.dataTasks removeObjectAtIndex:index];
        [self.datas removeObjectAtIndex:index];
        [dataTask cancel];
    }

    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    NSUInteger index = [self.dataTasks indexOfObject:dataTask];

    NSParameterAssert(index != NSNotFound);
    if (index == NSNotFound) {
        return;
    }

    AVAssetResourceLoadingRequest *loadingRequest = self.pendingRequests[index];

    long long requestedOffset = loadingRequest.dataRequest.requestedOffset;
    long long currentOffset = loadingRequest.dataRequest.currentOffset;
    long long length = loadingRequest.dataRequest.requestedLength;

    NSMutableData *mutableData = self.datas[index];
    NSParameterAssert(mutableData.length == currentOffset - requestedOffset);

    if (![self isRangeOfRequest:dataTask.currentRequest
            equalsToRangeOfResponse:(NSHTTPURLResponse *)dataTask.response
                    requestToTheEnd:loadingRequest.dataRequest.requestsAllDataToEndOfResource]) {
        data = [self subdataFromData:data
                          forRequest:dataTask.currentRequest
                            response:(NSHTTPURLResponse *)dataTask.response
                      loadingRequest:loadingRequest];
    }

    if (!data) {
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain
                                             code:NSURLErrorBadServerResponse
                                         userInfo:@{ NSLocalizedDescriptionKey : @"Server returned wrong range of data or empty data" }];
        [loadingRequest finishLoadingWithError:error];
        [dataTask cancel];

        if ([self.delegate respondsToSelector:@selector(dvAssetLoaderDelegate:didRecieveLoadingError:withDataTask:forRequest:)]) {
            [self.delegate dvAssetLoaderDelegate:self didRecieveLoadingError:error withDataTask:dataTask forRequest:loadingRequest];
        }

        return;
    }

    [mutableData appendData:data];

    if (loadingRequest.dataRequest.requestsAllDataToEndOfResource) {
        long long currentDataResponseOffset = currentOffset - requestedOffset;
        long long currentDataResponseLength = mutableData.length - currentDataResponseOffset;
        [loadingRequest.dataRequest respondWithData:[mutableData subdataWithRange:NSMakeRange((NSUInteger)currentDataResponseOffset, (NSUInteger)currentDataResponseLength)]];
    }
    else if (currentOffset - requestedOffset <= mutableData.length) {
        [loadingRequest.dataRequest respondWithData:[mutableData subdataWithRange:NSMakeRange((NSUInteger)(currentOffset - requestedOffset), (NSUInteger)MIN(mutableData.length - (currentOffset - requestedOffset), length))]];
    }
    else {
        [loadingRequest finishLoading];
        [self.pendingRequests removeObjectAtIndex:index];
        [self.datas removeObjectAtIndex:index];
        [self.dataTasks[index] cancel];
        [self.dataTasks removeObjectAtIndex:index];
    }
}

- (BOOL)isRangeOfRequest:(NSURLRequest *)request equalsToRangeOfResponse:(NSHTTPURLResponse *)response requestToTheEnd:(BOOL)requestToTheEnd {
    NSString *requestRange = rangeFromRequest(request);
    NSString *responseRange = rangeFromResponse(response);
    return requestToTheEnd ? [responseRange hasPrefix:requestRange] : [requestRange isEqualToString:responseRange];
}

- (NSData *)subdataFromData:(NSData *)data
                 forRequest:(NSURLRequest *)request
                   response:(NSHTTPURLResponse *)response
             loadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSString *requestRange = rangeFromRequest(request);
    NSString *responseRange = rangeFromResponse(response);

    NSInteger requestFrom = [[[requestRange componentsSeparatedByString:@"-"] firstObject] integerValue];
    NSInteger requestTo = [[[requestRange componentsSeparatedByString:@"-"] lastObject] integerValue];

    NSInteger responseFrom = [[[responseRange componentsSeparatedByString:@"-"] firstObject] integerValue];
    NSInteger responseTo = [[[responseRange componentsSeparatedByString:@"-"] lastObject] integerValue];

    NSParameterAssert(requestFrom >= responseFrom);
    if (requestFrom < responseFrom) {
        return nil;
    }

    NSParameterAssert(requestFrom < responseTo);
    if (requestFrom >= responseTo) {
        return nil;
    }

    NSParameterAssert(data.length > requestFrom - responseFrom);
    if (data.length <= requestFrom - responseFrom) {
        return nil;
    }

    if (loadingRequest.dataRequest.requestsAllDataToEndOfResource) {
        return [data subdataWithRange:NSMakeRange(requestFrom - responseFrom, data.length - (requestFrom - responseFrom))];
    }

    NSParameterAssert(responseTo >= requestTo);
    if (responseTo < requestTo) {
        return nil;
    }

    return [data subdataWithRange:NSMakeRange(requestFrom - responseFrom, requestTo - requestFrom + 1)];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionDataTask *)task didCompleteWithError:(nullable NSError *)error {
    NSUInteger index = [self.dataTasks indexOfObject:task];

    if (index == NSNotFound) {
        return;
    }

    AVAssetResourceLoadingRequest *loadingRequest = self.pendingRequests[index];

    if (error) {
        [loadingRequest finishLoadingWithError:error];
    }
    else {
        [loadingRequest finishLoading];
    }

    NSData *loadedData = self.datas[index];
    long long requestedOffset = loadingRequest.dataRequest.requestedOffset;
    NSUInteger length = loadedData.length;
    long long fullLength = [[(NSHTTPURLResponse *)task.response allHeaderFields][@"Content-Range"] componentsSeparatedByString:@"/"].lastObject.longLongValue;
    [self processData:loadedData forOffset:requestedOffset length:length fullLength:fullLength];

    [self.pendingRequests removeObjectAtIndex:index];
    [self.datas removeObjectAtIndex:index];
    [self.dataTasks removeObjectAtIndex:index];

    BOOL isCancelledError = [error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled;
    if (error && !isCancelledError && [self.delegate respondsToSelector:@selector(dvAssetLoaderDelegate:didRecieveLoadingError:withDataTask:forRequest:)]) {
        [self.delegate dvAssetLoaderDelegate:self didRecieveLoadingError:error withDataTask:task forRequest:loadingRequest];
    }
}

#pragma mark - Downloaded data processing

- (void)fillInContentInformation:(AVAssetResourceLoadingContentInformationRequest *)contentInformationRequest fromResponse:(NSURLResponse *)response {
    NSString *mimeType = [response MIMEType];
    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(mimeType), NULL);

    contentInformationRequest.contentType = CFBridgingRelease(contentType);

    if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
        return;
    }

    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    contentInformationRequest.byteRangeAccessSupported = [httpResponse.allHeaderFields[@"Accept-Ranges"] isEqualToString:@"bytes"];

    NSString *contentRange = httpResponse.allHeaderFields[@"Content-Range"];
    if (!contentRange) {
        contentInformationRequest.contentLength = [response expectedContentLength];
    }
    else {
        contentInformationRequest.contentLength = [contentRange componentsSeparatedByString:@"/"].lastObject.longLongValue;
    }
}

- (void)processData:(NSData *)data forOffset:(long long)offset length:(NSUInteger)length fullLength:(long long)fullLength {
    if (fullLength == 0 || data.length == 0) {
        return;
    }

    NSRange range = NSMakeRange((NSUInteger)offset, length);
    NSValue *rangeValue = [NSValue valueWithRange:range];
    self.datasForSavingToCache[rangeValue] = data;

    if ([self.delegate respondsToSelector:@selector(dvAssetLoaderDelegate:didLoadData:forRange:url:)]) {
        [self.delegate dvAssetLoaderDelegate:self didLoadData:data forRange:range url:self.originalURL];
    }

    NSData *dataToSave = concatedDataFromRanges(self.datasForSavingToCache, fullLength);
    if (dataToSave && [self.delegate respondsToSelector:@selector(dvAssetLoaderDelegate:didLoadData:forURL:)]) {
        [self.delegate dvAssetLoaderDelegate:self didLoadData:dataToSave forURL:self.originalURL];
    }
}

#pragma mark - Helpers

- (NSURL *)urlForLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSURL *interceptedURL = [loadingRequest.request URL];
    return [self fixedURLFromURL:interceptedURL];
}

- (NSURL *)fixedURLFromURL:(NSURL *)url {
    NSURLComponents *actualURLComponents = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
    actualURLComponents.scheme = self.originalScheme;
    return [actualURLComponents URL];
}

@end
