//
//  TableViewController.h
//  NNPlayground
//
//  Created by 杨培文 on 16/5/9.
//  Copyright © 2016年 杨培文. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewController : UITableViewController{
    NSMutableArray *data;
}

typedef void(^block)(int index);
- (void)initWithData:(NSMutableArray*)_data
           selection:(int)_selection
              sender:(UIView*)_sender
            selected:(block)_selected;

@end
