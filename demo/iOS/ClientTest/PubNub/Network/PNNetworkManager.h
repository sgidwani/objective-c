#import <Foundation/Foundation.h>
#import "PNPrivateStructures.h"


#pragma mark Class forward

@class PNRequest;


/**
 @brief      Class which power up network layer for \b PubNub client.
 @discussion Manager used to issue request to \b PubNub services and pre-process responses which 
             will be forwarded to requesting code.

 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface PNNetworkManager : NSObject


///------------------------------------------------
/// @name Information and configuration
///------------------------------------------------

/**
 @brief  Stores reference on block which should be called when underlying session becomes invalid.
 
 @since 4.0
 */
@property (nonatomic, copy) void(^invalidateHandler)(PNNetworkManager *sessionManager, NSError *error);

/**
 @brief      Stores reference on queue on which task completion blocks should be called.
 @discussion After task will be processed, it will call \a success or \a failure block depending on
             results. Those blocks will be called using this queue.
 
 @note  By default this queue set to \c main.
 
 @since 4.0
 */
@property (nonatomic, strong) dispatch_queue_t taskCompletionQueue;


///------------------------------------------------
/// @name Initialization
///------------------------------------------------

/**
 @brief      Construct network manager with predefined configuration.
 @discussion Network manager instance help to enqueue and pre-process request/response data.
 
 @param serviceURL    Reference on service host name which should be used to request data at 
                      specified resource path.
 @param configuration Reference on \a NSURLSession configuration which should be used by manager
                      during it's operation.
 
 @return Configured and ready to use network manager.
 
 @since 4.0
 */
+ (instancetype)managerWithServiceURL:(NSURL *)serviceURL
              andSessionConfiguration:(NSURLSessionConfiguration *)configuration;


///------------------------------------------------
/// @name Session & Tasks management
///------------------------------------------------

/**
 @brief      Invalidate underlying session along with whole manager.
 @discussion This method allow to invalidate session and if required, all active tasks can be
             completed or canceled (depending on \c shouldCompleteTasks flag).
 
 @param shouldCompleteTasks If set to \c YES all active tasks will be completed before underlying
                            session will be marked as 'invalidated'.
 
 @since 4.0
 */
- (void)invalidateWithTaskCompletion:(BOOL)shouldCompleteTasks;

/**
 @brief  Cancel all active tasks.
 @discussion Manager keep tracking active tasks and if required can provide reference on them. This
             method allow to cancel all active tasks w/o underlying session invalidation.
 
 @since 4.0
 */
- (void)cancelAllTasks;


///------------------------------------------------
/// @name Request processing
///------------------------------------------------

/**
 @brief      Send provided request object for processing.
 @discussion This method will built actual network request basing on data provided by request 
             object.
 
 @param request                   Reference on request object which hold information about API which
                                  should be called to get required results.
 @param additionalQueryParameters Dictionary with additional query key/value fields which should be 
                                  added to resource request path.
 @param successBlock              Reference on passed block which should be called in case if task 
                                  for provided request successfully completed and data can be 
                                  received from response.
 @param failureBlock              Reference on passed block which should be called in case if task
                                  for provided request completed with negative result (error or
                                  service respond with error code).
 
 @since 4.0
 */
- (void)sendRequest:(PNRequest *)request withParameters:(NSDictionary *)additionalQueryParameters
            success:(PNTaskSuccessfulCompletionBlock)successBlock
         andFailure:(PNTaskFailureCompletionBlock)failureBlock;

#pragma mark -


@end
