require 'spec_helper'
require 'vcr_helper'

describe ClientSetup do
  
  describe "setup" do 
    it 'creates an account without error' do
      VCR.use_cassette("Client_setup_create_an_account",
                       :match_requests_on => [:method, :uri, :query]) do
        ClientSetup.setup("Chris Wright", 
                          "1402 EOLUS AVE, ENCINITAS, CA 92024", 
                          "ChrisWrightFamily", 
                          "U0RHRW9sdXMxNDAy", 
                          ["01046957", "05219047"])        
      end
    end
  end

end
