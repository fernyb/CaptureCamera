#import <Foundation/Foundation.h>
#import <QTKit/QTKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ruby.h"

NSString * to_nsstring(VALUE string);

VALUE Capture = Qnil;
void Init_Capture();
void method_take_photo();
CGSize size_from_array(VALUE hash);
