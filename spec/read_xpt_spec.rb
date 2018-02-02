require "spec_helper"

describe Xpt do
  
  # Reports error on non-existing directory
    context "when setting non-existing directory" do
        it 'returns error' do
            inputDirectory="./support/sdf"
            theDomain="dm"
            xpt = Xpt.new(inputDirectory,theDomain+".xpt")

            result = xpt.read_data
            expect(result).to eq(-1)
        end
    end

  # Reports error on non-existing file
    context "when setting non-existing file" do
        inputDirectory="./support/xpt_files"
        theDomain="doesnotexist"
        xpt = Xpt.new(inputDirectory,theDomain+".xpt")

        it 'returns error' do
            result = xpt.read_data
            expect(result).to eq(-1)
        end
    end

  # Correct file
    context "when setting existing file" do
        inputDirectory="./spec/support/xpt_files"
        theDomain="dm"
        xpt = Xpt.new(inputDirectory,theDomain+".xpt")

        it 'sets input directory' do
            expect(xpt.directory).to eq(inputDirectory)
        end
        it 'sets input filename' do
            expect(xpt.file).to eq(theDomain+".xpt")
        end

        it 'reads xpt file and variables are the same and the same number of rows' do
            result = xpt.read_data

            correct_variables =["STUDYID","DOMAIN","USUBJID","SUBJID","RFSTDTC","RFENDTC","RFXSTDTC", "RFXENDTC",
                                "RFICDTC","RFPENDTC","DTHDTC","DTHFL","SITEID","AGE","AGEU","SEX","RACE","ETHNIC",
                                "ARMCD","ARM","ACTARMCD","ACTARM","COUNTRY","DMDTC","DMDY"]

            read_variables = []
            result[:variables].each do |map|
                read_variables << map[:name]
            end

            # expect(result[:variables][0]).to be correct_variables[0]
            expect(read_variables).to eq(correct_variables)
            expect(result[:data].size).to equal 306
        end
    end
end
