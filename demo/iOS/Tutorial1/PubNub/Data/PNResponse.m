/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNResponse.h"


#pragma mark Protected interface declaration

@interface PNResponse ()


#pragma mark - Information

@property (nonatomic, copy) NSURLRequest *clientRequest;
@property (nonatomic, copy) id data;
@property (nonatomic, copy) NSHTTPURLResponse *response;
@property (nonatomic, strong) NSString *serviceResponse;
@property (nonatomic, copy) NSError *error;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNResponse


#pragma mark - Initialization and configuration

+ (instancetype)responseWith:(NSHTTPURLResponse *)response forRequest:(NSURLRequest *)request
         withServiceResponse:(NSString *)serviceResponse data:(id)responseObject
                    andError:(NSError *)error {

    return [[self alloc] initWith:response forRequest:request withServiceResponse:serviceResponse
                             data:responseObject andError:error];
}

- (instancetype)initWith:(NSHTTPURLResponse *)response forRequest:(NSURLRequest *)request
     withServiceResponse:(NSString *)serviceResponse data:(id)responseObject
                andError:(NSError *)error {

    // CHeck whether initialization has been successful or not.
    if ((self = [super init]))  {

        self.response = response;
        self.clientRequest = request;
        NSMutableString *headers = [NSMutableString new];
        for (NSString *headerFieldName in self.response.allHeaderFields) {

            [headers appendFormat:@"%@: %@\n", headerFieldName,
                                  self.response.allHeaderFields[headerFieldName]];
        }
        self.serviceResponse = [[NSString alloc] initWithFormat:@"%@\n%@", headers, serviceResponse];
        self.data = responseObject;
        self.error = error;
    }

    return self;
}

#pragma mark -


@end
