//
//  WebViewController.m
//  NNPlayground
//
//  Created by 杨培文 on 16/5/15.
//  Copyright © 2016年 杨培文. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _webView.delegate = self;
    _webView.frame = CGRectMake(0, 0, 400, 1000);
    self.modalPresentationStyle = UIModalPresentationPopover;
    NSURL * u =[NSURL URLWithString:myurl];
    NSURLRequest * request =[NSURLRequest requestWithURL:u];
    [_webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setURL:(NSString *)url
        sender:(UIView *)sender
{
    self->myurl = url;
    self.modalPresentationStyle = UIModalPresentationPopover;
    self.preferredContentSize = _webView.frame.size;
    self.popoverPresentationController.sourceView = sender;
    self.popoverPresentationController.sourceRect = CGRectMake(0, 0, sender.frame.size.width, sender.frame.size.height);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [_waitView removeFromSuperview];
    [_waitLabel removeFromSuperview];
}

@end
