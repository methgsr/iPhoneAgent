//
//  AViewController.h
//  iPhoneAgent
//
//  Created by Deepthi Taduvayi on 20/03/13.
//  Copyright (c) 2013 Paradigm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView *myTableView;
    NSMutableArray *cellInfoArray;
}

@end
