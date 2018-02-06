require "spec_helper"

# For some reason this test cannot be within the spec
module BinaryHelper
    def check_content(generated_file, correct_file)
        created_file_content = File.open(generated_file, 'rb') { |f| f.read }
        correct_file_content = File.open(correct_file, 'rb') { |f| f.read }
        startPosition = 0
        stopPosition = 143
        # it 'has the same binary content on position '+startPosition.to_s+"-"+stopPosition.to_s+' before date of creation1' do
            expect(created_file_content[startPosition..stopPosition]).to eq(correct_file_content[startPosition..stopPosition])
        # end
        startPosition = 176
        stopPosition = 463
        # it 'has the same binary content on position '+startPosition.to_s+"-"+stopPosition.to_s+' after date of creation1 and before date of creation2' do
            expect(created_file_content[startPosition..stopPosition]).to eq(correct_file_content[startPosition..stopPosition])
        # end
        startPosition = 496
        stopPosition = -1
        # it 'has the same binary content on position '+startPosition.to_s+'-(end) after date of creation2' do
            expect(created_file_content[startPosition..stopPosition]).to eq(correct_file_content[startPosition..stopPosition])
        # end
    end
end

describe Xpt do
    include BinaryHelper

    context "expect gem to create xpt file with metadata and data ------------------------" do
        it 'as specified' do
        end
    end
    # Reports error on non-existing directory
    context "when setting non-existing directory" do
        outputDirectory="./directoryDoesNotExist"
        theDomain="dm"
        xpt = Xpt.new(outputDirectory,theDomain)

        # Fake data to send
        metadata = []
        rows = []

        it 'sets input directory '+outputDirectory do
            expect(xpt.directory).to eq(outputDirectory+"/")
        end
        it 'sets input filename '+theDomain+".xpt" do
            expect(xpt.filename).to eq(theDomain+".xpt")
        end
        it 'returns error that the directory does not exists' do
            result = xpt.create_data("Dataset label",metadata,rows)
            expect(result[:status]).to eq(-1)
        end
    end

    # Reports error on existing file
    context "when setting existing file" do
        outputDirectory="./spec/support/xpt_files"
        theDomain="existing"
        xpt = Xpt.new(outputDirectory,theDomain)

        # Fake data to send
        metadata = []
        rows = []

        it 'sets input directory '+outputDirectory do
            expect(xpt.directory).to eq(outputDirectory+"/")
        end
        it 'sets input filename '+theDomain+".xpt" do
            expect(xpt.filename).to eq(theDomain+".xpt")
        end
        it 'returns error that the file exists' do
            result = xpt.create_data("Dataset label",metadata,rows)
            expect(result[:status]).to eq(-2)
        end
        it 'and the file exists' do
            expect(File.exist?(xpt.directory+xpt.filename)).to eq(true)
        end
    end

    # Reports error if filename is longer than 8 characters
    context "when setting file name longer than 8 characters" do
        outputDirectory="./spec/output"
        theDomain="testdata1"
        xpt = Xpt.new(outputDirectory,theDomain)
        # Fake data to send
        metadata = []
        rows = []
        it 'sets input directory '+outputDirectory do
            expect(xpt.directory).to eq(outputDirectory+"/")
        end
        it 'sets input filename '+theDomain+".xpt" do
            expect(xpt.filename).to eq(theDomain+".xpt")
        end
        it 'reports error that file name is too long' do
            result = xpt.create_data("Dataset label",metadata,rows)
            expect(result[:status]).to eq(-101)
        end
        it 'and the filename is too long. Size: '+xpt.filename.chomp(".xpt").size.to_s do
            expect(xpt.filename.chomp(".xpt").size > 8).to eq(true)
        end
    end

    # Creates file with data
    context "when creating a file with data (metadata+rows)" do
        outputDirectory="./spec/output"
        theDomain="testdata"
        xpt = Xpt.new(outputDirectory,theDomain)

        metadata = [
            {name:"Char_11",label:"Label Char11",type:"char",length:11},
            {name:"Num1",label:"Label N1",type:"num",length:8}
        ]
        rows = [
            ["xpt.rb!",1.1],
            ["Only",0.1],
            ["Character",0.1],
            ["Content",-0.1],
            ["Allowed 01",4503599627370495]
        ]
        it 'sets input directory '+outputDirectory do
            expect(xpt.directory).to eq(outputDirectory+"/")
        end
        it 'sets input filename '+theDomain+".xpt" do
            expect(xpt.filename).to eq(theDomain+".xpt")
        end
        # Delete existing file, as it cannot exist
        it 'For test purposes. File is deleted before it is created' do
            File.delete(xpt.directory+xpt.filename) if File.exist?(xpt.directory+xpt.filename)
            expect(File.exist?(xpt.directory+xpt.filename)).to eq(false)
        end

        it 'creates the file ' do
            result = xpt.create_data("Dataset label",metadata,rows)
            expect(result[:status]).to eq(1)
        end
        it 'and the file exists' do
            expect(File.exist?(xpt.directory+xpt.filename)).to eq(true)
        end
    end

    # Compare binary content
    context "the created file " do
        it "binary compare should be the same (except dates)" do
            check_content("./spec/output/testdata.xpt", "./spec/support/compare_files/testdata_correct.xpt")
        end
    end
end
