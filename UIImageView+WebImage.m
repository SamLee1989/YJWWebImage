//
//  UIImageView+WebImage.m
//  YJWWebImage
//
//  Created by mac on 2019/6/29.
//  Copyright © 2019 yjw. All rights reserved.
//

#import "UIImageView+WebImage.h"
#import "YJWWebImageManager.h"
#import "YJWWebImageHelper.h"
#import <objc/runtime.h>

static NSString *imageIdentifierKey = @"imageIdentifierKey";
static NSString *placeholderImageKey = @"placeholderImageKey";

@interface UIImageView ()

@property (nonatomic,copy) NSString *imageIdentifier;
@property (nonatomic,strong) UIImage *placeholderImage;

@end

@implementation UIImageView (WebImage)

- (void)yjw_setImageWithURL:(NSString *)imgUrl{
    [self yjw_setImageWithURL:imgUrl
             placeholderImage:nil];
}

- (void)yjw_setImageWithURL:(NSString *)imgUrl
           placeholderImage:(nullable UIImage *)placeholderImage{
    [self yjw_setImageWithURL:imgUrl
             placeholderImage:placeholderImage
                    completed:nil];
}

- (void)yjw_setImageWithURL:(NSString *)imgUrl
                  completed:(nullable void(^)(UIImage *image,NSError *error,NSString *imgUrl))completed{
    [self yjw_setImageWithURL:imgUrl
             placeholderImage:nil
                    completed:completed];
}

- (void)yjw_setImageWithURL:(NSString *)imgUrl
           placeholderImage:(nullable UIImage *)placeholderImage
                  completed:(nullable void(^)(UIImage *image,NSError *error,NSString *imgUrl))completed{
    self.placeholderImage = placeholderImage;
    __block UIImageView *imageView = self;
    if([self needsUpdateImageWithAddress:imgUrl]){
        YJWWebImageManager *manager = [YJWWebImageManager new];
        [manager requestWebImageWithURL:imgUrl
                              needCache:YES
                    placeholderCallback:^{
                        imageView.image = placeholderImage;
                    } successed:^(UIImage * _Nullable img, NSError * _Nullable error) {
                        imageView.image = img;
                        if(completed){
                            completed(img,error,imgUrl);
                        }
                    }];
    }
    self.imageIdentifier = imgUrl;
}

- (void)yjw_n_setImageWithURL:(NSString *)imgUrl{
    [self yjw_n_setImageWithURL:imgUrl
               placeholderImage:nil];
}

- (void)yjw_n_setImageWithURL:(NSString *)imgUrl
             placeholderImage:(nullable UIImage *)placeholderImage{
    [self yjw_n_setImageWithURL:imgUrl
               placeholderImage:placeholderImage
                      completed:nil];
}

- (void)yjw_n_setImageWithURL:(NSString *)imgUrl
                    completed:(nullable void(^)(UIImage *image,NSError *error,NSString *imgUrl))completed{
    [self yjw_n_setImageWithURL:imgUrl
               placeholderImage:nil
                      completed:completed];
}

- (void)yjw_n_setImageWithURL:(NSString *)imgUrl
             placeholderImage:(nullable UIImage *)placeholderImage
                    completed:(nullable void(^)(UIImage *image,NSError *error,NSString *imgUrl))completed{
    self.placeholderImage = placeholderImage;
    __block UIImageView *imageView = self;
    YJWWebImageManager *manager = [YJWWebImageManager new];
    [manager requestWebImageWithURL:imgUrl
                          needCache:NO
                placeholderCallback:^{
                    imageView.image = placeholderImage;
                    
                }
                          successed:^(UIImage * _Nullable img, NSError * _Nullable error) {
                              imageView.image = img;
                              if(completed){
                                  completed(img,error,imgUrl);
                              }
                          }];
}

- (BOOL)needsUpdateImageWithAddress:(NSString *)imageUrl{
    if(self.image && self.image != self.placeholderImage){
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:[YJWWebImageHelper imagePathAtPath:imageUrl]]){
            if([imageUrl isEqualToString:self.imageIdentifier]){
                return NO;
            }
        }
    }
    return YES;
}

- (void)setImageIdentifier:(NSString *)imageIdentifier{
    objc_setAssociatedObject(self, &imageIdentifierKey, imageIdentifier, OBJC_ASSOCIATION_COPY);
}

- (NSString *)imageIdentifier{
    return objc_getAssociatedObject(self, &imageIdentifierKey);
}

- (void)setPlaceholderImage:(UIImage *)placeholderImage{
    objc_setAssociatedObject(self, &placeholderImageKey, placeholderImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)placeholderImage{
    return objc_getAssociatedObject(self, &placeholderImageKey);
}

@end
