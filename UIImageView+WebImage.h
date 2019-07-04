//
//  UIImageView+WebImage.h
//  YJWWebImage
//
//  Created by mac on 2019/6/29.
//  Copyright © 2019 yjw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (WebImage)

//-------------------异步加载 产生缓存 优先使用缓存-----------------------
- (void)yjw_setImageWithURL:(NSString *)imgUrl;

- (void)yjw_setImageWithURL:(NSString *)imgUrl
           placeholderImage:(nullable UIImage *)placeholderImage;

- (void)yjw_setImageWithURL:(NSString *)imgUrl
                  completed:(nullable void(^)(UIImage *image,NSError *error,NSString *imgUrl))completed;

- (void)yjw_setImageWithURL:(NSString *)imgUrl
           placeholderImage:(nullable UIImage *)placeholderImage
                  completed:(nullable void(^)(UIImage *image,NSError *error,NSString *imgUrl))completed;

//-------------------异步加载 不产生并且不使用缓存图片-----------------------
- (void)yjw_n_setImageWithURL:(NSString *)imgUrl;

- (void)yjw_n_setImageWithURL:(NSString *)imgUrl
           placeholderImage:(nullable UIImage *)placeholderImage;

- (void)yjw_n_setImageWithURL:(NSString *)imgUrl
                  completed:(nullable void(^)(UIImage *image,NSError *error,NSString *imgUrl))completed;

- (void)yjw_n_setImageWithURL:(NSString *)imgUrl
           placeholderImage:(nullable UIImage *)placeholderImage
                  completed:(nullable void(^)(UIImage *image,NSError *error,NSString *imgUrl))completed;

@end

NS_ASSUME_NONNULL_END
