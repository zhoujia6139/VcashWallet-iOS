//
//  ScanViewController.h
//  HLRCode
//
//  Created by 郝靓 on 2018/7/9.
//  Copyright © 2018年 郝靓. All rights reserved.
//

#import "BaseViewController.h"
#import <AVFoundation/AVFoundation.h>

@protocol ScanViewControllerDelegate <NSObject>

- (void)scanWithResult:(NSString *)result;

@end

@interface ScanViewController : BaseViewController

@property (strong, nonatomic) AVCaptureDevice * device;
@property (strong, nonatomic) AVCaptureDeviceInput * input;
@property (strong, nonatomic) AVCaptureMetadataOutput * output;
@property (strong, nonatomic) AVCaptureSession * session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer * preview;

@property (strong, nonatomic) UIPinchGestureRecognizer *pinchGes;

@property (nonatomic,strong)UIImageView *imageView;

@property (nonatomic,retain)UIImageView *line;

@property (nonatomic, weak) id<ScanViewControllerDelegate> delegate;

@end
