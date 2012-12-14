//
//  ViewController.m
//  AFDownload
//
//  Created by B.H.Liu on 12-12-13.
//  Copyright (c) 2012年 Appublisher. All rights reserved.
//

#import "ViewController.h"
#import "AFDownloadRequestOperation.h"
#import "AFDownloadManager.h"

@interface ViewController ()

@property (nonatomic, strong) UILabel *label1;
@property (nonatomic, strong) UILabel *label2;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.label1 = [[UILabel alloc] init];
    self.label1.frame = CGRectMake(0, 0, 200, 44);
    self.label1.backgroundColor = [UIColor clearColor];
    self.label1.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.label1];
    
    self.label2 = [[UILabel alloc] init];
    self.label2.frame = CGRectMake(0, 0, 200, 144);
    self.label2.backgroundColor = [UIColor clearColor];
    self.label2.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.label2];
    
    
    [[AFDownloadManager sharedManager] buildNewRequestWithURL:@"http://mov.bn.netease.com/movieMP4/2011/6/E/7/S75LE7DE7.mp4" shouldResume:YES isExcutableInBackground:YES];
    [[AFDownloadManager sharedManager] buildNewRequestWithURL:@"http://mov.bn.netease.com/movieMP4/2011/3/1/2/S6UNPKJ12.mp4" shouldResume:YES isExcutableInBackground:YES];
    
    int i = 0;
    for (AFDownloadRequestOperation *operation in [[AFDownloadManager sharedManager] onGoingOperations])
    {
        [operation setProgressiveDownloadProgressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile)
         {
             if (i == 0)
                 [self.label1 performSelector:@selector(setText:) onThread:[NSThread mainThread] withObject:[NSString stringWithFormat:@"%f",totalBytesReadForFile/(float)totalBytesExpectedToReadForFile] waitUntilDone:YES];
             else if (i == 1)
                 [self.label2 performSelector:@selector(setText:) onThread:[NSThread mainThread] withObject:[NSString stringWithFormat:@"%f",totalBytesReadForFile/(float)totalBytesExpectedToReadForFile] waitUntilDone:YES];
         }];
        [operation start];
        i++;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backToForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)backToForeground
{
    NSLog(@"app back to foreground: %@",[[AFDownloadManager sharedManager] onGoingOperations]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
