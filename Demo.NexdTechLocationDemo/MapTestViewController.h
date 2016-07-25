//
//  UIViewController+MapTestViewController.h
//  Demo.LocationTest
//
//  Created by Ninespring on 16/4/15.
//  Copyright © 2016年 Ninespring. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationEngine.h"

@import SVGKit;
@import CoreGraphics;
@import CocoaLumberjack;
@import QuartzCore;

@import CoreLocation;
@import CoreBluetooth;


@interface MapTestViewController : UIViewController<CBCentralManagerDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollViewForSVG;

@property (strong, nonatomic) SVGKImage *svgImage;

@property (strong, nonatomic) SVGKFastImageView *svgImageView;

@property (strong, nonatomic) SVGKLayeredImageView *svgLayeredImageView;

@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;

@property (strong, nonatomic) UIView *dotView;

@property (strong, nonatomic) UILabel *svgElementTextLabel;


@property (strong, nonatomic) IBOutlet UIButton *buttonCurrentPosition;
@property (strong, nonatomic) IBOutlet UIButton *buttonBounceOff;
@property (strong, nonatomic) IBOutlet UIButton *buttonChangePosition;
@property (strong, nonatomic) IBOutlet UIButton *buttonBack;

//For Debug
#define LoadedMap @"testMap.svg"
#define BackgroundImage @"backgroundImage_edited.jpg"
#define BuildingID @"101080560001"

//Position Dot Parameters
#define Radius 10.0;
#define BorderRatio 0.25;
#define TestCenter_X 50
#define TestCenter_Y 50

// Use Hex As UIColor Format
#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]


//Define Color Format
#define ElementFilledColor UIColorFromRGB(0xC7EFCF).CGColor
#define ElementAfterFillColor UIColorFromRGB(0xF0B67F).CGColor
#define PositionDotCenterColor UIColorFromRGB(0x2196F3).CGColor
#define PositionDotBorderColor UIColorFromRGB(0xecf0f1).CGColor

//Define Text Display Format
#define SingleLetterWidth 8






//Bluetooth Related Variables

@property (strong, nonatomic) CBCentralManager *cbManager;
@property (strong, nonatomic) CLLocationManager *clocationManager;
@property (strong, nonatomic) NSMutableArray *regions;
@property (strong, nonatomic) CLBeaconRegion *beaconRegion;


//Positioning Related Variables
@property (strong, nonatomic) LocationEngine *locationEngine;
@property (strong, nonatomic) NSArray *wifilist;
@end
