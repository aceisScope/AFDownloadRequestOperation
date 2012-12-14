AFDownloadManager
==========================

NOTICE: THIS CLASS IS BASICALLY FOR PERSONAL USE AND I CAN'T GUARANTEE ITS FLAWLESSNESS. NEITHER CAN I ENSURE THE EXAMPLE DOWNLOAD ADDRESSES IN THIS PROJECT WILL WORK OUTSIDE P.R.C..

A class based on [AFDownloadRequestOperation](https://github.com/steipete/AFDownloadRequestOperation). This is only a simple wrapper for multiple download with AFNetworking. 

``` objective-c
    - (void)buildNewRequestWithURL:(NSString *)url shouldResume:(BOOL)shouldResume isExcutableInBackground:(BOOL)isExcutableInBackground
```
Above is the method to build up a resumable download request, and decide whether to execute an infinite background task until the download is completed. But I won't personally recommend that.

### CHANGE IN AFURLConnectionOperation

In order to perform infinite background task, a ```- (void)setShouldExecuteAsInfiniteBackgroundTaskWithExpirationHandler:(BOOL (^)(void))handler;``` is added, based on the original ```- (void)setShouldExecuteAsBackgroundTaskWithExpirationHandler:(void (^)(void))handler;```.

### CONTINUE AN INCOMPLETE DOWNLOAD

1. Every time when a download request is initialed, it will be recorded both in UserDefaults and the "operation" property of this class, which is an array. When the app is brought from background to foreground, in which case it will receive a ```UIApplicationWillEnterForegroundNotification```, we can check ```[[AFDownloadManager sharedManager] onGoingOperations]``` to see how many downloads are still ongoing.
 
2. If an app is in background and terminated by 600s, so next time when app is launched, a new lifecycle starts, ```- (void)invokeAllSuspendedDownloadRequests;``` will invoke the records in UserDefaults and build up new download operations with them.

### AFDownloadRequestOperation

A progressive download operation for AFNetworking. I wrote this to support large PDF downloads in [my iOS PDF framework PSPDFKit](http://pspdfkit.com), but it works for any file type.

While AFNetworking already supports downloading files, this class has additional support to resume a partial download, uses a temporary directory and has a special block that helps with calculating the correct download progress.

AFDownloadRequestOperation is smart with choosing the correct targetPath. If you set a folder, the file name of the downloaded URL will be used, else the file name that is already set.

AFDownloadRequestOperation also relays any NSError that happened during a file operation to the faulure block.

With partially resumed files, the progress delegate needs additional info. The server might only have a few totalByesExpected, but we wanna show the correct value that includes the previous progress.

``` objective-c
    [pdfRequest setProgressiveDownloadProgressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
        self.downloadProgress = totalBytesReadForFile/(float)totalBytesExpectedToReadForFile;
    }];
```

The temporary folder will be automatically created on first access, but an be changed. It defaults to ```<app directory>tmp/Incomplete/```. The temp directory will be cleaned by the system on a regular bases; so a resume will only succeed if there's not much time between.

### AFNetworking

This is tested against the latest AFNetworking branch ([experimental-1.0RC2](https://github.com/AFNetworking/AFNetworking/tree/experimental-1.0RC2)) and uses ARC.


### Creator

[Peter Steinberger](http://github.com/steipete)
[@steipete](https://twitter.com/steipete)

## License

AFDownloadRequestOperation is available under the MIT license. See the LICENSE file for more info.