require "spec_helper"

describe Xpt do
  
    context "expect gem to read xpt with supplemental data as metadata ------------------------" do
        it 'as specified' do
        end
    end
    # Reports error on non-existing directory
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
            result = xpt.read_supp_meta
            expect(result[:status]).to eq(-1)
        end
    end

    # Reports error on non-existing file
    context "when setting non-existing file" do
        inputDirectory="./spec/support/xpt_files"
        theDomain="doesnotexist"
        xpt = Xpt.new(inputDirectory,theDomain)

        it 'sets input directory '+inputDirectory do
            expect(xpt.directory).to eq(inputDirectory+"/")
        end
        it 'sets input filename '+theDomain+".xpt" do
            expect(xpt.filename).to eq(theDomain+".xpt")
        end
        it 'returns error' do
            result = xpt.read_supp_meta
            expect(result[:status]).to eq(-2)
        end
    end

    # Reports error if filename does not match "SUPP--"
    context "when setting incorrect file name supdm (i.e. not SUPP--)" do
        inputDirectory="./spec/support/xpt_files"
        theDomain="supdm"
        xpt = Xpt.new(inputDirectory,theDomain)

        it 'sets input directory '+inputDirectory do
            expect(xpt.directory).to eq(inputDirectory+"/")
        end
        it 'sets input filename '+theDomain do
            expect(xpt.filename).to eq(theDomain+".xpt")
        end
        it 'returns error for '+theDomain do
            result = xpt.read_supp_meta
            expect(result[:status]).to eq(-3)
        end
    end

    # Reports error if filename does not match "SUPP--"
    context "when setting incorrect file name supdm (i.e. not SUPP--)" do
        inputDirectory="./spec/support/xpt_files"
        theDomain="suppdmm"
        xpt = Xpt.new(inputDirectory,theDomain)

        it 'sets input directory '+inputDirectory do
            expect(xpt.directory).to eq(inputDirectory+"/")
        end
        it 'sets input filename '+theDomain do
            expect(xpt.filename).to eq(theDomain+".xpt")
        end
        it 'returns error for '+theDomain do
            result = xpt.read_supp_meta
            expect(result[:status]).to eq(-3)
        end
    end

    # Correct file
    context "when setting existing file" do
        inputDirectory="./spec/support/xpt_files" # Intentionally without ending "/", should be added by class
        theDomain="suppdm"
        xpt = Xpt.new(inputDirectory,theDomain)

        it 'sets input directory '+inputDirectory do
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
