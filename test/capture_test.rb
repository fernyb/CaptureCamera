require 'capture_camera'

include Capture

dir = "~/Desktop"
photo_name = "capture_test"

take_photo :filename => "#{dir}/#{photo_name}.jpg", 
           :size     => [640,480]