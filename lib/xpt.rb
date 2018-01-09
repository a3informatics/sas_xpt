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
require "./xpt/read_data"
require "./xpt/read_meta"
require "./xpt/read_supp_meta"
require "./xpt/create_data"
require "./xpt/create_meta"

class Xpt
  attr_accessor :directory, :file
  include Create_xpt_data_module
  include Create_xpt_metadata_module
  include Read_xpt_data_module
  include Read_xpt_metadata_module
  include Read_xpt_supp_metadata_module

  def initialize(aName, aFile)
    @directory = aName
    @file = aFile
    return self
  end

  def read_data
    # Check if file exist
    inputFile = self.directory+"/"+self.file
    if File.exist?( inputFile ) then
      STDERR.puts( "Reading metadata from: "+inputFile )
      result = read_xpt_data(inputFile)
      STDERR.puts "==== File is read ===="
      return result
    else
      STDERR.puts( "Can't find file! "+inputFile )
      return -1
    end
  end

  def read_meta
    # Check if file exist
    inputFile = self.directory+"/"+self.file
    if File.exist?( inputFile ) then
      STDERR.puts( "Reading metadata from: "+inputFile )
    else
      STDERR.puts( "Eeek! Can't find file! "+inputFile )
    end

    result = read_xpt_metadata(inputFile)

    STDERR.puts "==== File is read ===="
    return result
  end

  def read_supp_meta
    # Check if file exist
    inputFile = self.directory+"/"+self.file
    if !File.exist?( inputFile ) then
      STDERR.puts( "Eeek! Can't find file! "+inputFile )
      return "(read_supp_meta) Error: File does not exist: "+inputFile
    end
    # Check if it is a SUPP dataset as well
    if !inputFile.include? "supp" then
      STDERR.puts "This is NOT a supp file. Exiting"
      return "(read_supp_meta) Error: This is not a supplemental qualifier dataset (SUPP--): "+inputFile
    end

    result = read_xpt_supp_metadata(inputFile)

    STDERR.puts "==== File is read ===="
    return result
  end


  def create_meta(datasetLabel,metadata)
    # Check if file exist
    STDERR.puts( "Create XPT file with metadata!")
    result = create_xpt_metadata(self.directory,self.file,datasetLabel,metadata)
    STDERR.puts "==== File is created ===="
    return result
  end

  def create_data(datasetLabel,metadata,realdata)
    STDERR.puts( "Create XPT file with data!" )
    # create_xpt_data(self.directory,self.file,self.datasetLabel, self.metadata,self.realdata)
    result = create_xpt_data(self.directory,self.file,datasetLabel,metadata,realdata)
    STDERR.puts "==== File is created ===="
    return result
  end
end



###################################################
# Test for reading data
###################################################
inputDirectory="./test_xpt_files/"
theDomain="dm"
xpt = Xpt.new(inputDirectory,theDomain+".xpt")
xpt_data = xpt.read_data

outputDirectory="./output/"
outputFileName = outputDirectory+theDomain+"_xpt_data.tsv"
outputFile = File.new(outputFileName,"w")

xpt_data[:variables].each do |item|
    item.each do |map|
        outputFile.write map[:name].to_s+"\t"
    end
end

outputFile.write "\n"

xpt_data[:data].each do |list|
    list.each do |map|
        map.each do |k, v|
            outputFile.write v.to_s+"\t"
        end
        outputFile.write "\n"
    end
end

puts "Test data created: "+outputFileName


###################################################
# Test for reading metadata only
###################################################
inputDirectory="./test_xpt_files/"
theDomain="dm"
xpt = Xpt.new(inputDirectory,theDomain+".xpt")
xpt_meta = xpt.read_meta

outputDirectory="./output/"
outputFileName = outputDirectory+theDomain+"_xpt_meta.tsv"
outputFile = File.new(outputFileName,"w")
xpt_meta[:variables].each do |item|
    item.each do |map|
        outputFile.write map[:name].to_s+"\t"
    end
end
outputFile.write "\n"

puts "created test output in file:"+outputFileName

###################################################
# Test for reading supp metadata only
###################################################
inputDirectory="./test_xpt_files/"
theDomain="dm"
theDomain="suppdm"
xpt = Xpt.new(inputDirectory,theDomain+".xpt")
xpt_supp_meta = xpt.read_supp_meta

if (xpt_supp_meta.instance_of? Hash) then
  outputDirectory="./output/"
  outputFileName = outputDirectory+theDomain+"_xpt_supp_meta.tsv"
  outputFile = File.new(outputFileName,"w")
  xpt_supp_meta[:variables].each do |item|
      outputFile.write item[:name]
      # item.each do |map|
      #     outputFile.write map[:name].to_s+"\t"
      # end
  end
  outputFile.write "\n"

  puts "created test output in file:"+outputFileName
end


###################################################
# Test for creating metadata only
###################################################
puts "Creating metadata only"
metadata = [[name:"c1",label:"label c1",type:"char",length:11],
            [name:"n1",label:"label n1",type:"num",length:8]
]

outputDirectory="./output"
filename="testmeta"
puts "Set output directory and filename: "+outputDirectory+"-"+filename

xpt = Xpt.new(outputDirectory,filename)

cres = xpt.create_meta("dataset label",metadata)

puts "Created file: "+outputDirectory+" - "+filename+".xpt"
puts "cres="+cres.to_s


###################################################
# Test for creating real data
###################################################
puts "Creating data"
metadata = [[name:"c1",label:"lc 1",type:"char",length:11],
            [name:"n1",label:"ln 1",type:"num",length:8]
]
rows = [
        ["xpt.rb!",1.1],
        ["A file",1.1],
        ["A file",4503599627370495]
    ]

outputDirectory="./output"
filename="testdata"
puts "Set output directory and filename: "+outputDirectory+"-"+filename

xpt = Xpt.new(outputDirectory,filename)
cres = xpt.create_data("dataset label",metadata,rows)

puts "Created file: "+outputDirectory+" - "+filename+".xpt"
puts "cres="+cres.to_s
