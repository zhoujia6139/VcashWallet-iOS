//
//  HandleSlateViewController.m
//  VcashWallet
//
//  Created by jia zhou on 2019/4/29.
//  Copyright © 2019年 blockin. All rights reserved.
//

#import "HandleSlateViewController.h"
#import "VcashSlate.h"
#import "WalletWrapper.h"
#import "ReceiveTransactionFileViewController.h"


@interface HandleSlateViewController ()

@property (weak, nonatomic) IBOutlet UILabel *walletIdLabel;

@property (weak, nonatomic) IBOutlet UIButton *btnCopy;


@property (weak, nonatomic) IBOutlet UIImageView *scanQR;

@property (weak, nonatomic) IBOutlet VcashButton *btnReceiveTxFile;

@property (weak, nonatomic) IBOutlet UITextView *proofAddrView;

@end

@implementation HandleSlateViewController{
    NSString *walletId;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = [LanguageService contentForKey:@"receiveVcash"];
    ViewRadius(self.btnCopy, 4.0);
    walletId = [WalletWrapper getWalletUserId];
    
    self.walletIdLabel.text = walletId;
    
    CIImage *ciImage = [self createQRCodeWithUrlString:walletId];
    UIImage *imageQRCode = [self adjustQRImageSize:ciImage QRSize:170];
    self.scanQR.image = imageQRCode;
    [self.btnReceiveTxFile setTitle:[NSString stringWithFormat:@"%@ >>",[LanguageService contentForKey:@"receiveTransactionFile"]] forState:UIControlStateNormal];
    
    self.proofAddrView.text = [WalletWrapper getPaymentProofAddress];
}

- (CIImage*)createQRCodeWithUrlString:(NSString*)url{
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    NSData *data = [url dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"];
    CIImage *qrCode = [filter outputImage];
    return qrCode;
}

- (UIImage*)adjustQRImageSize:(CIImage*)ciImage QRSize:(CGFloat)qrSize{
    CGRect ciImageRect = CGRectIntegral(ciImage.extent);
    CGFloat scale = MIN(qrSize / CGRectGetWidth(ciImageRect), qrSize / CGRectGetHeight(ciImageRect));
    size_t width = CGRectGetWidth(ciImageRect) * scale;
    size_t height = CGRectGetHeight(ciImageRect) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(YES)}];
    CGImageRef bitmapImage = [context createCGImage:ciImage fromRect:ciImageRect];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, ciImageRect, bitmapImage);
    
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    
    return [UIImage imageWithCGImage:scaledImage];
}

- (IBAction)clickedBtnCopyWalletId:(id)sender {
    UIPasteboard *pastboard = [UIPasteboard generalPasteboard];
    [pastboard setString:walletId];
    [self.view makeToast:[LanguageService contentForKey:@"copySuc"]];
}


- (IBAction)clickedBtnReceiveTransactionFile:(id)sender {
    [self pushReceiveTransactionFileVc];
}


- (void)pushReceiveTransactionFileVc{
    ReceiveTransactionFileViewController *receiveFileVc = [[ReceiveTransactionFileViewController alloc] init];
    [self.navigationController pushViewController:receiveFileVc animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
