//
//  APIDebug.m
//  TLMessageView
//
//  Created by 郭锐 on 16/8/24.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import "APIDebug.h"
#import <CommonCrypto/CommonDigest.h>
#import "TLProjectMacro.h"

static NSString *Host      = @"https://api.cn.ronghub.com";
static NSString *Url       = @"/message/private/publish.json";
static NSString *AppKey    = @"y745wfm844a4v";
static NSString *Appsecret = @"eIPrvtxgHw";

static NSString *const kAFCharactersGeneralDelimitersToEncode =@":#[]@"; // does not include "?" or "/" due to RFC 3986 - Section 3.4
static NSString *const kAFCharactersSubDelimitersToEncode = @"!$&'()*+,;=";


@interface APIDebug () <UIActionSheetDelegate>

@end

@implementation APIDebug
+(void)configWithVC:(UIViewController *)vc{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"APIDebug" style:UIBarButtonItemStylePlain target:self action:@selector(debugAction)];
    vc.navigationItem.rightBarButtonItem = item;
}
+(void)debugAction{
    ActionSheet *sheet = [[ActionSheet alloc] initWithTitle:@"模拟融云服务器向当前用户发送消息" cancelButtonTitle:@"取消" destructiveButtonTitle:nil action:^(NSInteger x) {
        NSString *content = nil;
        NSString *objName = nil;
        
        NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
        [allowedCharacterSet removeCharactersInString:[kAFCharactersGeneralDelimitersToEncode stringByAppendingString:kAFCharactersSubDelimitersToEncode]];
        
        switch (x) {
            case 1:
            {
                content = @"{\"content\":\"hello\",\"extra\":\"helloExtra\"}";
                objName = @"RC:TxtMsg";
            }
                break;
            case 2:
            {
                
                content = @"{\"content\":\"iVBORw0KGgoAAAANSUhEUgAAAA8AAAARCAIAAACNaGH2AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAACg0lEQVQokQXBS2+UZRQA4HPe23cfOkNn2grShmmpBMMCMRoSFv4C1+re6MKFf8XEJf+jbtiTuNGFaQSkpWl1mDKl813fy3mPz4NnS1+NegdUaNlyAjQkmHrwgJKl1rbxyhQsOyExOpGNfDD5WOU9aIUkdZEKRJmMpFTnLrABkfRsK3KAoP47e2ttaPp1AJD1ek0sAtVD75v60eMvt3fujWJo2DeqaNypevbrL9F7RAGI3jnmyIAcWTC+ev3XTz/+3G1uSeuEdKt1UPP5/OTNCccoAbbu3s1kyjKqTJpI7QDnXXsr1JTNEtcebu6pL55+9eb1MwaAGB9+9vjzJwcmmbr2fVpOUhhpgA/QZeR7qWRktfvgweZs8/Ld0iP++fuLadr6fLe9XIhMOVLGDtOD+e7OtknyAQiXFP54fvTb0RFRZOBSZV4gSJR+sCyctYcP73/97Xf11ZpiJSLT/SdPhVTMLIWsqUffeTu4CMBhNKlWy0VuaTr7aDzWSsXBpOV8f358fGwA8py/+eH70WRPKefWC13eJiYSqTB+659KFCzl4Lf3trUQlqFrpKmmG0YZsZFN9ot03IY6SMx9cvVJEB+Qg6Zbn97TKBA4xPD29GWtCkE2QiJ9O8tvCxBWgbmwQusSIx3ODiAzMTIgtv92uq9tUiq0jZAWqABlADGAWF+8HISIIEZlkRZJVpjr99dqqDWI7O+FDCKhwBBrCt0dgxfXFzfTaq3y66tL3a+suVHKVbqxf746DX5jZzY2SB71DXIdEC6pEWw49p5UmuY5vDqjSXK5UOOPdQxsSuNarzOJ0rtOSDYxdizkcFI774f+ZgXVbHJHqUSnJTKRziDKDCmcw//w3WEJ8Go/SwAAAABJRU5ErkJggg==\",\"imageUri\":\"http://7i7gc6.com1.z0.glb.clouddn.com/emoji.png\",\"extra\":\"helloExtra\"}";
                
                objName = @"RC:ImgMsg";
            }
                break;
            case 3:
            {
                content = @"{\"content\":\"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\",\"duration\":2,\"extra\":\"helloExtra\"}";
                
                
                objName = @"RC:VcMsg";

            }
                break;
            case 4:
            {
                content = @"{\"content\":\"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\",\"latitude\":40.032149,\"longitude\":116.417613,\"poi\":\"北京经济技术研修学院(北苑路)\",\"extra\":\"helloExtra\"}";
                
                objName = @"RC:LBSMsg";

            }
                break;
            default:
                break;
        }
        content = [content stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];

        [APIDebug sendMsgWithContent:content objectName:objName success:^{
            
        } failure:^(NSError *error) {
            
        }];
        
    } otherButtonTitles:@[@"发送文字消息",@"发送图片消息",@"发送语音消息",@"发送地理位置消息"]];
    [sheet showInView:kKeyWindow];
}
+(void)sendMsgWithContent:(NSString *)content
               objectName:(NSString *)objectName
                  success:(void (^)())success
                  failure:(void (^)(NSError *))failure{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",Host,Url]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:10];
    
    NSString *random = @(1000000000 + (arc4random() % (1000000000 - 1))).stringValue;
    
    NSString *appKey = AppKey;
    
    NSString *secret = Appsecret;
    
    NSString *time = [@([[NSDate date] timeIntervalSince1970]).stringValue componentsSeparatedByString:@"."][0];
    
    NSString *signature = [self sha1:[NSString stringWithFormat:@"%@%@%@",secret,random,time]];
    
    NSDictionary *header = @{@"App-Key":appKey,@"Timestamp":time,@"Nonce":random,@"Signature":signature,@"Content-Type":@"application/x-www-form-urlencoded"};
    [request setAllHTTPHeaderFields:header];
    
    NSString *params = [NSString stringWithFormat:@"content=%@&fromUserId=%@&toUserId=%@&objectName=%@",content,@"222",@"111",objectName];
    
    NSData *bodyData = [params dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    NSURLSessionDataTask *task = [ [NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            failure(error);
        }else{
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSLog(@"%@",json);
        }
    }];
    [task resume];
    
}
+(NSString*)dataTOjsonString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}
+ (NSString *) sha1:(NSString *)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (unsigned int)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i=0; i<CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}
@end



@interface ActionSheet ()
@property(nonatomic,copy)void (^actionBlock)(NSInteger);
@end

@implementation ActionSheet
-(instancetype)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle action:(void(^)(NSInteger))action otherButtonTitles:(NSArray *)otherButtonTitles{
    if (self = [super initWithTitle:title delegate:self cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:nil]) {
        self.actionBlock = action;
        
        for (NSString *title in otherButtonTitles) {
            [self addButtonWithTitle:title];
        }
    }
    return self;
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    self.actionBlock(buttonIndex);
}
@end
