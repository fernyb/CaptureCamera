#import "CaptureTest.h"
#import "CapturePhoto.h"

int main() {
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
  
  CapturePhoto * camera = [[CapturePhoto alloc] init];
  [camera setFilename:@"~/Desktop/screen.jpg"];
  [camera setSize:CGSizeMake(640,480)];
  
  [camera begin];
  [camera release];
  
  [pool drain];
  return 0;
}