require 'spec_helper'

describe "WebCache Model" do
  before(:each) do
    WebCache.destroy
  end

  let(:web_cache) { WebCache.new }
  it 'can be created' do
    web_cache.should_not be_nil
  end

  it 'starts with an empty db' do
    WebCache.count.should == 0
  end

  it 'can be persisted' do
    # expect{ web_cache.save }.to change(WebCache.count).by(1)
    count = WebCache.count
    web_cache.save
    WebCache.count.should == count + 1
  end

  it 'deletes records between tests' do
    WebCache.count.should == 0
  end

  
    
end
