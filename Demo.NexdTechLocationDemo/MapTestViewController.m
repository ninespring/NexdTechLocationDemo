//
//  UIViewController+MapTestViewController.m
//  Demo.LocationTest
//
//  Created by Ninespring on 16/4/15.
//  Copyright © 2016年 Ninespring. All rights reserved.
//

#import "MapTestViewController.h"

@implementation MapTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.svgImage = [SVGKImage imageNamed:LoadedMap];
    
    [self initButtonFunction];
    
    [self displayWithZoomAndHit:self.svgImage];
    
    // Location Related
    NSString *bid = BuildingID;
    [self initLocationEngine:bid];
    
    
    // Beacon Scan Started
    
    NSArray *uuid_list = [NSArray arrayWithObjects:@"EA01CD23-A1B2-C3D4-E5F6-C08B30FB15B0",@"F2C845E6-9AED-24F9-6C6E-887725D19116",@"E91143DE-ED63-903D-BCDB-1E672599A8E5",@"92A01577-A054-9ECC-57F5-7CABE6736241", nil];
    
    [self initBeaconScan:uuid_list];
    
    
    
}


/*
 Location Related Code
 */

- (void)initLocationEngine:(NSString *)bid{
    self.locationEngine= [[LocationEngine alloc] initWithDefaultBuildingID:bid];
    NSURL *wifilistFileUrl = [[NSBundle mainBundle] URLForResource:bid withExtension:@"wifilist"];
    NSString *wifilistLine = [NSString stringWithContentsOfURL:wifilistFileUrl encoding:NSUTF8StringEncoding error:nil];
    self.wifilist = [wifilistLine componentsSeparatedByString:@","];
}

- (double *)getLocationEngineInput:(NSArray <CLBeacon *> *) beacons{
    if (self.wifilist == nil) {
        return nil;
    }
    double *input = (double *)malloc(self.locationEngine.getEngine.col * sizeof(double));
    for (int i = 0; i < self.locationEngine.getEngine.col; i++){
        input[i] = 0.0;
    }
    for (CLBeacon *foundBeacon in beacons) {
        NSString *id = [NSString stringWithFormat:@"%@%@%@", foundBeacon.proximityUUID.UUIDString, foundBeacon.major, foundBeacon.minor];
        NSInteger index = [self.wifilist indexOfObject:id];
        if (NSNotFound == index) {
            continue;
        }
        NSLog(id);
        if (foundBeacon.rssi < -1.0) {
            input[index] = foundBeacon.rssi + 100;
        }
//        input[index] = foundBeacon.rssi ;
        NSString *info = [NSString stringWithFormat:@"%@-%@-%@-%ld", foundBeacon.proximityUUID.UUIDString, foundBeacon.major, foundBeacon.minor, foundBeacon.rssi];
        NSLog(info);
    }
    return input;
}

- (double *)utilizeLocationEngine:(double *)input{
    return [self.locationEngine locatePositionWithInputArray:input];
}

- (void)releaseLocationEngine{
    [self.locationEngine freeParams];
}



/*
 Bluetooth Related Code
 */



- (void) initBeaconScan:(NSArray *)uuid_list{
    self.clocationManager = [[CLLocationManager alloc] init];
    self.clocationManager.delegate = self;
    
    [self beaconScanAuthorizationDetection];
    
    NSString *uuid_string = uuid_list[0];
    NSLog(@"Start With UUID: %@", uuid_string);
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuid_string];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:uuid.UUIDString];
    [self.clocationManager startMonitoringForRegion:self.beaconRegion];
}

- (void) beaconScanAuthorizationDetection{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    NSLog(@"Location Service Status: %d", status);
    
    if (status == kCLAuthorizationStatusNotDetermined) {
        NSLog(@"Location Service Not Decided");
        [self.clocationManager requestWhenInUseAuthorization];
        NSLog(@"Location Service In Use");
    }else if(status == kCLAuthorizationStatusDenied){
        NSLog(@"Location Service Denied");
    }else if([CLLocationManager locationServicesEnabled] == NO){
        NSLog(@"Location Service Disabled");
    }else if(status == kCLAuthorizationStatusAuthorizedWhenInUse){
        NSLog(@"Location Service Authorized When In USE");
    }else if(status == kCLAuthorizationStatusAuthorizedAlways){
        NSLog(@"Location Service Authorized Always");
    }
    
    [self.clocationManager requestAlwaysAuthorization];
}

/*
 我们把locationManager初始化为CLLocationManager的新实例，然后把我们设置为它的委托，这样当更新时就会通知我们。
 
 我们通过同样的UUID设置了NSUUID对象，作为一个被app（先前创建的那个）广播的对象。
 
 最后我们把region传递给location manager 以便于监视。
 */
//

- (void) locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    
    [self.clocationManager startRangingBeaconsInRegion:self.beaconRegion];
}


- (void) locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region{
    
    [self.clocationManager stopRangingBeaconsInRegion:self.beaconRegion];
    
    
}


- (void) locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region{
    [self.clocationManager startRangingBeaconsInRegion:self.beaconRegion];
}



- (void) locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region{
    
    NSLog(@"Found Beacon!");
    NSString *temp = @"Found Beacon!\n";
//    for (CLBeacon *foundBeacon in beacons) {
//        //
//        //
//        //
//        //        NSLog(@"UUID:%@\n",foundBeacon.proximityUUID.UUIDString);
//        //        NSLog(@"RSSI:%ld\n",(long)foundBeacon.rssi);
//        //        NSLog(@"Major:%@",foundBeacon.major);
//        //        NSLog(@"Minor:%@",foundBeacon.minor);
//        
//        temp = [temp stringByAppendingString:[NSString stringWithFormat:@"UUID:%@\n",foundBeacon.proximityUUID.UUIDString]];
//        temp = [temp stringByAppendingString:[NSString stringWithFormat:@"RSSI:%ld\t",(long)foundBeacon.rssi]];
//        temp = [temp stringByAppendingString:[NSString stringWithFormat:@"Major:%@\t",foundBeacon.major]];
//        temp = [temp stringByAppendingString:[NSString stringWithFormat:@"Minor:%@\n",foundBeacon.minor]];
//    }
    double *input =[self getLocationEngineInput:beacons];
    [self displayInputData:input];
    double *res = [self utilizeLocationEngine:input];
    CGPoint newPos = CGPointMake(res[0], res[1]);
    NSLog(@"New Position: %f, %f", res[0], res[1]);
    [self setNewDotPosition:newPos];
}

- (void) displayInputData:(double *)inputData{
    NSString *idd = [NSString stringWithFormat:@"Input Data:"];
    for (int i = 0; i < self.wifilist.count; i++) {
        idd = [idd stringByAppendingString:[NSString stringWithFormat:@"%f ",inputData[i]]];
    }
    NSLog(idd);
}


- (void) stopBeaconScan{
    [self.clocationManager stopMonitoringForRegion:self.beaconRegion];
    [self.clocationManager stopRangingBeaconsInRegion:self.beaconRegion];
    [self.clocationManager stopUpdatingLocation];
    self.clocationManager = nil;
}








/*
 Map Related Code
 */

- (void) setBackGroundImage{
    UIImage *backgroundImage = [UIImage imageNamed:BackgroundImage];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    backgroundImageView.alpha = 0.2;
    backgroundImageView.center = self.svgLayeredImageView.center;
    [self.svgLayeredImageView.layer insertSublayer:backgroundImageView.layer atIndex:0];
}

- (void) initButtonFunction{
    [self.buttonCurrentPosition addTarget:self action:@selector(buttonCurrentPositionPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.buttonBounceOff addTarget:self action:@selector(buttonBounceOffPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.buttonChangePosition addTarget:self action:@selector(buttonChangePositionPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.buttonBack addTarget:self action:@selector(buttonBackPressed:) forControlEvents:UIControlEventTouchUpInside];
}

CGPoint positionPoint;
CALayer *dotLayer;



- (IBAction)buttonCurrentPositionPressed:(id)sender{
    if (self.dotView !=nil) {
        [self.scrollViewForSVG setContentOffset:CGPointMake(self.dotView.layer.position.x - self.scrollViewForSVG.center.x, self.dotView.layer.position.y - self.scrollViewForSVG.center.y)];
    }
}

- (IBAction)buttonBounceOffPressed:(id)sender{
    if (self.scrollViewForSVG != nil) {
        self.scrollViewForSVG.bounces = NO;
        self.scrollViewForSVG.bouncesZoom = NO;
    }
}

- (IBAction)buttonChangePositionPressed:(id)sender{
    if (self.scrollViewForSVG != nil) {
        if (self.dotView != nil) {
            
            [self setNewDotPosition:CGPointMake(70, 60)];
        }
    }
}

- (IBAction)buttonBackPressed:(id)sender{
    [self stopBeaconScan];
    if (self.locationEngine != nil) {
        [self releaseLocationEngine];
    }
}

/*
 使用ImageView作为展示SVG的方式
 SVG的展示使用的是FastImageView
 ImageView通过addSubView完成展示
 */

/*
 使用ScrollImageView作为展示SVG的方式, 可以更好的展示尺寸较大的svg文件
 SVG的展示使用的是FastImageView
 ScrollImageView通过addSubView完成展示
 */


- (void) displayWithZoomAndHit:(SVGKImage *) svgimage{
    if (svgimage != nil) {
        NSLog(@"Start Plotting!");
        self.svgLayeredImageView = [[SVGKLayeredImageView alloc] initWithSVGKImage:svgimage];
        
        self.scrollViewForSVG.delegate = self;
        [self.scrollViewForSVG addSubview:self.svgLayeredImageView];

        [self.scrollViewForSVG setContentSize:CGSizeMake(self.svgLayeredImageView.frame.size.width,self.svgLayeredImageView.frame.size.height)];

        [self.scrollViewForSVG setContentInset:UIEdgeInsetsMake(self.scrollViewForSVG.frame.size.height, 0.95* self.svgLayeredImageView.frame.size.width, self.scrollViewForSVG.frame.size.height, 0.95* self.svgLayeredImageView.frame.size.width)];

        NSLog(@"SVGLayerFrame: %f,%f",self.svgLayeredImageView.frame.size.width,self.svgLayeredImageView.frame.size.height);
        NSLog(@"ScrollView Center: %f, %f",self.scrollViewForSVG.center.x, self.scrollViewForSVG.center.y);
        float scaleRatio = self.scrollViewForSVG.frame.size.width / self.svgLayeredImageView.frame.size.width;
        
        self.scrollViewForSVG.bouncesZoom = YES;
        self.scrollViewForSVG.maximumZoomScale = MAX(5, scaleRatio);
        self.scrollViewForSVG.minimumZoomScale = MIN(1, scaleRatio);
        [self.scrollViewForSVG setZoomScale:scaleRatio*2];
        
        NSLog(@"Current Zoom Scale: %f", scaleRatio);
        
        /** Add gesture recognizer onto the view */
        if (self.tapRecognizer == nil) {
            self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handelTapGesture:)];
        }
        [self.scrollViewForSVG addGestureRecognizer:self.tapRecognizer];
        
        // Modify Loading Sequence
        [self setLayerSequence];
        
        
        // Add Display Position Dot
        [self setupDotLayer];
        [self moveDotLayer:self.scrollViewForSVG.zoomScale];
        
        [self setBackGroundImage];
    }
}


- (void) setLayerSequence{
    for (Element *domelement in [self.svgImage.DOMDocument getElementsByTagName:@"*"]) {
        SVGElement *element = (SVGElement *)domelement;
        NamedNodeMap *attrib = element.attributes;
        Node *class_type = [attrib getNamedItem:@"class"];
        if ([class_type.nodeValue  isEqual: @"frame"]) {
            CALayer *tempLayer = [self.svgImage layerWithIdentifier:element.identifier];
            //            [tempLayer removeFromSuperlayer];
            //            CAShapeLayer *tempShapeLayer = (MyShapeLayer *)tempLayer;
            //            [self.svgLayeredImageView.layer addSublayer:tempShapeLayer];
            
            
            
            
            CALayer *tempSuperLayer = tempLayer.superlayer;
            NSLog(@"Layer Class : %@, %@", tempLayer.class, tempSuperLayer.class);
            [tempLayer removeFromSuperlayer];
            [tempSuperLayer insertSublayer:tempLayer atIndex:0];
        }
    }
}


#pragma mark UIScrollView Delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.svgLayeredImageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withSVGView:(SVGKLayeredImageView *) svgLayeredImageView{
    
}

- (void)scrollViewDidZoom:(UIScrollView *) scrollView{
//    [self.scrollViewForSVG setContentSize:CGSizeMake(self.scrollViewForSVG.bounds.size.width + 2 * self.svgLayeredImageView.frame.size.width, self.scrollViewForSVG.bounds.size.height+ 2 * self.svgLayeredImageView.frame.size.height)];
    [self.scrollViewForSVG setContentInset:UIEdgeInsetsMake(self.scrollViewForSVG.bounds.size.height*0.5, 0.95* self.svgLayeredImageView.bounds.size.width, self.scrollViewForSVG.bounds.size.height*0.5, 0.95* self.svgLayeredImageView.frame.size.width)];
    
    [self moveDotLayer:scrollView.zoomScale];
}

- (void)scrollDidEndZooming:(UIScrollView *) scrollView withView:(UIView *) view atScale:(float) scale{
    NSLog([NSString stringWithFormat:@"Finish Scale : %f",scale]);
    
    view.transform = CGAffineTransformIdentity;
    view.bounds = CGRectApplyAffineTransform(view.bounds, CGAffineTransformMakeScale(scale, scale));
    
    [view setNeedsDisplay];
    
    self.scrollViewForSVG.maximumZoomScale /= scale;
    self.scrollViewForSVG.minimumZoomScale /= scale;
}



#pragma Mark Tap Gesture

CALayer* lastTappedLayer;
CGFloat lastTappedLayerOriginalBorderWidth;
CGColorRef lastTappedLayerOriginalBorderColor;

-(void) deselectTappedLayer
{
    if( lastTappedLayer != nil )
    {
        {
            lastTappedLayer.borderWidth = lastTappedLayerOriginalBorderWidth;
            lastTappedLayer.borderColor = lastTappedLayerOriginalBorderColor;
        }
        lastTappedLayer = nil;
    }
}

CAShapeLayer *lastHitShapeLayer;
//CGColorRef lastColor;

- (void) handelTapGesture:(UITapGestureRecognizer *) recognizer{
    
    CGPoint hitPoint = [recognizer locationInView:self.scrollViewForSVG];
    
    CALayer *hitLayer = [self.svgLayeredImageView.layer hitTest:hitPoint];
    
    NSLog([NSString stringWithFormat:@"Hit On Point: %f, %f\n",hitPoint.x, hitPoint.y]);
    
    BOOL isFrame = [self determineSVGElementsType:self.svgImage withLayer:hitLayer];
    if (isFrame) {
        return ;
    }
    if (hitLayer == lastTappedLayer) {
        [self deselectTappedLayer];
    }
    else{
        [self deselectTappedLayer];
    }
    lastTappedLayer = hitLayer;
    if (lastTappedLayer != nil) {
        lastTappedLayerOriginalBorderColor = lastTappedLayer.borderColor;
        lastTappedLayerOriginalBorderWidth = lastTappedLayer.borderWidth;
    }
    
    if ([hitLayer isKindOfClass:[CAShapeLayer class]]) {
        CAShapeLayer *shapeLayer = (CAShapeLayer *) hitLayer;
        if (lastHitShapeLayer == nil) {
//            lastColor = shapeLayer.fillColor;
            shapeLayer.fillColor = ElementFilledColor;
            lastHitShapeLayer = shapeLayer;
            
        }
        else{
            if (lastHitShapeLayer != shapeLayer) {
                                lastHitShapeLayer.fillColor = ElementAfterFillColor;
//                lastHitShapeLayer.fillColor = lastColor;
                //                lastColor = shapeLayer.fillColor;
                shapeLayer.fillColor = ElementFilledColor;
                lastHitShapeLayer = shapeLayer;
            }
        }
    }
    
    [self fetchSVGElementsByLayer:self.svgImage withLayer:hitLayer];
    
    
}

- (BOOL) determineSVGElementsType:(SVGKImage *)svgImage withLayer:(CALayer *)hitLayer{
    NSString *identifier = hitLayer.name;
    Element *element = [self.svgImage.DOMTree getElementById:identifier];
    if (element != nil) {
        SVGElement *svgElement = (SVGElement *)element;
        NamedNodeMap *svgAttributes = svgElement.attributes;
        Node *title = [svgAttributes getNamedItem:@"class"];
        NSLog(@"Selected Element Type is : %@", title.nodeValue);
        if ([title.nodeValue isEqual:@"frame"]) {
            return TRUE;
        }
        else{
            return FALSE;
        }
        
    }
    else{
        return FALSE;
    }
}



#pragma Mark Solve Position Dot Display Problem
- (void) setupDotLayer{
    float radius = Radius;
    positionPoint = CGPointMake(TestCenter_X, TestCenter_Y);
    self.dotView = [[UIView alloc] init];
    self.dotView.layer.frame = CGRectMake(positionPoint.x, positionPoint.y, radius * 2, radius * 2);
    self.dotView.layer.backgroundColor = PositionDotCenterColor;
    self.dotView.layer.borderWidth = radius * BorderRatio;
    self.dotView.layer.borderColor = PositionDotBorderColor;
    self.dotView.layer.cornerRadius = radius;
    [self.scrollViewForSVG addSubview:self.dotView];
}


- (void) moveDotLayer:(float) zoomScale{
    
    CGPoint newPos = CGPointMake(positionPoint.x * zoomScale, positionPoint.y * zoomScale);
    self.dotView.layer.position = newPos;
    
}

- (void) setNewDotPosition:(CGPoint) newPos{
    float zoomScale = self.scrollViewForSVG.zoomScale;
    CGPoint resPos = CGPointMake(newPos.x * zoomScale, newPos.y * zoomScale);
    self.dotView.layer.position = resPos;
    positionPoint = newPos;
}





// Fetch SVG Related Element

- (void) fetchSVGElementsByLayer:(SVGKImage *)svgImage withLayer:(CALayer *)hitLayer{
    
    NSString *identifier = hitLayer.name;
    Element *element = [self.svgImage.DOMTree getElementById:identifier];
    if (element != nil) {
        SVGElement *svgElement = (SVGElement *)element;
        NamedNodeMap *svgAttributes = svgElement.attributes;
        Node *title = [svgAttributes getNamedItem:@"class"];
        NSLog(@"Selected Element Type is : %@", title.nodeValue);
        Node *poi_name = [svgAttributes getNamedItem:@"name"];
        NSLog(@"Selected Point of Interest is : %@", title.nodeValue);
        NSLog(@"Selected Layer Center is : (%f, %f)", hitLayer.position.x
              , hitLayer.position.y);
        
        [self addLabelFadeInWithAttributes:hitLayer withAttributes:svgAttributes];
        
    }
    else{
        NSLog(@"Didn't Find Related Elements");
    }
}



- (void) addLabelFadeInWithAttributes:(CALayer *)hitLayer withAttributes:(NamedNodeMap *)svgElementAttributes{
    
    NSString *node_content = [svgElementAttributes getNamedItem:@"name"].nodeValue;
    
    if (self.svgElementTextLabel == nil) {
        self.svgElementTextLabel = [[UILabel alloc] init];
        
        float width = SingleLetterWidth * node_content.length;
        self.svgElementTextLabel.frame = CGRectMake(0, 0, width, 10);
        self.svgElementTextLabel.center = hitLayer.position;
        self.svgElementTextLabel.font = [UIFont fontWithName:@"Helvetica" size: 6.0];
        self.svgElementTextLabel.textAlignment = UITextAlignmentCenter;
        self.svgElementTextLabel.text = node_content;
        NSLog(@"Add String To UILabel: %@", node_content);
        [self.svgLayeredImageView addSubview:self.svgElementTextLabel];
    }
    else{
        
        [self.svgElementTextLabel removeFromSuperview];
        self.svgElementTextLabel.text = node_content;
        self.svgElementTextLabel.center = hitLayer.position;
        [self.svgLayeredImageView addSubview:self.svgElementTextLabel];
    }
    
    
}






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
