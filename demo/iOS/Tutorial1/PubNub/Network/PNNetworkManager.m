/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNNetworkManager.h"
#import "PNPrivateStructures.h"
#import "PNRequest+Private.h"
#import <libkern/OSAtomic.h>
#import "PNDictionary.h"
#import "PNRequest.h"
#import "PNLog.h"


#pragma mark Static

/**
 @brief  Cocoa Lumberjack logging level configuration for \b PubNub client class and categories.
 
 @since 4.0
 */
static DDLogLevel ddLogLevel = (DDLogLevel)PNRequestLogLevel;


#pragma mark - Protected interface declaration

@interface PNNetworkManager () <NSURLSessionDelegate, NSURLSessionDataDelegate>


#pragma mark - Information

/**
 @brief  Stores reference on \b PubNub server address which should be used to communicate with
         services.
 
 @since 4.0
 */
@property (nonatomic, strong) NSURL *serviceURL;

/**
 @brief  Stores reference on URL loading session which is used to issue download tasks.
 
 @since 4.0
 */
@property (nonatomic, strong) NSURLSession *session;

/**
 @brief  Stores reference on list of active data tasks.
 
 @since 4.0
 */
@property (nonatomic, strong) NSMutableArray *tasks;

/**
 @brief  Stores reference on spin lock which is used to protect access to active tasks list.
 
 @since 4.0
 */
@property (nonatomic, assign) OSSpinLock tasksSpinLock;

/**
 @brief      Stores reference on queue which should be used to process service response.
 @discussion Processing may include JSON de-serialization process or additional pre-processing.
 
 @since 4.0
 */
@property (nonatomic, strong) dispatch_queue_t processingQueue;


#pragma mark - Initialization

/**
 @brief      Initialize network manager with predefined configuration.
 @discussion Network manager instance help to enqueue and pre-process request/response data.
 
 @param serviceURL    Reference on service host name which should be used to request data at 
                      specified resource path.
 @param configuration Reference on \a NSURLSession configuration which should be used by manager
                      during it's operation.
 
 @return Initialized and ready to use network manager.
 
 @since 4.0
 */
- (instancetype)initWithServiceURL:(NSURL *)serviceURL
           andSessionConfiguration:(NSURLSessionConfiguration *)configuration;


#pragma mark - Constructors

/**
 @brief      Allow to construct resulting request URL.
 @discussion Using data passed with request object this method build full resource request path with
        `    all query parameters (including additional).
 
 @param request                   Reference on request object which hold information about API which
                                  should be called to get required results.
 @param additionalQueryParameters Dictionary with additional query key/value fields which should be
                                  added to resource request path.
 
 @return Constructed URL which can be used with actual network requests.
 
 @since 4.0
 */
- (NSURL *)URLForRequest:(PNRequest *)request
          withParameters:(NSDictionary *)additionalQueryParameters;

/**
 @brief  Allow to construct complete request to fetch or push data to remote services.
 
 @param url      Resource request URL
 @param postBody In case if some data should be pushed to remote service along with request it 
                 should be passed with this parameter.
 
 @return Constructed request which can be used to perform data request.
 
 @since 4.0
 */
- (NSURLRequest *)requestWithURL:(NSURL *)url postBody:(NSData *)postBody;


#pragma mark - Handlers

/**
 @brief  Handler data task processing completion.
 @discussion This handler allow to pre-process data received from service or handle error before
             it will be delivered to the caller.
 
 @param task         Reference on data task which has been used to fetch data from \b PubNub 
                     service.
 @param response     Reference on HTTP response which provide information about service response 
                     itself (w/o body).
 @param error        Reference on error in case if data task execution failed because.
 @param successBlock Reference on passed block which should be called in case if task for provided 
                     request successfully completed and data can be received from response.
 @param failureBlock Reference on passed block which should be called in case if task for provided 
                     request completed with negative result (error or service respond with error 
                     code).
 
 @since 4.0
 */
- (void)handleTaskCompletion:(NSURLSessionDataTask *)task withResponse:(NSURLResponse *)response
                        data:(NSData *)responseData error:(NSError *)error
                     success:(PNTaskSuccessfulCompletionBlock)successBlock
                  andFailure:(PNTaskFailureCompletionBlock)failureBlock;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNNetworkManager


#pragma mark - Logger

/**
 @brief  Called by Cocoa Lumberjack during initalization.
 
 @return Desired logger level for network manager.
 
 @since 4.0
 */
+ (DDLogLevel)ddLogLevel {
    
    return ddLogLevel;
}

/**
 @brief  Allow modify logger level used by Cocoa Lumberjack with logging macros.
 
 @param logLevel New log level which should be used by logger for network manager.
 
 @since 4.0
 */
+ (void)ddSetLogLevel:(DDLogLevel)logLevel {
    
    ddLogLevel = logLevel;
}


#pragma mark - Initialization

+ (instancetype)managerWithServiceURL:(NSURL *)serviceURL
              andSessionConfiguration:(NSURLSessionConfiguration *)configuration {
    
    return [[self alloc] initWithServiceURL:serviceURL andSessionConfiguration:configuration];
}

- (instancetype)initWithServiceURL:(NSURL *)serviceURL
           andSessionConfiguration:(NSURLSessionConfiguration *)configuration {
    
    // Check whether initialization was successful or not
    if ((self = [super init])) {
        
        // Storing user-provided data.
        self.serviceURL = serviceURL;
        
        // Construct URL session with default delegate queue.
        self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self
                                                delegateQueue:nil];
        
        // Prepare objects required for manager operation.
        self.processingQueue = dispatch_queue_create("com.pubnub.network.processing",
                                                     DISPATCH_QUEUE_CONCURRENT);
        self.taskCompletionQueue = dispatch_get_main_queue();
        self.tasks = [NSMutableArray new];
        self.tasksSpinLock = OS_SPINLOCK_INIT;
    }
    
    return self;
}


#pragma mark - Configuration

- (void)setSessionInvalidateHandler:(void(^)(PNNetworkManager *sessionManager,
                                             NSError *error))handlerBlock {
    
    // Invalidate handler block can be specified only once during manager life time.
    if (!self.invalidateHandler) {
        
        self.invalidateHandler = handlerBlock;
    }
}


#pragma mark - Session & Tasks management

- (void)invalidateWithTaskCompletion:(BOOL)shouldCompleteTasks {
    
    if (shouldCompleteTasks) {
        
        [self.session finishTasksAndInvalidate];
    }
    else {
        
        [self.session invalidateAndCancel];
    }
}

- (void)cancelAllTasks {
    
    OSSpinLockLock(&_tasksSpinLock);
    NSArray *tasks = [[self tasks] copy];
    [self.tasks removeAllObjects];
    OSSpinLockUnlock(&_tasksSpinLock);
    for (NSURLSessionDataTask *task in tasks) {
        
        // Cancel task w/o waiting for it's processing results.
        [task cancel];
    }
}


#pragma mark - Constructors

- (NSURL *)URLForRequest:(PNRequest *)request
          withParameters:(NSDictionary *)additionalQueryParameters {
    
    NSURL *URLForRequest = [NSURL URLWithString:request.resourcePath relativeToURL:self.serviceURL];
    if ([request.parameters count] || [additionalQueryParameters count]) {

        // Append request query list.
        id query = additionalQueryParameters;
        if ([request.parameters count]) {

            query = [additionalQueryParameters mutableCopy];
            [query addEntriesFromDictionary:request.parameters];
        }
        NSString *queryString = [NSString stringWithFormat:@"?%@", [PNDictionary queryStringFrom:query]];
        URLForRequest = [NSURL URLWithString:[[URLForRequest absoluteString]stringByAppendingString:queryString]];
    }
    
    return URLForRequest;
}

- (NSURLRequest *)requestWithURL:(NSURL *)url postBody:(NSData *)postBody {
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"GET";
    if (postBody) {
        
        request.allHTTPHeaderFields = @{@"Content-Encoding":@"gzip",
                                        @"Content-Type":@"application/json;charset=UTF-8",
                                        @"Content-Length":[NSString stringWithFormat:@"%@",
                                                           @([postBody length])]};
        [request setHTTPBody:postBody];
        request.HTTPMethod = @"POST";
    }
    
    return request;
}


#pragma mark - Request processing

- (void)sendRequest:(PNRequest *)request withParameters:(NSDictionary *)additionalQueryParameters
            success:(PNTaskSuccessfulCompletionBlock)successBlock
         andFailure:(PNTaskFailureCompletionBlock)failureBlock {
    
    // Prepare request which should be used by data loading task.
    NSURL *taskRequestURL = [self URLForRequest:request withParameters:additionalQueryParameters];
    NSURLRequest *taskRequest = [self requestWithURL:taskRequestURL postBody:request.body];
    
    DDLogRequest(@"<PubNub> %@ %@", (request.body ? @"POST" : @"GET"),
                 [taskRequestURL absoluteString]);
    
    // Request data task from session using constructed request.
    __weak __typeof(self) weakSelf = self;
    __block __weak NSURLSessionDataTask *task = [self.session dataTaskWithRequest:taskRequest
                                                 completionHandler:^(NSData *data,
                                                                     NSURLResponse *response,
                                                                     NSError *error) {
        
        __strong __typeof(self) strongSelf = weakSelf;
        [strongSelf handleTaskCompletion:task withResponse:response data:data error:error
                                 success:[successBlock copy] andFailure:[failureBlock copy]];
    }];
    task.taskDescription = PNOperationTypeStrings[request.operation];
    
    // Store task in list of tracked active tasks.
    OSSpinLockLock(&_tasksSpinLock);
    [self.tasks addObject:task];
    OSSpinLockUnlock(&_tasksSpinLock);
    
    // Launch task.
    [task resume];
}


#pragma mark - Handlers

- (void)handleTaskCompletion:(NSURLSessionDataTask *)task withResponse:(NSURLResponse *)response
                        data:(NSData *)responseData error:(NSError *)error
                     success:(PNTaskSuccessfulCompletionBlock)successBlock
                  andFailure:(PNTaskFailureCompletionBlock)failureBlock {
    
    // Removing task from list of tracked tasks.
    OSSpinLockLock(&_tasksSpinLock);
    [self.tasks removeObject:task];
    OSSpinLockUnlock(&_tasksSpinLock);
    
    // Shift response processing to background queue to keep calling queue/thread responsive.
    __weak __typeof(self) weakSelf = self;
    dispatch_async([self processingQueue], ^{
        
        __strong __typeof(self) strongSelf = weakSelf;
        NSString *serviceResponse = [[NSString alloc] initWithData:responseData
                                                          encoding:NSUTF8StringEncoding];
        
        // Try de-serialize JSON.
        NSError *deSerializationError;
        id responseObject = [NSJSONSerialization JSONObjectWithData:responseData
                                                            options:NSJSONReadingAllowFragments
                                                              error:&deSerializationError];
        
        // Shift completion blocks execution to passed queue.
        dispatch_async(strongSelf.taskCompletionQueue, ^{
            
            // Check whether service returned non-error response or not.
            if (!error && !deSerializationError) {
                
                successBlock(task, responseObject, serviceResponse);
            }
            // Looks like service returned unexpected response or error.
            else {
                
                failureBlock(task, serviceResponse, (error?: deSerializationError));
            }
        });
    });
}


#pragma mark - NSURLSession delegate methods

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
    
    if (self.invalidateHandler) {
        
        self.invalidateHandler(self, error);
    }
}


#pragma mark - NSURLSessionData delegate methods

- (void) URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
  willCacheResponse:(NSCachedURLResponse *)proposedResponse
  completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler {
    
    // Be quiet, cache shouldn't be updated with response for this task
}

#pragma mark -


@end
