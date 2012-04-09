#import "CapturePhoto.h"

@implementation CapturePhoto
@synthesize failedToInitialize;
@synthesize delay;
@synthesize filename, size;

- (id)init
{
  self = [super init];
  [self initVars];
  return self;
}

- (void)initVars
{
  didTakePhoto = NO;
  delay = 1;
  NSError * error = nil;

  // Get default input device and open it
  video = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeVideo];
  BOOL success = [video open:&error];
  
  if (!success || error != nil) {
    NSLog(@"Error Could Not Open Device");
    failedToInitialize = YES;
    return;
  }

  input = [[QTCaptureDeviceInput alloc] initWithDevice:video];
  session = [QTCaptureSession new];
  success = [session addInput:input error:&error];

  if (!success || error != nil) {
    NSLog(@"Error could not add input into session");
    failedToInitialize = YES;
    return;
  }

  output = [QTCaptureDecompressedVideoOutput new];
  [output setDelegate:self];

  success = [session addOutput:output error:&error];
  if (!success || error != nil) {
    NSLog(@"Error session failed to add output");
    failedToInitialize = YES;
    return;
  }
  
  currentImage = nil;
}

- (void)photoTaken:(NSData *)imageData
{
  if([self filename]) {
    NSString * saveFilePath = [[NSString stringWithFormat:@"%@", [self filename]] stringByExpandingTildeInPath];
    [imageData writeToFile:saveFilePath atomically:NO];
  }
}

- (void)begin
{
  [session startRunning];
  
  NSDate * now = [[NSDate alloc] init];
  [[NSRunLoop currentRunLoop] runUntilDate:[now dateByAddingTimeInterval:(double)delay]];
  [now release];
  
  BOOL didTake = NO;
  
  while( didTake == NO ) {
    @synchronized(self) {
      didTake = didTakePhoto;
    }

    if( didTake == NO ) { // Wait until the photo is taken...
      [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow: 0.1]];
    }
  }   // end while
  
 // Stop the session
  [session stopRunning];
}

- (void)captureOutput:(QTCaptureOutput *)captureOutput 
  didOutputVideoFrame:(CVImageBufferRef)videoFrame 
     withSampleBuffer:(QTSampleBuffer *)sampleBuffer 
       fromConnection:(QTCaptureConnection *)connection
{
    // If we already have an image we should use that instead
    if ( currentImage ) return;
    
    // Retain the videoFrame so it won't disappear
    // don't forget to release!
    CVBufferRetain(videoFrame);
    
    // The Apple docs state that this action must be synchronized
    // as this method will be run on another thread
    @synchronized (self) {
        currentImage = videoFrame;
    }
    
    // As stated above, this method will be called on another thread, so
    // we perform the selector that handles the image on the main thread
    [self performSelectorOnMainThread:@selector(saveImage) withObject:nil waitUntilDone:NO];
}

- (NSData *)dataFromImage:(NSImage *)anImage
{
  NSData * tiffData = [anImage TIFFRepresentation];
  NSBitmapImageFileType imageType = NSJPEGFileType;
  NSDictionary * imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:0.9] forKey:NSImageCompressionFactor];
  
  NSBitmapImageRep * imageRep = [NSBitmapImageRep imageRepWithData:tiffData];
  NSData * photoData = [imageRep representationUsingType:imageType properties:imageProps];
  return photoData;
}

- (CIImage *)applyFiltersForImageBuffer:(CVImageBufferRef)imageBufferRef
{
  CIImage * inputImage = [CIImage imageWithCVImageBuffer:imageBufferRef];
  CGRect extent = [inputImage extent];
  CGSize inputImageSize = extent.size;
  
  CGFloat targetAspectRation = [self size].width / [self size].height;
  CGFloat inputAspectRation = inputImageSize.width / inputImageSize.height;
  CGFloat scaleFactor;
  
  if (inputAspectRation > targetAspectRation) {
    scaleFactor = inputImageSize.height / [self size].height;
  } else {
    scaleFactor = inputImageSize.width / [self size].width;
  }

  CIFilter *scaleFilter = [CIFilter filterWithName:@"CILanczosScaleTransform"];
	[scaleFilter setDefaults];
	[scaleFilter setValue:inputImage forKey:@"inputImage"];
  [scaleFilter setValue:[NSNumber numberWithFloat:scaleFactor] forKey:@"inputScale"];

	return [scaleFilter valueForKey:@"outputImage"];
}

   
- (void)saveImage
{
    CIImage * ciImage = [self applyFiltersForImageBuffer:currentImage];
    NSCIImageRep *imageRep = [NSCIImageRep imageRepWithCIImage:ciImage];
  
    NSImage * imageCam = [[NSImage alloc] initWithSize:[imageRep size]];
    [imageCam addRepresentation:imageRep];
    
    NSData * imageData = [self dataFromImage:imageCam];
  
    if ( [self respondsToSelector:@selector(photoTaken:)] ) {
        [self photoTaken:imageData];
    }
    
    // Clean up after us
    [imageCam release];
    CVBufferRelease(currentImage); // release the current from since we retained it above.
    currentImage = nil;
    didTakePhoto = YES; // make sure we know the photo has been taken so we can end the while loop
}


- (void)dealloc
{
  [super dealloc];
  
  // make sure we are not running
  if ([session isRunning]) {
    [session stopRunning];
  }
  // if video cam is open by the current application (which is us) then we should close it
  if ([video isOpen]) {
    [video close];
  }
  
  if(session) [session release];
  if(video) [video release];
  
  if(filename) [filename release];
}

@end
