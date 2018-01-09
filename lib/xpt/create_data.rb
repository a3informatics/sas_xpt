######################################################
# Creates a SAS version 5 XPT file
#-----------------------------------------------------
# Input: path to file
#        filename
#        dataset label
#        variabel metadata in a list []
#        data in a list []
#-----------------------------------------------------
# Output: SAS version 5 XPT file
#-----------------------------------------------------
# Known limitations:
# - Numeric missing values
#   E.g. ""
# - No error handling of input metadata
#   E.g. If characters are too long to fit metadata
# - Largest numeric value allowed = 4'503'599'627'370'495
######################################################
module Create_xpt_data_module
    def create_xpt_data(path,filename,ds_label,metadata,rows)
        path = File.join(path,"") # This just makes sure that the path always ends with "/"
        # STDERR.puts "Create "+path+filename
        file = File.new(path+filename+".xpt","wb")

        # Write first header
    #    firstHeader = file.read(80)
        str = "HEADER RECORD*******LIBRARY HEADER RECORD!!!!!!!000000000000000000000000000000"
        file.write(str)

        # Write REAL header info
        # #aaaaaaaabbbbbbbbccccccccddddddddeeeeeeee                        ffffffffffffffff
        # sasSymbol = []
        file.write("  ") # Don't really now what this is used for
        file.write("SAS     ")
        # sasSymbol[1] = file.read(8)
        file.write("SAS     ")
        # sasLib = file.read(8)
        file.write("SASLIB  ")
        # sasVer = file.read(8)
        file.write("9.4     ")
        # sasOs = file.read(8)
        file.write("X64_8PRO")
        # blanks = file.read(24)
        file.write(" "*24)
        # creationTime = file.read(16)
    #    dt = Time.now.to_s
        dt = Time.now.strftime("%d%b%y:%H:%M:%S")
        file.write(dt)

        # Write second REAL header info
        # #ddMMMyy:hh:mm:ss+"        "
        # modifiedTime = file.read(16)
        # blanks = file.read(64)
        file.write(dt)
        file.write(" "*64)

        # Write Member header records
        # #HEADER RECORD*******MEMBER HEADER RECORD!!!!!!!000000000000000001600000000140
        file.write("HEADER RECORD*******MEMBER  HEADER RECORD!!!!!!!000000000000000001600000000140  ")
        # #HEADER RECORD*******DSCRPTR HEADER RECORD!!!!!!!000000000000000000000000000000
        # memDesc = file.read(80)
        file.write("HEADER RECORD*******DSCRPTR HEADER RECORD!!!!!!!000000000000000000000000000000")

        # #Read REAL header info
        # #aaaaaaaabbbbbbbbccccccccddddddddeeeeeeee                        ffffffffffffffff
        # sasSymbol = file.read(8)
        file.write("  ")  # Don't really now what this is used for
        file.write("SAS     ")
        # dsname = file.read(8)
        file.write(filename.ljust(8))
        # sasdata = file.read(8)
        file.write("SASDATA ")
        # sasVer = file.read(8)
        file.write("9.4     ")
        # sasOs = file.read(8)
        file.write("X64_8PRO")
        # blanks = file.read(24)
        file.write(" "*24)
        # creationTime = file.read(16)
        file.write(dt)

        # #Read second REAL header info
        # #ddMMMyy:hh:mm:ss+"        "
        # modifiedTime = file.read(16)
        file.write(dt)
        # blanks = file.read(16)
        file.write(" ".ljust(16))
        # dslabel = file.read(40)
        file.write(ds_label.ljust(40)) # .upcase
        # dstype = file.read(8)
        file.write(" "*8)

        # #Namestr header
        # #HEADER RECORD*******NAMESTR HEADER RECORD!!!!!!!000000xxxx00000000000000000000
        # nameHeader = file.read(54)
        file.write("HEADER RECORD*******NAMESTR HEADER RECORD!!!!!!!000000")
        # nVars = file.read(4)
        nVars = metadata.size
        file.write(nVars.to_s.rjust(4,'0'))

        totalRowLength = 0

        # blanks = file.read(22). Is acutally 20*"0" and 2*" " 
        file.write("0"*20)
        file.write(" "*2) # Not in read meta

        nposLength = 0 # Initiate position of first variable in observation
        metadata.each_with_index do |varmeta, index|
                rowLength = 0 # Initate count of  row length.

                #     type         = file.read(shortByte).unpack("n")[0]
                rowLength += 2
                if (varmeta.first[:type] == "char") then
                    type = [2].pack("n*")
                else
                    type = [1].pack("n*")
                end
                file.write(type)
                #     blank        = file.read(shortByte).unpack("n")[0]
                rowLength += 2
                blank = ["  ".to_i].pack("n*")
                file.write(blank)

                #     length       = file.read(shortByte).unpack("n")[0]
                rowLength += 2
                varLength = varmeta.first[:length]
                length = [varLength.to_i].pack("n*")
                file.write(length)

                # varnum       = file.read(shortByte).unpack("n")[0]
                rowLength += 2
                varnum = [index+1].pack("n*")
                file.write(varnum)

                # name         = file.read(8)
                rowLength += 8
                file.write(varmeta.first[:name].upcase.ljust(8))

                # label        = file.read(40)
                rowLength += 40
                file.write(varmeta.first[:label].ljust(40))

                # formatName   = file.read(8)
                rowLength += 8
    #            file.write("Fmt".ljust(8))
                formatName = ""
                file.write(formatName.ljust(8))

                # formatLength = file.read(shortByte).unpack("n")[0]
                rowLength += 2
                formatLength = [0.to_i].pack("n*")
                file.write(formatLength)

                # formatDec    = file.read(shortByte).unpack("n")[0]
                rowLength += 2
                formatDec = [0.to_i].pack("n*")
                file.write(formatDec)

                # formatJust   = file.read(shortByte).unpack("n")[0]
                rowLength += 2
                formatJust = [0.to_i].pack("n*")
                file.write(formatJust)

                # unused       = file.read(2)
                rowLength += 2
                unused = [0.to_i].pack("n*")
                file.write(unused)

                # inFormat     = file.read(8)
                rowLength += 8
                inFormat = ""
                file.write(inFormat.ljust(8))

                # inforLength  = file.read(shortByte).unpack("n")[0]
                rowLength += 2
                inforLength = [0.to_i].pack("n*")
                file.write(inforLength)

                # inforDec     = file.read(shortByte).unpack("n")[0]
                rowLength += 2
                inforDec = [0.to_i].pack("n*")
                file.write(inforDec)

                # npos = file.read(4)
                rowLength += 4
                npos = ["0".to_i,nposLength].pack("n*") #------------- FIX: Hardcoding of "0"
                file.write(npos)

                # a=file.read(52)         # This might need adoption for VAX/VMS xpt files
                rowLength += 52
                padNull = ["0".to_i].pack("n") # 16-bit unsigned
                file.write(padNull*26) # Length of padNull is 2. 26*2 = 52
    #            padNull = ["0".to_i].pack("C") # 8-bit unsigned
    #            file.write(padNull*52) # Length of padNull is 52

                nposLength += varLength # Set position of next variable
                totalRowLength += rowLength # Set current row length for padding after all variables
        end

        # STDERR.puts "Debug: totalRowLength: "+totalRowLength.inspect

    #  Not in create_meta
        padBlank = " "

        modden = totalRowLength.modulo(80)
        # STDERR.puts "Debug mod: "+modden.inspect
        padLength = (80-modden)
        # STDERR.puts "Debug padLength: "+padLength.inspect
        if (padLength != 0 && padLength != 80) then
            padString = " "*padLength 
            file.write(padString)
        end

        # STDERR.puts "Debug -------------------Observations -------------------"
        ##################################################
        # Write observation header
        file.write("HEADER RECORD*******OBS     HEADER RECORD!!!!!!!000000000000000000000000000000  ")
        totalRowLength = 80

        # Start counting after headers
        totalRowLength = 0

        # Create missing numeric value
        padNull = ["0".to_i].pack("C") # 8-bit unsigned
        missingNumeric = "."+padNull*7 # Target 0101110+00000000000000000000000000000000000000000000000000000000
        # Create zero numeric value
        padNull = ["0".to_i].pack("C") # 8-bit unsigned
        zeroValue = padNull*0 # Target 0000000+00000000000000000000000000000000000000000000000000000000


        theVariables = metadata.collect {|it| it[0][:name] }
        varLengths   = metadata.collect {|it| it[0][:length] }
        varTypes     = metadata.collect {|it| it[0][:type] }
        rows.each do |row|
            row.each_with_index do |value, index |
                # STDERR.puts "Debug metadata "+index.to_s+":"+varLengths[index].inspect
                totalRowLength += varLengths[index] # Set current row length for padding after all variables
                # STDERR.print "Debug: value= "
                # STDERR.puts value.inspect
                if (varTypes[index] == "num") then
    #                if (value) then
                    # STDERR.print "value is: "+value.to_s
                    binValue = [value].pack("E").unpack("Q>")
                    # STDERR.print "  binValue: "+binValue.inspect
                    if (value == 0) then
                        file.write(zeroValue)
                        # STDERR.print " ------ writing a zero\n"
                    elsif (value) then
                        ################ Put real value
                        isValue = "1" # Real data = 1, missing value = 0
                        # Set sign +/-
                        if value < 0 then
                            theSign = theSign = "1"
                            value=value*-1
                        else
                            theSign = "0"
                        end
                        if value < 16 then
                          exponent = "1000001"
                          integerLength = 4
                          theIntBin = ("%04b" % value)
                        elsif value < 256 
                          exponent = "1000010"
                          integerLength = 8
                          theIntBin = ("%08b" % value)
                        elsif value < 4096 
                          exponent = "1000011"
                          integerLength = 12
                          theIntBin = ("%012b" % value)
                        elsif value < 65536 
                          exponent = "1000100"
                          integerLength = 16
                          theIntBin = ("%016b" % value)
                        elsif value < 1048576
                          exponent = "1000101"
                          integerLength = 20
                          theIntBin = ("%020b" % value)
                        elsif value < 16777216
                          exponent = "1000110"
                          integerLength = 24
                          theIntBin = ("%024b" % value)
                        elsif value < 268435456
                          exponent = "1000111"
                          integerLength = 28
                          theIntBin = ("%028b" % value)
                        elsif value < 4294967296
                          exponent = "1001000"
                          integerLength = 32
                          theIntBin = ("%032b" % value)
                        elsif value < 68719476736
                          exponent = "1001001"
                          integerLength = 36
                          theIntBin = ("%036b" % value)
                        elsif value < 1099511627776
                          exponent = "1001010"
                          integerLength = 40
                          theIntBin = ("%040b" % value)
                        elsif value < 17592186044416
                          exponent = "1001011"
                          integerLength = 44
                          theIntBin = ("%044b" % value)
                        elsif value < 281474976710656
                          exponent = "1001100"
                          integerLength = 48
                          theIntBin = ("%048b" % value)
                        elsif value < 4503599627370496
                          exponent = "1001100"
                          integerLength = 52
                          theIntBin = ("%052b" % value)
                        else
                          STDERR.puts("Info: Too large number: "+value.to_s)
                          return "Warning: Too large number in input data: "+value.to_s
                          exponent = "TOOLARGE"
                          integerLength = 53
                          theIntBin = "TOOLARGE"
                        end

                        # Does the value have decimals? Add float part
                        if (value != value.to_i) then
                            theFloatPart = ((value)-value.to_i)
                            tmpFloat = theFloatPart
                            reminder = 0
                            theFloatBin = ""
                            1.upto(56-integerLength) do |i|
                                reminder = (tmpFloat * 2)
                                theFloatBin = theFloatBin + reminder.to_i.to_s
                                tmpFloat = ((reminder)-reminder.to_i)
                            end
                        else # If it doesn't, pad with 0
                            theFloatBin = "0"*(56-integerLength)
                        end
                        # Build the whole binary string
                        theBin = theSign+exponent+theIntBin+theFloatBin
                        # Convert each byte (8 digits) to hex
                        theBin.scan(/.{8}/).each do |it|
                            theBinHex = [it.to_i(2)].pack("C")
                            file.write(theBinHex)
                        end
                    else
                        # Put a null value
                        file.write(missingNumeric)
                        STDERR.puts "Info: Writing a missing numeric"
                    end
                else
                    file.write(value.ljust(varLengths[index]))
                end
            end
        end

        # Pad to 80 bytes
        modden = totalRowLength.modulo(80)
        # STDERR.puts "Debug: mod= "+modden.inspect
        padLength = (80-modden)
        # STDERR.puts "Debug: padLength= "+padLength.inspect
        if (padLength != 0) then
            padString = padBlank*padLength
            # STDERR.puts "Debug: pad= "+padString.length.inspect
            file.write(padString)
        end
        return "file created"
    end
end
