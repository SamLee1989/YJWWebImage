//
//  YJWWebImageHelper.m
//  YJWWebImage
//
//  Created by mac on 2019/7/1.
//  Copyright © 2019 yjw. All rights reserved.
//

#import "YJWWebImageHelper.h"
#import <CommonCrypto/CommonDigest.h>

@implementation YJWWebImageHelper

+ (NSString *)imagePathAtPath:(NSString *)imgPath{
    return [NSString stringWithFormat:@"%@%@.tmp",[self folderPath],[self md5StringByString:imgPath]];
}
+ (NSString *)folderPath{
    return [NSString stringWithFormat:@"%@/Documents/YJWWebImage/",NSHomeDirectory()];
}

//生成源图像的高质量缩放版本
+ (UIImage *)image:(UIImage *)image lanczosScaleTransform:(CGFloat)scale{
    CIFilter *filter = [CIFilter filterWithName:@"CILanczosScaleTransform" keysAndValues:kCIInputImageKey,[CIImage imageWithCGImage:[image CGImage]], nil];
    //缩放比列
    [filter setValue:[NSNumber numberWithFloat:scale] forKey:kCIInputScaleKey];
    //宽高比
    [filter setValue:[NSNumber numberWithFloat:1.0] forKey:kCIInputAspectRatioKey];
    return [self createImageWithCIImage:filter.outputImage];
}

+ (NSString *)md5StringByString:(NSString *)str
{
    const char *cStr = [str UTF8String];
    //加密规则
    unsigned char result[16] = "0123456789abcdef";
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    //这里的x是小写则产生的md5也是小写，x是大写则md5是大写
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+ (UIImage *)createImageWithCIImage:(CIImage *)ciImage{
    //创建基于CPU的CIContext对象
    CIContext *context = [CIContext contextWithOptions:
                          [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                      forKey:kCIContextUseSoftwareRenderer]];
    if(ciImage){
        // 创建CGImage句柄
        CGImageRef cgImage = [context createCGImage:ciImage
                                           fromRect:[ciImage extent]];
        UIImage *maskImage = [UIImage imageWithCGImage:cgImage];
        // 释放CGImage句柄
        CGImageRelease(cgImage);
        
        return maskImage;
    }
    return nil;
}

@end
