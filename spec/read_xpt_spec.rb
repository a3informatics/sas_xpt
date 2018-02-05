require "spec_helper"

describe Xpt do
  
  # Reports error on non-existing directory
    context "expect gem to read xpt data ------------------------" do
        it 'as specified' do
        end
    end
    context "when setting non-existing directory" do
        it 'returns error' do
            inputDirectory="./support/sdf"
            theDomain="dm"
            xpt = Xpt.new(inputDirectory,theDomain+".xpt")

            result = xpt.read_data
            expect(result[:status]).to eq(-1)
        end
    end

  # Reports error on non-existing file
    context "when setting non-existing file" do
        inputDirectory="./support/xpt_files"
        theDomain="doesnotexist"
        xpt = Xpt.new(inputDirectory,theDomain+".xpt")

        it 'returns error' do
            result = xpt.read_data
            expect(result[:status]).to eq(-1)
        end
    end

  # Correct file
    context "when setting existing file" do
        inputDirectory="./spec/support/xpt_files" # Intentionally without ending "/", should be added
        theDomain="dm"
        xpt = Xpt.new(inputDirectory,theDomain+".xpt")

        it 'sets input directory' do
            expect(xpt.directory).to eq(inputDirectory+"/")
        end
        it 'sets input filename' do
            expect(xpt.file).to eq(theDomain+".xpt")
        end

        it 'reads xpt file and returns the correct variables and content on the last row' do
            result = xpt.read_data

            correct_variables =["STUDYID","DOMAIN","USUBJID","SUBJID","RFSTDTC","RFENDTC","RFXSTDTC", "RFXENDTC",
                                "RFICDTC","RFPENDTC","DTHDTC","DTHFL","SITEID","AGE","AGEU","SEX","RACE","ETHNIC",
                                "ARMCD","ARM","ACTARMCD","ACTARM","COUNTRY","DMDTC","DMDY"]

            read_variables = []
            result[:variables].each do |map|
                read_variables << map[:name]
            end

            # Check that it is the right variables
            expect(read_variables).to eq(correct_variables)
            # Check that the number of rows are correct
            expect(result[:data].size).to equal 306
            # On last row, check USUBJID (char), AGE (num) and the last variable in the dataset DMDY
            expect(result[:data][-1]['USUBJID']).to eq("01-718-1427")
            expect(result[:data][-1]['AGE']).to eq(74.0)
            expect(result[:data][-1]['DMDY']).to eq(-4.0)
        end
    end
end
