//
//  AViewController.m
//  iPhoneAgent
//
//  Created by Deepthi Taduvayi on 20/03/13.
//  Copyright (c) 2013 Paradigm. All rights reserved.
//

#import "AViewController.h"
#import "UIDevice-IOKitExtensions.h"
#import "UIDevice-Hardware.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#include <dlfcn.h>
#include <math.h>
#include <dlfcn.h>
#import "CoreTelephony.h"

@interface AViewController ()

@end

@implementation AViewController

CFMachPortRef mach_port;
CTServerConnectionRef conn;
CellInfo a;
int mnc;

void ConnectionCallback(CTServerConnectionRef connection, CFStringRef string, CFDictionaryRef dictionary, void *data)
{
	NSLog(@"ConnectionCallback");
	CFShow(dictionary);
}

void printInfo()
{
	if (!mach_port || !conn) return;
    
    int count = 0;
	_CTServerConnectionCellMonitorGetCellCount(mach_port, conn, &count);
	if (count > 0)
    {
		int i = 0;        
        _CTServerConnectionCellMonitorGetCellInfo(mach_port, conn, i, &a);        
        NSLog(@"Cell site: %d, MNC: %d ", i, a.servingmnc);        
        mnc = a.servingmnc;
	}
    else
    {
		NSLog(@"No Cell info");
	}
}

void start_monitor()
{
	conn = _CTServerConnectionCreate(kCFAllocatorDefault, ConnectionCallback, NULL);
	mach_port_t port  = _CTServerConnectionGetPort(conn);
	mach_port = CFMachPortCreateWithPort(kCFAllocatorDefault,port,NULL,NULL, NULL);
	_CTServerConnectionCellMonitorStart(mach_port,conn);
}

- (void)getCellId
{
    start_monitor();
    printInfo();
    [myTableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(getCellId) userInfo:nil repeats:YES];

    cellInfoArray = [[NSMutableArray arrayWithObjects:@"IMEI", @"iOS Version", @"iPhone Version", @"MNC", nil] retain];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [cellInfoArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    CTTelephonyNetworkInfo *netInfo;
    CTCarrier *carrier;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        [cell.detailTextLabel setTextColor:[UIColor blackColor]];
    }
    netInfo = [[CTTelephonyNetworkInfo alloc] init];
    carrier = [netInfo subscriberCellularProvider];

    // Configure the cell...
    [cell.textLabel setText:[cellInfoArray objectAtIndex:indexPath.row]];
    
    switch (indexPath.row)
    {
        case 0:
            [cell.detailTextLabel setText:[[UIDevice currentDevice] imei]];
            break;
        case 1:
            [cell.detailTextLabel setText:[[UIDevice currentDevice] systemVersion]];
            break;
        case 2:
            [cell.detailTextLabel setText:[[UIDevice currentDevice] platformString]];
            break;
        case 3:
            [cell.detailTextLabel setText:[carrier mobileCountryCode]];
            break;
        default:
            break;
    }
    return cell;
}

- (void)dealloc
{
    [cellInfoArray release];
    [super dealloc];
}

@end
