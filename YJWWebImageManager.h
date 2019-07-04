//
//  YJWWebImageRequest.h
//  YJWWebImage
//
//  Created by mac on 2019/6/29.
//  Copyright © 2019 yjw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^RequestSuccessed)(UIImage *_Nullable img, NSError *_Nullable error);
typedef void(^_Nullable PlaceholderCallback)(void);
//typedef void(^Failure)(NSError *error);

typedef enum clearCacheResultType{
    ClearCacheResultTypeSuccessed = 0,//缓存清理成功
    ClearCacheResultTypeFailed = 1,//缓存清理失败
    ClearCacheResultTypeNoCache = 2,//没有缓存文件
} ClearCacheResultType;

@interface YJWWebImageManager : NSObject

+ (instancetype)sharedManager;

- (void)requestWebImageWithURL:(NSString *)url
                     needCache:(BOOL)needCache
           placeholderCallback:(PlaceholderCallback)callback
                     successed:(RequestSuccessed)block;

//图片缓存字节数，单位(Byte)
+ (CGFloat)sizeForCache;

//删除所有缓存图片
+ (ClearCacheResultType)clearCache;

@end

NS_ASSUME_NONNULL_END
