//
//  AFDownloadManager.m
//  AFDownload
//
//  Created by B.H.Liu on 12-12-14.
//  Copyright (c) 2012年 Appublisher. All rights reserved.
//

#import "AFDownloadManager.h"


@interface AFDownloadManager ()

@property (nonatomic,strong) AFHTTPClient *client;

@end

static AFDownloadManager* _manager;

@implementation AFDownloadManager

+ (AFDownloadManager*)sharedManager
{
    @synchronized(self)
    {
        if (_manager == nil)
        {
            _manager = [[super alloc] init];
        }
    }
    return _manager;
}

- (id) init
{
    self = [super init];
    if (self != nil)
    {
        self.client = [[AFHTTPClient alloc] init];
        self.operations = [NSMutableArray array];
        
        if (![[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULT_DOWNLOADS])
        {
            NSArray *array = [NSArray array];
            [[NSUserDefaults standardUserDefaults] setObject:array forKey:USERDEFAULT_DOWNLOADS];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    return self;
}


- (NSString*) fileNameForResourceAtURL:(NSString*)url
{
    NSString * fileName = url;
    if ([url hasPrefix:@"http://"]) fileName = [url substringFromIndex:[@"http://" length]];
    else if ([url hasPrefix:@"https://"]) fileName = [url substringFromIndex:[@"https://" length]];
    
    fileName = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"__"];
    return fileName;
}

- (void)buildNewRequestWithURL:(NSString *)url shouldResume:(BOOL)shouldResume isExcutableInBackground:(BOOL)isExcutableInBackground withCompletionBlock:(void (^)(void))completion andFailureBlock:(void (^)(void))failure
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:[self fileNameForResourceAtURL:url]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    //store the new request url
    NSMutableArray *array = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULT_DOWNLOADS]];
    [array addObject:url];
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:USERDEFAULT_DOWNLOADS];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    AFDownloadRequestOperation *operation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:path shouldResume:YES];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Successfully downloaded file to %@", path);
        
        //remove the completed request
        [array removeObject:operation.request.URL.absoluteString];
        [[NSUserDefaults standardUserDefaults] setObject:array forKey:USERDEFAULT_DOWNLOADS];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.operations removeObject:operation];
        
        //completionblock
        if (completion)
        {
            completion();
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self.operations removeObject:operation];
        
        if (failure)
        {
            failure();
        }
    }];
    
    if (isExcutableInBackground) //highly unrecommended
    {
        __weak AFDownloadRequestOperation *_operation = operation;
        [_operation setShouldExecuteAsInfiniteBackgroundTaskWithExpirationHandler:^BOOL(void)
         {
             if ([array indexOfObject:_operation.request.URL.absoluteString] == NSNotFound)
             {
                 NSLog(@"BackgroundTaskWithExpirationHandler infinite till operation done");
                 return YES;
             }
             else
             {
                 NSLog(@"BackgroundTaskWithExpirationHandler finite when operation is done");
                 return NO;
             }
         }];
    }
    else
    {
        [operation setShouldExecuteAsBackgroundTaskWithExpirationHandler:^void
         {
             NSLog(@"BackgroundTaskWithExpirationHandler");
         }];
    }
    
    [self.client enqueueHTTPRequestOperation:operation];
    
    [self.operations addObject:operation];
    
    //whether to start an operation should be decided by a viewController
    /*
    [operation setProgressiveDownloadProgressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile)
     {
         CGFloat progress = totalBytesReadForFile/(float)totalBytesExpectedToReadForFile;
     }];
    
    [operation start];
    */

}

- (void)invokeAllSuspendedDownloadRequests
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULT_DOWNLOADS]];
    
    for (NSString *requestURL in [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULT_DOWNLOADS])
    {
        if ([array indexOfObject:requestURL]!=NSNotFound) continue;
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestURL]];
        
        AFDownloadRequestOperation *operation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:[self fileNameForResourceAtURL:request.URL.absoluteString] shouldResume:YES];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Successfully downloaded file to %@", [self fileNameForResourceAtURL:request.URL.absoluteString]);
            
            //remove the completed request
            [array removeObject:operation.request.URL.absoluteString];
            [[NSUserDefaults standardUserDefaults] setObject:array forKey:USERDEFAULT_DOWNLOADS];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self.operations removeObject:operation];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            [self.operations removeObject:operation];
        }];
        
        [operation setShouldExecuteAsBackgroundTaskWithExpirationHandler:^(void)
         {
             NSLog(@"BackgroundTaskWithExpirationHandler");
         }];
        
        [self.client enqueueHTTPRequestOperation:operation];
        
        [self.operations addObject:operation];
        
        //whether to start an operation might be controlled by a viewController
    
    }
}

- (NSArray*)onGoingOperations
{
    return self.operations;
}

- (void)pauseAllDownloads
{
    for (AFDownloadRequestOperation *operation in self.operations)
    {
        [operation pause];
    }
}

- (void)resumeAllDownloads
{
    for (AFDownloadRequestOperation *operation in self.operations)
    {
        [operation resume];
    }
}

- (void)cancelAllDownloads
{
    for (AFDownloadRequestOperation *operation in self.operations)
    {
        [operation cancel];
    }
    
    [self.operations removeAllObjects];
}


- (void)resumeDownloadAtIndex:(int)index
{
    [(AFDownloadRequestOperation *)self.operations[index] resume];
}


- (void)pauseDownloadAtIndex:(int)index
{
    [(AFDownloadRequestOperation *)self.operations[index] pause];
}


- (void)cancelDownloadAtIndex:(int)index
{
    [(AFDownloadRequestOperation *)self.operations[index] cancel];
}

@end
