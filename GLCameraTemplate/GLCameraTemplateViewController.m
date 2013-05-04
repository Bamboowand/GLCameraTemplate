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

    // UIToolbar
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44,
                                                                     self.view.frame.size.width, 44)];
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
- (void)processCameraFrame:(CMSampleBufferRef)sampleBuffer
{
    CVImageBufferRef cameraFrame = CMSampleBufferGetImageBuffer(sampleBuffer);

    CVPixelBufferLockBaseAddress(cameraFrame, 0);
    
    [self.glView drawFrame:cameraFrame];

    if (self.videoRecorder.isRecording)
    {
        [self.videoRecorder writeSampleAtTime:CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer)];
    }

    CVPixelBufferUnlockBaseAddress(cameraFrame, 0);
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

#pragma - mark
- (void)recordBarButtonItemClick:(UIBarButtonItem *)barButtonItem
{
    if (!self.videoRecorder.isRecording)
    {
        [self.videoRecorder startRecording:self.glView.bounds];
    }
    else
    {
        NSURL *movieURL = [self.videoRecorder stopRecording];

        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeVideoAtPathToSavedPhotosAlbum:movieURL
                                    completionBlock:^(NSURL *assetURL, NSError *error){
        }];
    }
}

@end
