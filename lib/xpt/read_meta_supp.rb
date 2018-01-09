######################################################
# Reads metadata from a SAS version 5 XPT file
#-----------------------------------------------------
# Input: name of file (including the path)
#-----------------------------------------------------
# Output: Hash map containing
#   - metadata: hash map of metadata (variables and attributes)
#-----------------------------------------------------
# Known limitations:
# - Does not handle VAX/VMS created files
######################################################
module Read_xpt_metadata_supp_module
    def read_xpt_metadata_supp(inputFile)
        file = File.new(inputFile,"r")

        # Read first header             #HEADER RECORD*******LIBRARY HEADER RECORD!!!!!!!000000000000000000000000000000
        firstHeader = file.read(80)

        #Read REAL header info          #aaaaaaaabbbbbbbbccccccccddddddddeeeeeeee                        ffffffffffffffff
        sasSymbol = []
        sasSymbol[0] = file.read(8)
        sasSymbol[1] = file.read(8)
        sasLib = file.read(8)
        sasVer = file.read(8)
        sasOs = file.read(8)
        blanks = file.read(24)
        creationTime = file.read(16)

        #Read second REAL header info   #ddMMMyy:hh:mm:ss+"        "
        modifiedTime = file.read(16)
        blanks = file.read(64)

        # Read Member header records    #HEADER RECORD*******MEMBER HEADER RECORD!!!!!!!000000000000000001600000000140
        memHeader = file.read(74)
        varLength = file.read(4)
        blanks = file.read(2)
        #Read DSCRPTR header            #HEADER RECORD*******DSCRPTR HEADER RECORD!!!!!!!000000000000000000000000000000
        memDesc = file.read(80)

        #Read REAL header info          #aaaaaaaabbbbbbbbccccccccddddddddeeeeeeee                        ffffffffffffffff
        sasSymbol = file.read(8)
        dsname = file.read(8)
        sasdata = file.read(8)
        sasVer = file.read(8)
        sasOs = file.read(8)
        blanks = file.read(24)
        creationTime = file.read(16)

        #Read second REAL header info   #ddMMMyy:hh:mm:ss+"        "
        modifiedTime = file.read(16)
        blanks = file.read(16)
        dslabel = file.read(40)
        dstype = file.read(8)

        #Namestr header                #HEADER RECORD*******NAMESTR HEADER RECORD!!!!!!!000000xxxx00000000000000000000
        nameHeader = file.read(54)
        nVars = file.read(4)
        # STDERR.puts "Debug: nVars="+nVars
        blanks = file.read(22)

        # Get number of variables in the dataset
        numberOfVariables = nVars.sub!(/^0+/,"").to_i

        # STDERR.puts "Debug: numberOfVariables="+numberOfVariables.to_s+"   (class:"+numberOfVariables.class.to_s+")"

        #Namestr record
        totalLength = 0
        shortByte = 2
        #for i in 1..numberOfVariables
        #variables = {}
        variables = []
        for i in 1..numberOfVariables
          template = Hash.new
          type         = "not set"
          length       = -99
          varnum       = -99
          name         = "not set"
          label        = "not set"
          formatName   = "not set"  
          formatLength = "not set"  
          formatDec    = "not set"  
          formatJust   = "not set"  
          informat     = "not set"  
          inforLength  = "not set"  
          inforDec     = "not set"  
          format       = "not set"  

          type         = file.read(shortByte).unpack("n")[0]
          blank        = file.read(shortByte).unpack("n")[0]
          length       = file.read(shortByte).unpack("n")[0]
          varnum       = file.read(shortByte).unpack("n")[0]
          name         = file.read(8)
          label        = file.read(40)
          formatName   = file.read(8)
          formatLength = file.read(shortByte).unpack("n")[0]
          formatDec    = file.read(shortByte).unpack("n")[0]
          formatJust   = file.read(shortByte).unpack("n")[0]
          unused       = file.read(2)
          inFormat     = file.read(8)
          inforLength  = file.read(shortByte).unpack("n")[0]
          inforDec     = file.read(shortByte).unpack("n")[0]
          npos         = file.read(4)
          a=file.read(52)         # This might need adoption for VAX/VMS xpt files

          template[:type] = type
          template[:length] = length
          template[:varnum] = varnum
          template[:name] = name.strip
          template[:label] = label.strip
          template[:formatName] = formatName.strip
          template[:formatLength] = formatLength
          template[:formatDec] = formatDec
          template[:formatJust] = formatJust
          template[:informat] = informat.strip
          template[:inforLength] = inforLength
          template[:inforDec] = inforDec
          template[:format] = format.strip

          variables << template

          totalLength = totalLength + 140
        end

        modden = totalLength.modulo(80)
        paddedLength = (80-modden)

        blank = file.read(modden)

        # header start
        blank = file.read(80)

        # Save variable lenghts to loop over them
        variableLengths = variables.collect {|it| it[:length] }

        # Check how long each record will be
        sizeToRead = 0
        variableLengths.each do |length|
          sizeToRead += length
        end
        # STDERR.puts "Debug: sizeToRead= "+sizeToRead.to_s

        i = 0
        suppVars = {}
        theQnam = "not set"
        firstChar = file.read(1)
        rdomain = nil
        theDomain = nil

        # Read until EOF or it is a special character 
        until (file.eof? || firstChar.bytes[0] < 33)

          # Read first variable as we need to append the first character read in the end
          preStuff = file.read(variables[0][:length]-1).strip
          stuff = firstChar+preStuff

          # Read the rest of the variables
          variables[1..-1].each do |variable|
            stuff = file.read(variable[:length]).strip
            if (variable[:name] == "QNAM") then
              theQnam = stuff.strip
            elsif (variable[:name] == "QLABEL") then
              suppVars[theQnam] = stuff.strip
            elsif (rdomain == nil) # If there is more than one supp domain, this might need adjusting
              if (variable[:name] == "RDOMAIN") then
                theDomain = stuff.strip
              end
            end
          end
          i += 1
          firstChar = file.read(1)
        end

        # Continue to read until end of file
        readSoFar = 0
        i = 0
        until file.eof?
          i += 1
          stuff = file.read(1)
          readSoFar += 1
        end
        STDERR.puts "(Read_meta_supp) Info: read characters until eof="+readSoFar.to_s

        # puts suppVars
        results = {}
        results[:variables] = suppVars.collect {|key, value| {name:key,label:value} }

        results[:domain] = [theDomain]

        results[:status] = ["ok"]

        # File metadata read. Rest of file is data.
        return results
    end
end
