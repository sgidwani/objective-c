/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNStatus+Private.h"
#import <AFURLResponseSerialization.h>
#import "PNPrivateStructures.h"
#import "PNStatus+Private.h"
#import "PNResult+Private.h"
#import "PNResponse.h"
#import "PNLog.h"


#pragma mark Private interface

@interface PNStatus ()


#pragma mark - Interpretation

/**
 @brief Try interpret response status code meaningful status object state.

 @param statusCode HTTP response status code which should be used during interpretation.

 @since 4.0
 */
- (PNStatusCategory)categoryTypeFromStatusCode:(NSInteger)statusCode;

/**
 @brief Try interpret error object to meaningful status object state.

 @param error Reference on error which should be used during interpretation.

 @since 4.0
 */
- (PNStatusCategory)categoryTypeFromError:(NSError *)error;

/**
 @brief Try extract useful data from error object (in case if service provided some feedback).

 @param error Reference on error from which data should be pulled out.

 @since 4.0
 */
- (NSDictionary *)dataFromError:(NSError *)error;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNStatus

+ (instancetype)statusForOperation:(PNOperationType)operation category:(PNStatusCategory)category {
    
    PNStatus *status = [PNStatus new];
    status.operation = operation;
    status.category = category;
    
    return status;
}

+ (instancetype)statusFromResult:(PNResult *)result {

    return [[self alloc] initForRequest:result.requestObject
                              withError:result.requestObject.response.error];
}

+ (instancetype)statusForRequest:(PNRequest *)request withError:(NSError *)error {
    
    return [[self alloc] initForRequest:request withError:error];
}

- (instancetype)initForRequest:(PNRequest *)request withError:(NSError *)error {
    
    // Check whether initialization has been successful or not.
    if ((self = [super initForRequest:request])) {
        
        NSError *processingError = (error?: request.response.error);
        
        // Check whether status should represent acknowledgment or not.
        if (request.response.response.statusCode == 200 && !processingError) {
            
            self.category = PNAcknowledgmentCategory;
        }
        else {
            
            // Try extract category basing on response status codes.
            self.category = [self categoryTypeFromStatusCode:request.response.response.statusCode];

            // Extract status category from passed error object.
            if (self.category == PNUnknownCategory) {
                
                self.category = [self categoryTypeFromError:processingError];
            }
        }
        _subCategory = self.category;
        self.error = (self.category != PNAcknowledgmentCategory);
        if (self.isError && ![self.data count]) {
            
            self.data = ([self dataParsedAsError:request.response.data]?: [self dataFromError:error]);
        }
        self.data = (([self.data count] ? self.data : [self dataFromError:error]) ?: request.response.data);
        if (self.category == PNUnknownCategory) {
            
            NSLog(@"<PubNub> Status with unknown operation: %@", [self dictionaryRepresentation]);
        }
    }
    
    return self;
}


#pragma mark - Recovery

- (void)retry {

    if (self.retryBlock) {

        self.retryBlock();
    }
}

- (void)cancelAutomaticRetry {

    if (self.retryCancelBlock) {

        self.retryCancelBlock();
    }
}


#pragma mark - Interpretation

- (PNStatusCategory)categoryTypeFromStatusCode:(NSInteger)statusCode {
    
    PNStatusCategory category = PNUnknownCategory;
    if (statusCode == 403) {
        
        category = PNAccessDeniedCategory;
    }
    
    return category;
}

- (PNStatusCategory)categoryTypeFromError:(NSError *)error {

    PNStatusCategory category = PNUnknownCategory;
    if ([error.domain isEqualToString:NSURLErrorDomain]) {
        
        switch (error.code) {
            case NSURLErrorTimedOut:
                
                category = PNTimeoutCategory;
                break;
            case NSURLErrorCannotFindHost:
            case NSURLErrorCannotConnectToHost:
            case NSURLErrorNetworkConnectionLost:
            case NSURLErrorDNSLookupFailed:
            case NSURLErrorNotConnectedToInternet:

                category = PNNetworkIssuesCategory;
                break;
            case NSURLErrorCannotDecodeContentData:
            case NSURLErrorBadServerResponse:

                category = PNMalformedResponseCategory;
                break;
            case NSURLErrorBadURL:

                category = PNBadRequestCategory;
                break;
            case NSURLErrorCancelled:

                category = PNCancelledCategory;
                break;
            case NSURLErrorSecureConnectionFailed:

                category = PNSSLConnectionFailedCategory;
                break;
            case NSURLErrorServerCertificateUntrusted:
                
                category = PNSSLUntrustedCertificateCategory;
                break;
            default:
                break;
        }
    }
    else if ([error.domain isEqualToString:NSCocoaErrorDomain]) {
        
        switch (error.code) {
            case NSPropertyListReadCorruptError:
                
                category = PNMalformedResponseCategory;
                break;
                
            default:
                break;
        }
    }
    else if ([error.domain isEqualToString:AFURLResponseSerializationErrorDomain]) {
        
        switch (error.code) {
            case NSURLErrorBadServerResponse:
                
                category = PNMalformedResponseCategory;
                break;
                
            default:
                break;
        }
    }
    
    return category;
}

- (NSDictionary *)dataFromError:(NSError *)error {
    
    NSDictionary *data = nil;
    NSString *information = error.userInfo[NSLocalizedDescriptionKey];
    if (!information) {
        
        information = error.userInfo[@"NSDebugDescription"];
    }
    
    if (information) {
        
        data = @{@"information":information};
    }
    
    return data;
}


#pragma mark - Misc

- (NSDictionary *)dictionaryRepresentation {
    
    NSMutableDictionary *status = [[super dictionaryRepresentation] mutableCopy];
    [status addEntriesFromDictionary:@{@"Category": @{
                                               @"Main": PNStatusCategoryStrings[self.category],
                                               @"Additional": PNStatusCategoryStrings[self.subCategory]},
                                       @"Secure": (self.isSSLEnabled ? @"YES" : @"NO"),
                                       @"Objects": @{@"Channels": (self.channels?: @"no channels"),
                                                     @"Channel groups": (self.groups?: @"no groups")},
                                       @"UUID": (self.uuid?: @"uknonwn"),
                                       @"Authorization": (self.authorizationKey?: @"not set"),
                                       @"Time": @{@"Current": (self.currentTimetoken?: @(0)),
                                                  @"Previous": (self.previousTimetoken?: @(0))}}];
    
    return [status copy];
}

@end