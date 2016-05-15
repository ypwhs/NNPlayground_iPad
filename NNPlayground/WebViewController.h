//
//  WebViewController.h
//  NNPlayground
//
//  Created by 杨培文 on 16/5/15.
//  Copyright © 2016年 杨培文. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate>{
    NSString * myurl;
}

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *waitView;
@property (weak, nonatomic) IBOutlet UILabel *waitLabel;
- (void)setURL:(NSString *)url
        sender:(UIView *)sender;

@end
