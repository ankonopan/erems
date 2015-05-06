require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe RPackage do
  before do
    @package = RPackage.new
  end

  it "extract maitainers" do
    @package.maintainer = "John <email@email.com>"
    expect(@package.maintainers_h.first[:name]).to eq "John"
    expect(@package.maintainers_h.first[:email]).to eq "email@email.com"
  end

  it "should extract only the name when available" do
    @package.maintainer = "John Dow"
    expect(@package.maintainers_h.first[:name]).to eq "John Dow"
    expect(@package.maintainers_h.first[:email]).to be_empty
  end

end
