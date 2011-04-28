#!/usr/bin/env ruby

help_no_command = <<END
Perform the given command. Available commands are:
clean, install
END

if ARGV.empty? 
	print help_no_command
end

ARGV.each do|a|
  case ARGV[0] #Command
  when "clean"
  	puts "Cleaning installation\n"
  	`rm -f *.jpg *.gif *.tiff`
  when install
  	puts "Creating directories"
  	`mkdir -p data`
  end
end


