//
//  GLCameraTemplateViewController.m
//  GLCameraTemplate
//
//  Created by kazuki_tanaka on 2013/05/01.
//  Copyright (c) 2013年 kazukitanaka. All rights reserved.
//

#import "GLCameraTemplateViewController.h"

#import <AudioToolbox/AudioToolbox.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "OpenGLView.h"
#import "AVCaptureCamera.h"
#import "VideoRecorder.h"

#import "PhotoPrevieViewController.h"

@interface GLCameraTemplateViewController ()

@property (nonatomic, strong) OpenGLView *glView;
@property (nonatomic, strong) AVCaptureCamera *camera;
@property (nonatomic, strong) VideoRecorder *videoRecorder;

@end

@implementation GLCameraTemplateViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    // Camera
    self.camera = [[AVCaptureCamera alloc] initWithDelelgate:self];

    // Video Recorder
    self.videoRecorder = [[VideoRecorder alloc] init];

    // OpenGL View
    self.glView = [[OpenGLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.glView];

    if (1 < self.camera.deviceCount)
    {
        UIButton *switchCameraButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        switchCameraButton.frame = CGRectMake(245.0f, 10.0f, 70.0f, 35.0f);
        switchCameraButton.backgroundColor = [UIColor clearColor];
        [switchCameraButton addTarget:self
                               action:@selector(switchCameraButtonClick:)
                     forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:switchCameraButton];
    }
    
    // UIToolbar
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44.0f,
                                                                     self.view.frame.size.width, 44.0f)];
    [self.view addSubview:toolbar];

    // Shutter Button
    UIBarButtonItem *shutterButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                                                      target:self
                                                                                      action:@selector(shutterButtonItemClick:)];

    UIBarButtonItem *recordButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"rec"
                                                                         style:UIBarButtonItemStyleBordered
                                                                        target:self
                                                                        action:@selector(recordBarButtonItemClick:)];
    toolbar.items = @[ shutterButtonItem, recordButtonItem ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark
- (void)processCameraFrame:(CMSampleBufferRef)sampleBuffer mediaType:(NSString *)mediaType
{
    CVImageBufferRef cameraFrame = CMSampleBufferGetImageBuffer(sampleBuffer);

    CVPixelBufferLockBaseAddress(cameraFrame, 0);

    if (self.videoRecorder.isRecording)
    {
        [self.videoRecorder writeSample:sampleBuffer frame:self.glView.bounds mediaType:AVMediaTypeVideo];
    }
    
    [self.glView drawFrame:cameraFrame];

    CVPixelBufferUnlockBaseAddress(cameraFrame, 0);
}

#pragma - mark
- (void)captureDidStartRinning
{
    [self.camera setFocus:self.glView.center];
}

#pragma - mark
- (void)shutterButtonItemClick:(UIBarButtonItem *)barButtonItem
{
    AudioServicesPlaySystemSound(1108);

    __block UIImage *saveImage = [self.glView convertUIImage];

    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:saveImage.CGImage
                               orientation:(ALAssetOrientation)saveImage.imageOrientation
                           completionBlock:^(NSURL *assetURL, NSError *error){

                               PhotoPrevieViewController *controller = [[PhotoPrevieViewController alloc]initWithImage:saveImage];
                               [self presentViewController:controller animated:YES completion:NULL];
                           }];
}

#pragma mark -
- (void)recordBarButtonItemClick:(UIBarButtonItem *)barButtonItem
{
    if (!self.videoRecorder.isRecording)
    {
        AudioServicesPlaySystemSound(1117);
        [self.videoRecorder startRecording:self.glView.bounds];
    }
    else
    {
        AudioServicesPlaySystemSound(1118);
        NSURL *movieURL = [self.videoRecorder stopRecording];

        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeVideoAtPathToSavedPhotosAlbum:movieURL
                                    completionBlock:^(NSURL *assetURL, NSError *error){
        }];
    }
}

#pragma mark -
- (void)switchCameraButtonClick:(UIButton *)button
{
    [self.camera switchCamera];
}

#pragma mark - dealloc
- (void)dealloc
{
    self.glView = nil;
    self.camera = nil;
    self.videoRecorder = nil;
}

@end
