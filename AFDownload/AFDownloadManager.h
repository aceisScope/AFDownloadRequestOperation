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

//this is the method to invoke all uncompleted download recorded in UserDefault, called when app is launched
- (void)invokeAllSuspendedDownloadRequests;

//build up a new download
- (void)buildNewRequestWithURL:(NSString *)url shouldResume:(BOOL)shouldResume isExcutableInBackground:(BOOL)isExcutableInBackground;

- (void)startAllDownloads;
- (void)cancelAllDownloads;

@end
