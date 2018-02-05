######################################################
# Creates a SAS version 5 XPT file with metadata
#-----------------------------------------------------
# Input: path to file to create
#        name of file to create
#        dataset label
#        metadata as hash ????????????
#-----------------------------------------------------
# Output: Hash map containing
#   - metadata: hash map of metadata (variables and attributes)
#-----------------------------------------------------
# Known limitations:
# - Some header information is static.
# - Some variable metadata is static. (E.g. formats)
######################################################
module Create_xpt_metadata_module
    def create_xpt_metadata(path,filename,ds_label,metadata)
        if filename.chomp(".xpt").length > 8 then
            return "---------- Dataset name longer than 8 characters ---------"
        end
        path = File.join(path,"") # This just makes sure that the path always ends with "/"
        # STDERR.puts "Create "+path+filename

        file = File.new(path+filename,"wb")

        # Create header
        str = "HEADER RECORD*******LIBRARY HEADER RECORD!!!!!!!000000000000000000000000000000"
        file.write(str)

        # Create REAL header info
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
        dt = Time.now.strftime("%d%b%y:%H:%M:%S").upcase
        file.write(dt)
        # STDERR.puts ':'+dt+':'

        # Create second REAL header info (repeat of date)
        # #ddMMMyy:hh:mm:ss+"        "
        file.write(dt)
        file.write(" "*64)

        # Create member (variable) header records
        # #HEADER RECORD*******MEMBER HEADER RECORD!!!!!!!000000000000000001600000000140
        file.write("HEADER RECORD*******MEMBER  HEADER RECORD!!!!!!!000000000000000001600000000140  ")
        # #HEADER RECORD*******DSCRPTR HEADER RECORD!!!!!!!000000000000000000000000000000
        # memDesc = file.read(80)
        file.write("HEADER RECORD*******DSCRPTR HEADER RECORD!!!!!!!000000000000000000000000000000")

        # Create REAL header info
        # #aaaaaaaabbbbbbbbccccccccddddddddeeeeeeee                        ffffffffffffffff
        file.write("  ")  # Don't really now what this is used for
        file.write("SAS     ")  # Static it is SAS generated
        file.write(filename.chomp(".xpt").ljust(8))
        file.write("SASDATA ")  # Static header info
        file.write("9.4     ")  # Static SAS version number
        file.write("X64_8PRO")  # Static OS version
        file.write(" "*24)
        file.write(dt)          # And date again!

        # Create second REAL header info
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
        file.write("HEADER RECORD*******NAMESTR HEADER RECORD!!!!!!!000000")
        # Set number of variables to loop
        nVars = metadata.size
        # STDERR.puts "Debug: nVars="+nVars.to_s
        file.write(nVars.to_s.rjust(4,'0'))

        # blanks = file.read(22). Is acutally 20*"0" and 2*" " 
        file.write("0"*20)
        file.write(" "*2) # Not in read meta

        # Start looping over the variables
        totalRowLength = 0

        nposLength = 0 # Initiate position of first variable in observation
        metadata.each_with_index do |varmeta, index|
                rowLength = 0 # Initate count of  row length.

                # Create type
                rowLength += 2
                if (varmeta.first[:type] == "char") then
                    type = [2].pack("n*")
                else
                    type = [1].pack("n*")
                end
                file.write(type)

                #   Pad
                rowLength += 2
                blank = ["  ".to_i].pack("n*")
                file.write(blank)

                # Length of variable
                rowLength += 2
                varLength = varmeta.first[:length]
                length = [varLength.to_i].pack("n*")
                file.write(length)

                # Add the position of the variable
                rowLength += 2
                varnum = [index+1].pack("n*")
                file.write(varnum)

                # Name
                rowLength += 8
                file.write(varmeta.first[:name].upcase.ljust(8))

                # Label
                rowLength += 40
                file.write(varmeta.first[:label].ljust(40))

                # FormatName  (static)
                rowLength += 8
                formatName = ""
                file.write(formatName.ljust(8))

                # FormatLength  (static)
                rowLength += 2
                formatLength = [0.to_i].pack("n*")
                file.write(formatLength)

                # Decimal format  (static)
                rowLength += 2
                formatDec = [0.to_i].pack("n*")
                file.write(formatDec)

                # Format justification (static)
                rowLength += 2
                formatJust = [0.to_i].pack("n*")
                file.write(formatJust)

                # Pad
                rowLength += 2
                unused = [0.to_i].pack("n*")
                file.write(unused)

                # InFormat  (static)
                rowLength += 8
                inFormat = ""
                file.write(inFormat.ljust(8))

                # Informat length (static)
                rowLength += 2
                inforLength = [0.to_i].pack("n*")
                file.write(inforLength)

                # Informat decimalt (static)
                rowLength += 2
                inforDec = [0.to_i].pack("n*")
                file.write(inforDec)

                # Position of this information
                rowLength += 4
                npos = ["0".to_i,nposLength].pack("n*") #------------- FIX: Hardcoding of "0"
                file.write(npos)

                # Padding up to a length of a record (140, since we are not VAX/VMS)
                rowLength += 52
                padNull = ["0".to_i].pack("n") # 16-bit unsigned
                file.write(padNull*26) # Length of padNull is 2. 26*2 = 52
    #            padNull = ["0".to_i].pack("C") # 8-bit unsigned
    #            file.write(padNull*52) # Length of padNull is 52

                nposLength += varLength # Set position of next variable
                totalRowLength += rowLength # Set current row length for padding after all variables
        end

        # STDERR.puts "Debug: totalRowLength= "+totalRowLength.inspect

        # Calculate padding to make it into 80 bit chunks
        modden = totalRowLength.modulo(80)
        # STDERR.puts "Debug: mod= "+modden.inspect
        padLength = (80-modden)
        # STDERR.puts "Debug: padLength= "+padLength.inspect
        if (padLength != 0 && padLength != 80) then
            padString = " "*padLength 
            # STDERR.puts "Debug: padLength= "+padLength.inspect
            file.write(padString)
        end

        # Write observation header to complete the xpt file
        file.write("HEADER RECORD*******OBS     HEADER RECORD!!!!!!!000000000000000000000000000000  ")
        totalRowLength = 80

        # Pad each variable
        metadata.each do |varmeta|
            if (varmeta.first[:type] == "char") then
                padString = " "*varmeta.first[:length]
                file.write(padString)
            else
                padNull = ["0".to_i].pack("C") # 8-bit unsigned
                padString = "."+padNull*7 # Target 0101110+00000000000000000000000000000000000000000000000000000000
                file.write(padString)
            end
            totalRowLength += varmeta.first[:length] # Set current row length for padding after all variables
        end

        # Pad last time make it a 80 bit chunk
        modden = totalRowLength.modulo(80)
        # STDERR.puts "Debug: mod= "+modden.inspect
        padLength = (80-modden)
        # STDERR.puts "Debug: padLength= "+padLength.inspect
        if (padLength != 0 && padLength != 80) then
            padString = " "*padLength
            file.write(padString)
        end

        return "file created"
    end
end
