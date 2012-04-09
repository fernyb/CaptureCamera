#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>
#import <QuartzCore/QuartzCore.h>


@interface CapturePhoto : NSObject {
  CVImageBufferRef currentImage;
  BOOL failedToInitialize;
  
  QTCaptureDevice * video;
  QTCaptureDecompressedVideoOutput * output;
  QTCaptureInput * input;
  QTCaptureSession * session;
  
  NSInteger delay;
  BOOL didTakePhoto;
  
  NSString * filename;
  CGSize size;
}

@property(readonly) BOOL failedToInitialize;
@property(assign) NSInteger delay;
@property(copy) NSString * filename;
@property(assign) CGSize size;

- (void)initVars;
- (void)begin;
- (void)photoTaken:(NSData *)imageData;
- (NSData *)dataFromImage:(NSImage *)anImage;
- (CIImage *)applyFiltersForImageBuffer:(CVImageBufferRef)imageBufferRef;

@end
