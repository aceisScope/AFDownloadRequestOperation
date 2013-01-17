//
//  AFDownloadManager.h
//  AFDownload
//
//  Created by B.H.Liu on 12-12-14.
//  Copyright (c) 2012年 Appublisher. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AFHTTPClient.h"
#import "AFDownloadRequestOperation.h"

#define USERDEFAULT_DOWNLOADS @"userdefault_downloads"

@interface AFDownloadManager : NSObject

@property (nonatomic, strong) NSMutableArray *operations;


+ (id)sharedManager;

//all on-going downloads
- (NSArray*)onGoingOperations;

//this is the method to invoke all uncompleted download recorded in UserDefault that are due to termination of 600s background task, normally should be called when app is launched (a new app lifecycle, onGoingOperations is destroyed)
- (void)invokeAllSuspendedDownloadRequests;

//build up a new download
/**
 @param isExcutableInBackground:YES this will execute an tricky infinite background task until download is completed. not recommended.
 */
- (void)buildNewRequestWithURL:(NSString *)url shouldResume:(BOOL)shouldResume isExcutableInBackground:(BOOL)isExcutableInBackground;

- (void)resumeAllDownloads;
- (void)cancelAllDownloads;
- (void)pauseAllDownloads;
- (void)resumeDownloadAtIndex:(int)index;
- (void)pauseDownloadAtIndex:(int)index;
- (void)cancelDownloadAtIndex:(int)index;

@end
