require 'mkmf'

$CFLAGS  << " -ObjC "
$LDFLAGS << " -lobjc -framework Foundation -framework Cocoa -framework QTKit -framework QuartzCore"

find_header('CapturePhoto.h', '..')

extension_name = "Capture"

dir_config(extension_name)

create_makefile(extension_name)
