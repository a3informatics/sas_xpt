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
  attr_accessor :directory, :filename
  include Create_xpt_data_module
  include Create_xpt_metadata_module
  include Read_xpt_data_module
  include Read_xpt_metadata_module
  include Read_xpt_supp_metadata_module

  def initialize(aPath, aDomain)
    @directory = File.join(aPath,"") # This makes sure that the directory always ends with "/"
    @filename = aDomain+".xpt"
    return self
  end

  def read_data
    # Check if directory exist
    if !File.exist?(self.directory) then
      result = createError(-1,"(Xpt read_data) Input directory does not exist")
    # Check if file exist
    elsif !File.exist?(self.directory+self.filename) then
      result = createError(-2,"(Xpt read_data) Input file does not exist")
    # Read file
    else
      result = read_xpt_data(self.directory+self.filename)
    end
    return result
  end

  def read_meta
    # Check if directory exist
    if !File.exist?(self.directory) then
      result = createError(-1,"(Xpt read_meta) Input directory does not exist")

    # Check if file exist
    elsif !File.exist?(self.directory+self.filename) then
      result = createError(-2,"(Xpt read_meta) Input file does not exist")

    # Read file
    else
      result = read_xpt_metadata(self.directory+self.filename)
    end
    return result
  end

  def read_supp_meta
    # Check if directory exist
    if !File.exist?(self.directory) then
      result = createError(-1,"(Xpt read_supp_meta) Input directory does not exist")

    # Check if file exist
    elsif !File.exist?(self.directory+self.filename) then
      result = createError(-2,"(Xpt read_supp_meta) Input file does not exist")

    # Check if it is named as a SUPPxx dataset as well
    elsif self.filename !~ /^supp..\.xpt$/
      result = createError(-3,"(Xpt read_supp_meta) Incorrect naming of SUPP-- file")

    # Read file
    else
      result = read_xpt_supp_metadata(self.directory+self.filename)
    end
    return result
  end

  def create_meta(datasetLabel,metadata)
    # Check if file exist
    STDERR.puts( "Create XPT file with metadata!")
    result = create_xpt_metadata(self.directory,self.filename,datasetLabel,metadata)
    STDERR.puts "==== File is created ===="
    return result
  end

  def create_data(datasetLabel,metadata,realdata)
    STDERR.puts( "Create XPT file with data!" )
    # create_xpt_data(self.directory,self.filename,self.datasetLabel, self.metadata,self.realdata)
    result = create_xpt_data(self.directory,self.filename,datasetLabel,metadata,realdata)
    STDERR.puts "==== File is created ===="
    return result
  end

  def createError(errorNo, errorText)
    result = {}
    result[:status] = errorNo
    result[:error] = errorText
    return result
  end
end
