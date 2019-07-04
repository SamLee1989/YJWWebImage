//
//  YJWWebImageRequest.m
//  YJWWebImage
//
//  Created by mac on 2019/6/29.
//  Copyright © 2019 yjw. All rights reserved.
//

#import "YJWWebImageManager.h"
#import "YJWWebImageHelper.h"

typedef void(^ErrorBlock)(NSError **err);

@interface YJWWebImageManager ()<NSURLSessionDownloadDelegate>{
}

@property (nonatomic,copy) RequestSuccessed successedBlock;
@property (nonatomic,strong) UIImage *resultImage;
@property (nonatomic,assign) BOOL needCache;

@end

static YJWWebImageManager *_manager;

@implementation YJWWebImageManager

+ (instancetype)sharedManager{
    if(!_manager){
        _manager = [YJWWebImageManager new];
    }
    return _manager;
}

- (void)requestWebImageWithURL:(NSString *)url
                     needCache:(BOOL)needCache
           placeholderCallback:(PlaceholderCallback)callback
                     successed:(RequestSuccessed)block{
    self.needCache = needCache;
    if(self.needCache){
        UIImage *cacheImage = [self thumbImageCacheWithAddress:url];
        if(cacheImage){
            //使用缓存
            block(cacheImage,nil);
        }else{
            if(callback){
                callback();
            }
            [self doRequestWithUrl:url successed:block];
        }
    }else{
        if(callback){
            callback();
        }
        [self doRequestWithUrl:url successed:block];
    }
}

- (void)doRequestWithUrl:(NSString *)url
               successed:(nonnull RequestSuccessed)block{
        self.successedBlock = block;
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                              delegate:self
                                                         delegateQueue:nil];
        NSURLSessionDownloadTask *task = [session downloadTaskWithURL:[NSURL URLWithString:url]];
        [task resume];
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location{
    NSData *data = [NSData dataWithContentsOfURL:location options:NSDataReadingMappedIfSafe error:nil];
    NSString *absoluteString = downloadTask.currentRequest.URL.absoluteString;
    self.resultImage = [UIImage imageWithData:data];//[[UIImage alloc] initWithData:data scale:[UIScreen mainScreen].scale];
    //UIImage *scaleImage = [[UIImage alloc] initWithCGImage:image.CGImage scale:[UIScreen mainScreen].scale orientation:image.imageOrientation];
    if(self.needCache){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self writeImageData:UIImageJPEGRepresentation(self.resultImage, 0.5) toCacheFolder:[YJWWebImageHelper imagePathAtPath:absoluteString]];
        });
    }

    //释放session 由于以上方式声明的session的delegate为强引用 如果不显式调用以下方法 将会导致内存泄漏 则此类对象不会被f释放
    [session finishTasksAndInvalidate];
    session = nil;
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error{
    NSString *absoluteString = task.currentRequest.URL.absoluteString;
    __block YJWWebImageManager *manager = self;
    if(self.successedBlock){
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self.needCache){
                UIImage *cacheImage = [self thumbImageCacheWithAddress:absoluteString];
                if(cacheImage){
                    //使用缓存
                    manager.successedBlock(cacheImage,error);
                }else{
                    manager.successedBlock(self.resultImage,error);
                }
            }else{
                manager.successedBlock(self.resultImage,error);
            }
        });
    }
}

//- (void)URLSession:(NSURLSession *)session
//      downloadTask:(NSURLSessionDownloadTask *)downloadTask
//      didWriteData:(int64_t)bytesWritten
// totalBytesWritten:(int64_t)totalBytesWritten
//totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
//    //NSLog(@"data %lld writeData %lld totalBytesExpectedToWrite %lld",bytesWritten,totalBytesWritten,totalBytesExpectedToWrite);
//}

- (UIImage *)thumbImageCacheWithAddress:(NSString *)absoluteString{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:[YJWWebImageHelper imagePathAtPath:absoluteString]]){
        //查找大图
        NSData *data = [NSData dataWithContentsOfFile:[YJWWebImageHelper imagePathAtPath:absoluteString]];
        if(data){
            // NSLog(@"%.2f",data.length / 1024.0);
            //return [[UIImage alloc] initWithData:data scale:[UIScreen mainScreen].scale];
            return [UIImage imageWithData:data];
        }
    }
    return nil;
}

- (void)writeImageData:(NSData *)data toCacheFolder:(NSString *)folder{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:[YJWWebImageHelper folderPath]]){
        [fileManager createDirectoryAtPath:[YJWWebImageHelper folderPath]
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    }
    if(data){
        if(![fileManager fileExistsAtPath:folder]){
            //写入原图
            [data writeToFile:folder atomically:YES];
        }
    }
}

- (UIImage*)transformImage:(UIImage *)image width:(CGFloat)width height:(CGFloat)height{
    CGFloat destW = width;
    CGFloat destH = height;
    CGFloat sourceW = width;
    CGFloat sourceH = height;
    CGImageRef imageRef = image.CGImage;
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                destW,
                                                destH,
                                                CGImageGetBitsPerComponent(imageRef),
                                                4*destW,
                                                CGImageGetColorSpace(imageRef),
                                                (kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst));
    CGContextDrawImage(bitmap, CGRectMake(0, 0, sourceW, sourceH), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage *result = [UIImage imageWithCGImage:ref];
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    return result;
}

+ (CGFloat)sizeForCache{
    CGFloat size = 0.0;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory;
    if([fileManager fileExistsAtPath:[YJWWebImageHelper folderPath] isDirectory:&isDirectory]){
        if(isDirectory){
            NSError *err;
            NSArray <NSString *> *directoryContents = [fileManager contentsOfDirectoryAtPath:[YJWWebImageHelper folderPath]
                                                                                       error:&err];
            if(!err && directoryContents.count > 0){
                for(NSString *fileName in directoryContents){
                    NSString *finalFileName = [NSString stringWithFormat:@"%@%@",[YJWWebImageHelper folderPath],fileName];
                    NSData *data = [NSData dataWithContentsOfFile:finalFileName];
                    size += data.length;
                }
            }
        }
    }
    return size;
}

+ (ClearCacheResultType)clearCache{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory;
    if([fileManager fileExistsAtPath:[YJWWebImageHelper folderPath] isDirectory:&isDirectory]){
        if(isDirectory){
            NSError *err;
            NSArray <NSString *> *directoryContents = [fileManager contentsOfDirectoryAtPath:[YJWWebImageHelper folderPath]
                                                                                       error:&err];
            if(!err && directoryContents.count > 0){
                int count = 0;
                for(NSString *fileName in directoryContents){
                    NSString *finalFileName = [NSString stringWithFormat:@"%@%@",[YJWWebImageHelper folderPath],fileName];
                    NSError *error;
                    if([fileManager removeItemAtPath:finalFileName error:&error]){
                        count++;
                    }
                }
                if(count == directoryContents.count){
                    return ClearCacheResultTypeSuccessed;
                }else{
                    return ClearCacheResultTypeFailed;
                }
            }
        }
    }
    return ClearCacheResultTypeNoCache;
}

- (void)dealloc{
    NSLog(@"dealloc");
}

@end
