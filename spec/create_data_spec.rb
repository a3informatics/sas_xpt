require "spec_helper"

describe Xpt do
  
    context "expect gem to create xpt file with data ------------------------" do
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
            result = xpt.create_meta
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
            result = xpt.create_meta
            expect(result[:status]).to eq(-2)
        end
    end

    # Reports error if filename does not match "SUPP--"
    # context "when setting incorrect file name supdm (i.e. not SUPP--)" do
    #     inputDirectory="./spec/support/xpt_files"
    #     theDomain="supdm"
    #     xpt = Xpt.new(inputDirectory,theDomain)

    #     it 'sets input directory '+inputDirectory do
    #         expect(xpt.directory).to eq(inputDirectory+"/")
    #     end
    #     it 'sets input filename '+theDomain do
    #         expect(xpt.filename).to eq(theDomain+".xpt")
    #     end
    #     it 'returns error for '+theDomain do
    #         result = xpt.read_supp_meta
    #         expect(result[:status]).to eq(-3)
    #     end
    # end


end
