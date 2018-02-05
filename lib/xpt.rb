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

  def initialize(aPath, aFilename)
    @directory = File.join(aPath,"") # This makes sure that the directory always ends with "/"
    @filename = aFilename
    return self
  end

  def read_data
    # Check if file exist
    inputFile = self.directory+self.filename
    if File.exist?( inputFile ) then
      result = read_xpt_data(inputFile)
    else
      result = createError(-1,"(read data) Input directory/file does not exist")
    end
    return result
  end

  def read_meta
    # Check if file exist
    inputFile = self.directory+self.filename
    if File.exist?( inputFile ) then
      result = read_xpt_metadata(inputFile)
    else
      result = createError(-1,"(read_meta) Input directory/file does not exist")
    end
    return result
  end

  def read_supp_meta
    inputFile = self.directory+self.filename
    # Check if file exist
    if !File.exist?(inputFile) then
      result = createError(-1,"(Read_supp_meta) Input directory/file does not exist")

    # Check if it is named as a SUPPxx dataset as well
    elsif (self.filename =~ /supp..\.xpt/) then
      result = read_xpt_supp_metadata(inputFile)

    # Check if it is named as a SUPPxx dataset as well
    else
      result = createError(-2,"(Read_supp_meta) Incorrect naming of file")
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

inputDirectory="../spec/support/xpt_files"
theDomain="suppae"
xpt = Xpt.new(inputDirectory,theDomain+".xpt")
xpt_supp_meta = xpt.read_supp_meta

p xpt_supp_meta
