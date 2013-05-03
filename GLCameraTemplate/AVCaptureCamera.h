//
//  AVCaptureCamera.h
//  GLCameraTemplate
//
//  Created by kazuki_tanaka on 2013/05/03.
//  Copyright (c) 2013年 kazukitanaka. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AVCaptureCameraDelegate <NSObject>

- (void)processCameraFrame:(CVImageBufferRef)cameraFream;

@end

@interface AVCaptureCamera : NSObject

- (id)initWithDelelgate:(id)aDelegate;

@end
