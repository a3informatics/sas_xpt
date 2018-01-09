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
require "./xpt/read_meta_supp"
require "./xpt/create_data"
require "./xpt/create_meta"

class Xpt
  attr_accessor :directory, :file
  include Create_xpt_data_module
  include Create_xpt_metadata_module
  include Read_xpt_data_module
  include Read_xpt_metadata_module
  include Read_xpt_metadata_supp_module

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

    result = read_xpt_metadata_supp(inputFile)

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

