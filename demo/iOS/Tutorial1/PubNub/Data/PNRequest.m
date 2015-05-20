/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNRequest+Private.h"
#import "PNResult.h"
#import "PNStatus.h"


#pragma mark Protected interface declaration

@interface PNRequest (Protected)


#pragma mark - Initialization and configuration

/**
 @brief  Initialize request instance with predefined configuration (the only way to pass data into
         this class).
 
 @param resourcePath    Stores reference on path which will be used to get access to \b PubNub
                        services.
 @param queryParameters Stores reference on query parameters storage which should be passed along 
                        with resource path.
 @param type            Represent type of operation which should be issued to \b PubNub service.
 @param block           Stores reference on block which should be called at the end of operation
                        processing.
 
 @return Configured and ready to use request instance.
 
 @since 4.0
 */
- (instancetype)initWithPath:(NSString *)resourcePath parameters:(NSDictionary *)queryParameters
                forOperation:(PNOperationType)type withCompletion:(dispatch_block_t)block;

#pragma mark -

@end


#pragma mark - Interface implementation

@implementation PNRequest


#pragma mark - Initialization and configuration

+ (instancetype)requestWithPath:(NSString *)resourcePath parameters:(NSDictionary *)queryParameters
                   forOperation:(PNOperationType)type withCompletion:(dispatch_block_t)block {
    
    return [[self alloc] initWithPath:resourcePath parameters:queryParameters forOperation:type
                       withCompletion:block];
}

- (instancetype)initWithPath:(NSString *)resourcePath parameters:(NSDictionary *)queryParameters
                forOperation:(PNOperationType)type withCompletion:(dispatch_block_t)block {
 
    // Check whether initialization has been successful or not.
    if ((self = [super init])) {
        
        _operation = type;
        _resourcePath = [resourcePath copy];
        _parameters = [(queryParameters?: @{}) copy];
        _completionBlock = [block copy];
    }
    
    return self;
}

#pragma mark -


@end
