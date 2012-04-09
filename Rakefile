require "bundler/gem_tasks"


namespace :build do
  desc "Build and Run Capture Test Extention"
  task :capture do
    base_path    = File.expand_path(".", File.dirname(__FILE__))
    frameworks   = %W(Foundation Cocoa QTKit QuartzCore).map {|framework| "-framework #{framework}"}.join(" ")
    include_path = %Q{-I #{base_path}/ext}
    output_file  = "#{base_path}/test/CaptureTest"
    main_file    = "#{base_path}/test/CaptureTest.m #{base_path}/ext/CapturePhoto.m"
    
    system("rm #{output_file}") if File.exists?(output_file)
  
    command = %Q{ gcc -arch x86_64 -ObjC -Wall -Wimplicit-function-declaration -lobjc #{frameworks} #{include_path} -o #{output_file} #{main_file} }
 
    puts command, "\n"
    system(command)
    
    if File.exists?(output_file)
      system("chmod +x #{output_file}")
      puts "Run: #{output_file}"
      puts "-----", "\n"
      system("#{output_file}")
    end
  end
end