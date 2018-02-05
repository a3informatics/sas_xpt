require "spec_helper"

describe Xpt do
  
  # Reports error on non-existing directory
    context "expect gem to read xpt metadata ------------------------" do
        it 'as specified' do
        end
    end
    context "when setting non-existing directory" do
        inputDirectory="./support/sdf"
        theDomain="dm"
        xpt = Xpt.new(inputDirectory,theDomain)

        it 'sets input directory '+inputDirectory do
            expect(xpt.directory).to eq(inputDirectory+"/")
        end
        it 'sets input filename '+theDomain+".xpt" do
            expect(xpt.filename).to eq(theDomain+".xpt")
        end

        it 'returns error' do
            result = xpt.read_meta
            expect(result[:status]).to eq(-1)
        end
    end

  # Reports error on non-existing file
    context "when setting non-existing file" do
        inputDirectory="./spec/support/xpt_files" # Intentionally without ending "/", should be added by class
        theDomain="doesnotexist"
        xpt = Xpt.new(inputDirectory,theDomain)
        it 'sets input directory '+inputDirectory do
            expect(xpt.directory).to eq(inputDirectory+"/")
        end
        it 'sets input filename '+theDomain+".xpt" do
            expect(xpt.filename).to eq(theDomain+".xpt")
        end

        it 'returns error' do
            result = xpt.read_meta
            expect(result[:status]).to eq(-2)
        end
    end

  # Correct file
    context "when setting existing file" do
        inputDirectory="./spec/support/xpt_files" # Intentionally without ending "/", should be added by class
        theDomain="dm"
        xpt = Xpt.new(inputDirectory,theDomain)

        it 'sets input directory '+inputDirectory do
            expect(xpt.directory).to eq(inputDirectory+"/")
        end
        it 'sets input filename '+theDomain+".xpt" do
            expect(xpt.filename).to eq(theDomain+".xpt")
        end

        it 'reads xpt file metadata and returns the correct variables' do
            result = xpt.read_meta

            correct_variables =["STUDYID","DOMAIN","USUBJID","SUBJID","RFSTDTC","RFENDTC","RFXSTDTC", "RFXENDTC",
                                "RFICDTC","RFPENDTC","DTHDTC","DTHFL","SITEID","AGE","AGEU","SEX","RACE","ETHNIC",
                                "ARMCD","ARM","ACTARMCD","ACTARM","COUNTRY","DMDTC","DMDY"]

            read_variables = []
            result[:variables].each do |map|
                read_variables << map[:name]
            end

            # Check that it is the right variables
            expect(read_variables).to eq(correct_variables)
        end
    end
end
