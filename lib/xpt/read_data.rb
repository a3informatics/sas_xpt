######################################################
# Reads a SAS version 5 XPT file
#-----------------------------------------------------
# Input: name of file (including the path)
#-----------------------------------------------------
# Output: Hash map containing
#   - metadata: hash map of metadata (variables and attributes)
#   - data: hash map of data (variables and data)
#-----------------------------------------------------
# Known limitations:
# - Does not read more than 40000 records (lastRecordToRead = 40000)
# - Ignores coded numeric missing values (e.g. ".A" -> ".Z")
#   They will all be set to missing "."
# - No error handling
######################################################
module Read_xpt_data_module
    def read_xpt_data(inputFile)
    #   puts "Reading "+inputFile
        file = File.new(inputFile,"r")

        # Read first header
        #HEADER RECORD*******LIBRARY HEADER RECORD!!!!!!!000000000000000000000000000000 
        firstHeader = file.read(80)

        #Read REAL header info
        #aaaaaaaabbbbbbbbccccccccddddddddeeeeeeee                        ffffffffffffffff
        sasSymbol = []
        sasSymbol[0] = file.read(8)
        sasSymbol[1] = file.read(8)
        sasLib = file.read(8)
        sasVer = file.read(8)
        sasOs = file.read(8)
        blanks = file.read(24)
        creationTime = file.read(16)

        #Read second REAL header info
        #ddMMMyy:hh:mm:ss+"        "
        modifiedTime = file.read(16)
        blanks = file.read(64)

        # Read Member header records
        #HEADER RECORD*******MEMBER HEADER RECORD!!!!!!!000000000000000001600000000140
        memHeader = file.read(74)
        varLength = file.read(4)
        blanks = file.read(2)
        #HEADER RECORD*******DSCRPTR HEADER RECORD!!!!!!!000000000000000000000000000000
        memDesc = file.read(80)

        #Read REAL header info
        #aaaaaaaabbbbbbbbccccccccddddddddeeeeeeee                        ffffffffffffffff
        sasSymbol = file.read(8)
        dsname = file.read(8)
        sasdata = file.read(8)
        sasVer = file.read(8)
        sasOs = file.read(8)
        blanks = file.read(24)
        creationTime = file.read(16)

        #Read second REAL header info
        #ddMMMyy:hh:mm:ss+"        "
        modifiedTime = file.read(16)
        blanks = file.read(16)
        dslabel = file.read(40)
        dstype = file.read(8)

        #Namestr header
        #HEADER RECORD*******NAMESTR HEADER RECORD!!!!!!!000000xxxx00000000000000000000
        nameHeader = file.read(54)
        nVars = file.read(4)
        blanks = file.read(22)


        if (nVars[0] != "0")
            numberOfVariables = nVars.to_i
        elsif (nVars[1] != "0")
            numberOfVariables = nVars[1..3].to_i
        elsif (nVars[2] != "0")
            numberOfVariables = nVars[2..3].to_i
        else
            numberOfVariables = nVars[3].to_i
        end

        #Namestr record
        totalLength = 0
        rowLength = 0
        shortByte = 2
        variables = []
        for i in 1..numberOfVariables
            rowLength = 0
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
            rowLength += 2
            blank        = file.read(shortByte).unpack("n")[0]
            rowLength += 2
            length       = file.read(shortByte).unpack("n")[0]
            rowLength += 2
            varnum       = file.read(shortByte).unpack("n")[0]
            rowLength += 2
            name         = file.read(8)
            rowLength += 8
            label        = file.read(40)
            rowLength += 40
            formatName   = file.read(8)
            rowLength += 8
            formatLength = file.read(shortByte).unpack("n")[0]
            rowLength += 2
            formatDec    = file.read(shortByte).unpack("n")[0]
            rowLength += 2
            formatJust   = file.read(shortByte).unpack("n")[0]
            rowLength += 2
            unused       = file.read(2)
            rowLength += 2
            inFormat     = file.read(8)
            rowLength += 8
            inforLength  = file.read(shortByte).unpack("n")[0]
            rowLength += 2
            inforDec     = file.read(shortByte).unpack("n")[0]
            rowLength += 2
            npos         = file.read(4)
            rowLength += 4
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

            # Add variable to template
            variables << template

            totalLength = totalLength + 140
        end

        results = {}
        results[:variables] = variables

        results[:metadata] = []

        results[:metadata] << variables[1]
        results[:metadata] << rowLength
        results[:metadata] << totalLength
        modden = totalLength.modulo(80)
        results[:metadata] << totalLength.modulo(80)
        paddedLength = (80-modden)

        # Read padding until next header record
        # Read header record
        blank = file.read(paddedLength)

        # Read header record, unless it was already read in the last statement (i.e. modden == 0)
        if (modden != 0) then
            blank = file.read(80)
        end

        # Read data until end of file
        # Including a maximum number of records to read
        lastRecordToRead = 100000
        rowNumber = 1
        data = []
        # Need to read first character, to be able to stop the loop.
        firstChar = file.read(1)
        firstVar = true

    #   CHANGE HERE!!!!  Make if statement for firstchar (as it is only used once) then rewind the file
    #    until (file.eof? || firstChar.bytes[0] < 33 || rowNumber > lastRecordToRead)
        until (file.eof? || (firstChar.bytes[0] > 0 && firstChar.bytes[0] < 33) || rowNumber > lastRecordToRead)
            template = {}
            variables.each do |variable|
                #------ Read strings
                if (variable[:type] == 2) then
                    if (firstVar) then
                        preStuff = file.read(variables[0][:length]-1) # .strip
                        theValue = firstChar+preStuff
                        firstVar = false
                    else
                        theValue = file.read(variable[:length]) # .strip shouldn't be used
                    end
                #------ Read float
                else
                    if (firstVar) then
                        theChar = firstChar.unpack("B*")[0]
                        firstVar = false
                    else
                        theChar = file.read(1).unpack("B*")[0]
                    end
                    if (theChar[0]=="0") then
                        sign = 1 # "+"
                        signChar = "+"
                    else
                        sign = -1 # "-"
                        signChar = "-"
                    end
                    exponent = theChar[1..7]
                    floatbits = ""
                    floatbits = file.read(variable[:length]-1).unpack("B*")[0]

                    # Is it a real value and not a missing value?
                    if (floatbits != "00000000000000000000000000000000000000000000000000000000") then # Real data
                        if (exponent == "1000001") then
                            integerLength = 4
                        elsif (exponent == "1000010") then
                            integerLength = 8
                        elsif (exponent == "1000011") then
                            integerLength = 12
                        elsif (exponent == "1000100") then
                            integerLength = 16
                        elsif (exponent == "1000101") then
                          integerLength = 20
                        elsif (exponent == "1000110") then
                          integerLength = 24
                        elsif (exponent == "1000111") then
                          integerLength = 28
                        elsif (exponent == "1001000") then
                          integerLength = 32
                        elsif (exponent == "1001001") then
                          integerLength = 36
                        elsif (exponent == "1001010") then
                          integerLength = 40
                        elsif (exponent == "1001011") then
                          integerLength = 44
                        elsif (exponent == "1001100") then
                          integerLength = 48
                        elsif (exponent == "1001100") then
                          integerLength = 52
                        else
                            # Known issue: No test data available for large integers. The above should work.
                            integerLength = -1
                        end
                        if (integerLength != -1) then
                            theIntegerBinary = floatbits[0..integerLength-1]
                            theDecimalBinary = floatbits[integerLength..-1]
                            theValue = ((floatbits.to_i(2) * (1.0/(1 << theDecimalBinary.length)))*sign)
                        else
                            theValue = "Unknown floating point"
                        end

                    else # Missing value or zero
                        # Exponent all zeros -> zero
                        if exponent == "0000000" then
                            theValue = 0
                        else
                            # Just assign as a missing float
                            theValue = "."
                        end
                        # Could include error checking. But for now, just skip.
                        # Check that it is only 0 in the floating part for missing values
                        # if (floatbits.include? "1") then
                        #     STDERR.puts "Read missing value error: "+signChar+exponent+"-"+floatbits
                        # else
                        #     STDERR.puts " missing: "+signChar+exponent
                        # end
                    end
                end
                template[variable[:name]] = theValue
            end
            data << template
            rowNumber += 1
            firstChar = file.read(1)
            firstVar = true
        end
        results[:data] = data

        return results
    end
end
