######################################################
# Xpt main
#-----------------------------------------------------
# Input: path to file to create
#        name of file to create
#        dataset label
#        metadata as hash
#        data as hash
#-----------------------------------------------------
# Output: See respective method
#-----------------------------------------------------
# Known limitations:
# - Make two xpt classes? Read and Write?
# - Where to check whether a file exists before writing?
######################################################
require "xpt/read_data"
require "xpt/read_meta"
require "xpt/create_data"
require "xpt/create_meta"

class Xpt
  attr_accessor :directory, :file, :datasetLabel, :metadata, :realdata

  def initialize(aName, aFile, dLabel = "empty", mdata = "empty", rdata= "empty")
    @directory = aName
    @file = aFile
    @datasetLabel = dLabel
    @metadata = mdata
    @realdata = rdata
    return self
  end

  def read_data
    # Check if file exist
    inputFile = self.directory+"/"+self.file
    if File.exist?( inputFile ) then
      puts( "Reading metadata from: "+inputFile )
    else
      puts( "Can't find file! "+inputFile )
    end

    result = read_xpt_data(inputFile)

    puts "==== File is read ===="
#    result[:data][0].each do |it|
#      puts it
#    end

    return result
  end

  def read_meta
    # Check if file exist
    inputFile = self.directory+"/"+self.file
    if File.exist?( inputFile ) then
      puts( "Reading metadata from: "+inputFile )
    else
      puts( "Eeek! Can't find file! "+inputFile )
    end

    result = read_xpt_metadata(inputFile)

    puts "==== File is read ===="
    return result
  end

  def create_meta
    # Check if file exist
=begin
    inputFile = self.directory+"/"+self.file
    if File.exist?( inputFile ) then
      puts( "Reading metadata from: "+inputFile )
    else
      puts( "Eeek! Can't find file! "+inputFile )
    end
    puts self.directory
    puts self.file
    puts self.datasetLabel
    puts self.metadata
=end

    puts( "Create XPT file with metadata!")
    result = create_xpt_metadata(self.directory,self.file,self.datasetLabel,self.metadata)

    puts "==== File is created ===="
    return result
  end

  def create_data
    puts( "Create XPT file with data!" )
    create_xpt_data(self.directory,self.file,self.datasetLabel, self.metadata,self.realdata)
    puts "==== File is created ===="
  end


end


exit

puts "Creating data"
metadata = [[name:"c1",label:"lc 1",type:"char",length:11],
            [name:"n1",label:"ln 1",type:"num",length:8]
]
rows = [
        ["Hi Jakub!",1.1],
        ["A file",1.1],
        ["created",-1.1],
        ["within",2.1],
        ["ruby.",-2.1],
        ["It",10.1],
        ["is",-10.1],
        ["now",-100.55],
        ["part",1000.1],
        ["of",10000.1],
        ["the",-100000.1],
        ["xpt",1000000.1],
        ["gem",1234567.12345],
        [":)",-1234567.12345]
    ]

outputDirectory="C:/Users/ju/Dev/Ruby/gems/xptoutput"
filename="testdata"
puts "Set output directory and filename: "+outputDirectory+"-"+filename

c = Xpt.new(outputDirectory,filename,"dataset label",metadata,rows)

cres = c.create_data

puts "Created file: "+outputDirectory+" - "+filename+".xpt"


