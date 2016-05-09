//
//  TableViewController.m
//  NNPlayground
//
//  Created by 杨培文 on 16/5/9.
//  Copyright © 2016年 杨培文. All rights reserved.
//

#import "TableViewController.h"

@interface TableViewController ()

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self.tableView setScrollEnabled:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return data.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    [cell.textLabel setText:(NSString*)data[indexPath.row]];
    if(indexPath.row == selection){
        [cell setAccessoryType: UITableViewCellAccessoryCheckmark];
    }
    return cell;
}

block selected;
int selection = 1;
- (void)initWithData:(NSMutableArray*)_data
           selection:(int)_selection
              sender:(UIView*)sender
            selected:(block)_selected
{
    data = _data;
    selected = _selected;
    selection = _selection;
    self.modalPresentationStyle = UIModalPresentationPopover;
    self.preferredContentSize = CGSizeMake(300, 44 * _data.count - 1);
    
    self.popoverPresentationController.sourceView = sender;
    self.popoverPresentationController.sourceRect = CGRectMake(0, 0, sender.frame.size.width, sender.frame.size.height);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selected((int)indexPath.row);
}


@end
