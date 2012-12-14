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
- (void)invokeAllSuspendedDownloadRequests;
- (void)buildNewRequestWithURL:(NSString *)urlRequest shouldResume:(BOOL)shouldResume;

- (void)startAllDownloads;
- (void)cancelAllDownloads;

@end
