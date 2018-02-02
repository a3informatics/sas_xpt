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
require "xpt/read_supp_meta"
require "xpt/create_data"
require "xpt/create_meta"

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
      # STDERR.puts( "Reading data from: "+inputFile )
      result = read_xpt_data(inputFile)
      # STDERR.puts "==== File is read ===="
      return result
    else
      # STDERR.puts( "Can't find file! "+inputFile )
      return -1
    end
  end

  def read_meta
    # Check if file exist
    inputFile = self.directory+"/"+self.file
    if File.exist?( inputFile ) then
      # STDERR.puts( "Reading metadata from: "+inputFile )
      result = read_xpt_metadata(inputFile)
      return result
    else
      # STDERR.puts( "Eeek! Can't find file! "+inputFile )
      return -1
    end
  end

  def read_supp_meta
    # Check if file exist
    inputFile = self.directory+"/"+self.file
    if !File.exist?( inputFile ) then
      # return "(read_supp_meta) Error: File does not exist: "+inputFile
      result = {}
      result[:status] = -1
      result[:error] = "Input directory/file does not exist"
      return result
    end
    # Check if it is named as a SUPP dataset as well
    if (self.file =~ /supp..\.xpt/) then
      result = read_xpt_supp_metadata(inputFile)
      return result
    else
      # return "(read_supp_meta) Error: This is not a supplemental qualifier dataset (SUPP--): "+inputFile
      result = {}
      result[:status] = -2
      result[:error] = "Incorrect naming of file"
      return result
    end
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
