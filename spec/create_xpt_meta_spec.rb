require "spec_helper"

describe Xpt do
  
    context "expect gem to create xpt file with metadata only ------------------------" do
        it 'as specified' do
        end
    end
    # Reports error on non-existing directory
    context "when setting non-existing directory" do
        outputDirectory="./support/sdf"
        theDomain="dm"
        xpt = Xpt.new(outputDirectory,theDomain)

        # Fake metadata to send
        metadata = []
        it 'sets input directory '+outputDirectory do
            expect(xpt.directory).to eq(outputDirectory+"/")
        end
        it 'sets input filename '+theDomain+".xpt" do
            expect(xpt.filename).to eq(theDomain+".xpt")
        end
        it 'returns error' do
            result = xpt.create_meta("Dataset label",metadata)
            expect(result[:status]).to eq(-1)
        end
    end

    # Reports error on non-existing file
    context "when setting non-existing file" do
        outputDirectory="./spec/support/xpt_files"
        theDomain="doesnotexist"
        xpt = Xpt.new(outputDirectory,theDomain)

        # Fake metadata to send
        metadata = []

        it 'sets input directory '+outputDirectory do
            expect(xpt.directory).to eq(outputDirectory+"/")
        end
        it 'sets input filename '+theDomain+".xpt" do
            expect(xpt.filename).to eq(theDomain+".xpt")
        end
        it 'returns error' do
            result = xpt.create_meta("Dataset label",metadata)
            expect(result[:status]).to eq(-2)
        end
    end

    # Reports error if filename does not match "SUPP--"
    # context "when setting incorrect file name supdm (i.e. not SUPP--)" do
    #     outputDirectory="./spec/support/xpt_files"
    #     theDomain="supdm"
    #     xpt = Xpt.new(outputDirectory,theDomain)

    #     it 'sets input directory '+outputDirectory do
    #         expect(xpt.directory).to eq(outputDirectory+"/")
    #     end
    #     it 'sets input filename '+theDomain do
    #         expect(xpt.filename).to eq(theDomain+".xpt")
    #     end
    #     it 'returns error for '+theDomain do
    #         result = xpt.read_supp_meta
    #         expect(result[:status]).to eq(-3)
    #     end
    # end

    # Reports error on non-existing file
    context "when creating a file with metadata" do
        outputDirectory="./spec/support/xpt_files"
        theDomain="wm1"
        xpt = Xpt.new(outputDirectory,theDomain)
        metadata = [[name:"c1",label:"label c1",type:"char",length:11],
                    [name:"n1",label:"label n1",type:"num",length:8]
        ]

        it 'sets input directory '+outputDirectory do
            expect(xpt.directory).to eq(outputDirectory+"/")
        end
        it 'sets input filename '+theDomain+".xpt" do
            expect(xpt.filename).to eq(theDomain+".xpt")
        end
        it 'creates a file' do
            result = xpt.create_meta(self.directory,self.filename,metadata)
            expect(result[:status]).to eq(-2)
        end
    end



end
