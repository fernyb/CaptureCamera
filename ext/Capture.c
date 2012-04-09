#import "Capture.h"
#import "CapturePhoto.h"

NSString * to_nsstring(VALUE string) 
{
  if (string == Qnil) {
    return [NSString string];
  }
  else {
    printf(StringValuePtr(string));
    return [NSString stringWithCString:StringValuePtr(string) encoding:NSASCIIStringEncoding];
  }
}

void Init_Capture() {
  Capture = rb_define_module("Capture");
  rb_define_method(Capture, "take_photo", method_take_photo, 1);
}

CGSize size_from_array(VALUE array) {
  long len = RARRAY_LEN(array);
  int sizeWidth = 0;
  int sizeHeight = 0;
  
  if(len == 2) {
    sizeWidth  = FIX2INT(rb_ary_entry(array, 0));
    sizeHeight = FIX2INT(rb_ary_entry(array, 1));
  } else {
    rb_raise(rb_eArgError, "size wrong number of arguments (%d for 2)", len);
  }
  return CGSizeMake(sizeWidth, sizeHeight); 
}

void method_take_photo(VALUE self, VALUE options)
{
  Check_Type(options, T_HASH);
  VALUE filename  = rb_hash_aref(options, ID2SYM(rb_intern("filename")));
  VALUE size      = rb_hash_aref(options, ID2SYM(rb_intern("size")));  
  
  Check_Type(size, T_ARRAY);
  
  NSAutoreleasePool * pool = [NSAutoreleasePool new];
    CapturePhoto * camera = [[CapturePhoto alloc] init];
    if([camera failedToInitialize]) {
      [camera release];
    } else {
      [camera setFilename:to_nsstring(filename)];
      [camera setSize:size_from_array(size)];
      
      [camera begin];
      [camera release];
    }
  [pool drain];
}