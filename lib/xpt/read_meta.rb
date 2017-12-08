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
def read_xpt_metadata(inputFile)
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
    results[:variables] = []
    results[:variables] << variables

    results[:debug] = []

    results[:debug] << {rowLength:rowLength}
    results[:debug] << {totalLength:totalLength}

    # File metadata read. Rest of file is data.
    return results
end
