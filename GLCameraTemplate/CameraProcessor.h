//
//  CameraProcessor.h
//  GLCameraTemplate
//
//  Created by kazuki_tanaka on 2013/05/03.
//  Copyright (c) 2013年 kazukitanaka. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>

@protocol CameraProcessorDelegate <NSObject>

- (void)processCameraFrame:(CMSampleBufferRef)sampleBuffer mediaType:(NSString *)mediaType;
- (void)captureDidStartRinning;

@end

@interface CameraProcessor : NSObject

- (id)initWithDelelgate:(id)delegate;
- (void)switchCamera;
- (void)setFocus:(CGPoint)position;

@property (nonatomic, readonly) NSInteger deviceCount;
@property (nonatomic, readonly) BOOL hasFlash;
@property (nonatomic, readonly) BOOL isFrontCamera;

@end