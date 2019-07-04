//
//  YJWWebImageHelper.h
//  YJWWebImage
//
//  Created by mac on 2019/7/1.
//  Copyright © 2019 yjw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YJWWebImageHelper : NSObject

+ (NSString *)imagePathAtPath:(NSString *)imgPath;
+ (NSString *)folderPath;

//生成源图像的高质量缩放版本
+ (UIImage *)image:(UIImage *)image lanczosScaleTransform:(CGFloat)scale;

+ (NSString *)md5StringByString:(NSString *)str;

+ (UIImage *)createImageWithCIImage:(CIImage *)ciImage;

@end

NS_ASSUME_NONNULL_END
