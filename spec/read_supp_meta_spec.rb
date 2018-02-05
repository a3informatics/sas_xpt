require "spec_helper"

describe Xpt do
  
  # Reports error on non-existing directory
    context "expect gem to read xpt with supplemental data as metadata ------------------------" do
        it 'as specified' do
        end
    end
    context "when setting non-existing directory" do
        it 'returns error' do
            inputDirectory="./support/sdf"
            theDomain="dm"
            xpt = Xpt.new(inputDirectory,theDomain+".xpt")

            result = xpt.read_supp_meta
            expect(result[:status]).to eq(-1)
        end
    end

  # Reports error on non-existing file
    context "when setting non-existing file" do
        inputDirectory="./support/xpt_files"
        theDomain="doesnotexist"
        xpt = Xpt.new(inputDirectory,theDomain+".xpt")

        it 'returns error' do
            result = xpt.read_supp_meta
            expect(result[:status]).to eq(-1)
        end
    end

  # Reports error if file does not start with "SUPP"
    context "when setting incorrect file name (i.e. not SUPP--)" do
        inputDirectory="./spec/support/xpt_files"
        theDomain="supdm"
        xpt = Xpt.new(inputDirectory,theDomain+".xpt")

        it 'returns error for supdm' do
            result = xpt.read_supp_meta
            expect(result[:status]).to eq(-2)
        end

        inputDirectory="./spec/support/xpt_files"
        theDomain="supdm"
        xpt = Xpt.new(inputDirectory,theDomain+".xpt")

        it 'returns error for suppdmm' do
            result = xpt.read_supp_meta
            expect(result[:status]).to eq(-2)
        end

    end


  # Correct file
    context "when setting existing file" do
        inputDirectory="./spec/support/xpt_files" # Intentionally without ending "/", should be added by class
        theDomain="suppdm"
        xpt = Xpt.new(inputDirectory,theDomain+".xpt")

        it 'sets input directory' do
            expect(xpt.directory).to eq(inputDirectory+"/")
        end
        it 'sets input filename '+theDomain do
            expect(xpt.filename).to eq(theDomain+".xpt")
        end

        it 'reads xpt file metadata and returns the correct variables' do
            result = xpt.read_supp_meta

            correct_variables =["COMPLT16","COMPLT24","COMPLT8","EFFICACY","ITT","SAFETY"]

            read_variables = []
            result[:variables].each do |map|
                read_variables << map[:name]
            end

            # Check that it is the right variables
            expect(read_variables).to eq(correct_variables)
        end
    end
end
