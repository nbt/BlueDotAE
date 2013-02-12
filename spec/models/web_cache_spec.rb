require 'spec_helper'
require 'vcr_helper'

describe "WebCache Model" do
  before(:each) do
    WebCache.destroy
  end
  let(:web_cache) { WebCache.new }

  it 'can be created' do
    web_cache.should_not be_nil
  end

  it 'test starts with an empty db' do
    WebCache.count.should == 0
  end

  it 'can be persisted' do
    # $stderr.puts("web_cache = #{web_cache}")
    # expect{ web_cache.save }.to change(WebCache.count).by(1)
    count = WebCache.count
    web_cache.save
    WebCache.count.should == count + 1
  end

  it 'test deletes records between tests' do
    WebCache.count.should == 0
  end

  describe 'with_db_caching' do
    let(:target) { "http://lambda.csail.mit.edu" }

    it 'should cache entry on first access to a uri' do
      VCR.use_cassette("web_cache_spec_0") do
        count = WebCache.count.should == 0
        WebCache.with_db_cache(target) {|uri|
          Net::HTTP.get(URI(uri))
        }
        WebCache.count.should == 1
      end
    end

    it 'should fetch cached entry on second access' do
      VCR.use_cassette("web_cache_spec_1") do
        count = WebCache.count.should == 0
        WebCache.with_db_cache(target) {|uri|
          Net::HTTP.get(URI(uri))
        }
        WebCache.count.should == 1
        expect { WebCache.with_db_cache(target) {|uri|
            raise RuntimeError
          }
        }.to_not raise_error
      end
    end

  end
    
end
