# Basically this will process a bunch of phpinfo files in parallel.
#
# i.e. ruby distrib.rb ../collection_tools/raw_phpinfo_files
#
# A simple script that forks off processing files in a directory
# assuming:
#
# CALL_NAME [file list]
#
# ie. ../script/runner parse.rb file1 file2 file3 file4
#
#
#require 'kernel'
require 'time'


# NOTE: it is calling parse with the RAILS script runner
CALL_NAME= "ruby ../data_model/script/runner parse.rb"

FILES_PER_PROCESS= 100

# directory to check comes from ARGV


def fork_and_call_program( call, args)
  Kernel.fork { 
    p "forked "
    p call.split(/\s\s*/).concat(args)
    _call = call + " "+ args.collect {|x| "\"#{x}\""}.join(" ")
    p _call
    print `#{_call}`
    #  system(call.split(/\s\s*/).concat(args))
  }
end  

if(ARGV.length == 0)
  p "Must specifiy a directory"
  exit
end


_start = Time.now.to_f

to_process = []
c = 0
Dir[ARGV[0] + "*"].each do |fil|
  # skip it, if it's not a file
  p (! File.file?( fil ))
  p File.join(ARGV[0], fil)
  next if (! File.file?(fil ))
  
  if(c < FILES_PER_PROCESS)
    c +=1
    to_process <<  fil
  else
    fork_and_call_program(CALL_NAME, to_process)
    to_process = []
    c = 0
  end
end

if(to_process.length != 0)
  # get the non_even numbers
  fork_and_call_program(CALL_NAME, to_process)
end


# done.
print "Took #{Time.now.to_f - _start} seconds\n"
