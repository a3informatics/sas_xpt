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
