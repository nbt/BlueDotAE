=begin
    describe 'on empty db' do
      before(:each) do
        @n_candidates = 10
        @candidate_attributes = generate_uoi_attributes(@n_candidates, 0)
        @candidate_records = generate_uoi_candidates(@n_candidates, 0)
        @selected_fields = [:f_string, :f_integer]
      end

      [[], nil, :none, :all].each do |condition|

        it "#{condition} :on_update => :all, :on_insert => :ignore inserts none" do
          UOITest.count.should == 0
          UOITest.update_or_insert(@candidate_records, condition, :on_update => :all, :on_insert => :ignore)
          UOITest.count.should == 0
        end

        it "#{condition} :on_update => :all, :on_insert => :error raises error" do
          UOITest.count.should == 0
          expect {
            UOITest.update_or_insert(@candidate_records, condition, :on_update => :all, :on_insert => :error)
          }.to raise_error(UpdateOrInsert::InsertError)
        end

        it "#{condition} :on_update => :all, :on_insert => :all inserts all" do
          UOITest.count.should == 0
          UOITest.update_or_insert(@candidate_records, condition, :on_update => :all, :on_insert => :all)
          UOITest.count.should == @n_candidates
          @candidate_attributes.each do |r|
            s = UOITest.first(:f_string => r[:f_string])
            r.keys.each { |k| s[k].should == r[k] }
          end
        end

        it "#{condition} :on_update => :all :on_insert => selected_fields populates only selected fields" do
          UOITest.count.should == 0
          UOITest.update_or_insert(@candidate_records, :all, :on_update => :all, :on_insert => @selected_fields)
          UOITest.count.should == @n_candidates
          @candidate_attributes.each do |r|
            s = UOITest.first(@selected_fields.first => r[@selected_fields.first])
            r.keys.each do |key|
              if @selected_fields.member?(key)
                s[key].should == r[key]
              else
                s[key].should be_nil
              end
            end
          end
          
        end
        
      end
      
    end
=end

    describe 'on populated db' do
      
      describe 'with no overlap' do
=begin
        before(:each) do
          @n_incumbents = 10
          @incumbent_attributes = generate_uoi_attributes(@n_incumbents, 0)
          @incumbent_records = generate_uoi_incumbents(@n_incumbents, 0)

          @n_candidates = 10
          @candidate_attributes = generate_uoi_attributes(@n_candidates, @n_incumbents)
          @candidate_records = generate_uoi_candidates(@n_candidates, @n_incumbents)

          @selected_fields = [:f_string, :f_integer]
        end
        
        [[], nil, :none, :all].each do |condition|

          it "#{condition} :on_update => :all, :on_insert => :ignore inserts none" do
            UOITest.count.should == @n_incumbents
            UOITest.update_or_insert(@candidate_records, condition, :on_update => :all, :on_insert => :ignore)
            UOITest.count.should == @n_incumbents
          end
          
          it "#{condition} :on_update => :all, :on_insert => :error raises error" do
            UOITest.count.should == @n_incumbents
            expect {
              UOITest.update_or_insert(@candidate_records, condition, :on_update => :all, :on_insert => :error)
            }.to raise_error(UpdateOrInsert::InsertError)
          end
          
          it "#{condition} :on_update => :all, :on_insert => :all inserts all" do
            UOITest.count.should == @n_incumbents
            UOITest.update_or_insert(@candidate_records, condition, :on_update => :all, :on_insert => :all)
            UOITest.count.should == @n_incumbents + @n_candidates
            @candidate_attributes.each do |r|
              s = UOITest.first(:f_string => r[:f_string])
              r.keys.each { |k| s[k].should == r[k] }
            end
          end
          
          it "#{condition} :on_update => :all :on_insert => selected_fields populates only selected fields" do
            UOITest.count.should == @n_incumbents
            UOITest.update_or_insert(@candidate_records, :all, :on_update => :all, :on_insert => @selected_fields)
            UOITest.count.should == @n_incumbents + @n_candidates
            @candidate_attributes.each do |r|
              s = UOITest.first(@selected_fields.first => r[@selected_fields.first])
              r.keys.each do |key|
                if @selected_fields.member?(key)
                  s[key].should == r[key]
                else
                  s[key].should be_nil
                end
              end
            end
          end

          it "#{condition} :on_update => :error, :on_insert => :all does not raise error" do
            UOITest.count.should == @n_incumbents
            expect {
              UOITest.update_or_insert(@candidate_records, condition, :on_update => :error, :on_insert => :all)
            }.to_not raise_error
          end

        end                     # [[], nil, :none, :all].each do |condition|
        
=end
      end                       # describe 'with no overlap' do

      describe 'with overlap' do
=begin
        before(:each) do
          @n_incumbents = 10
          @incumbent_attributes = generate_uoi_attributes(@n_incumbents, 0)
          @incumbent_records = generate_uoi_incumbents(@n_incumbents, 0)

          @n_candidates = 10
          @candidate_attributes = generate_uoi_attributes(@n_candidates, @n_incumbents / 2)
          @candidate_records = generate_uoi_candidates(@n_candidates, @n_incumbents / 2)

          # modify the candidates so we can distinguish them from the incumbents
          @candidate_attributes.each do |h| 
            h[:f_integer] = h[:f_integer] * 100
            h[:f_float] = h[:f_float] * 10
          end
          @candidate_records.each do |r| 
            r[:f_integer] = r[:f_integer] * 100
            r[:f_float] = r[:f_float] * 10
          end
          
        end

        # This set of tests convinced me to learn rcov

        [[], nil, :none].each do |condition|
          
          describe "condition = #{condition.inspect}" do
            before(:each) do
              @condition = condition
            end
            
            describe 'on_update => :ignore' do
              before(:each) do
                @on_update = :ignore
              end
              
              describe 'on_insert => :ignore' do
                before(:each) do 
                  @on_insert = :ignore
                end
                
                it "will work" do
                  UOITest.count.should == @n_incumbents
                  UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
                  UOITest.count.should == @n_incumbents
                  # incumbents should be unaltered
                  @incumbent_attributes.each do |h|
                    r = UOITest.first(:f_string => h[:f_string])
                    h.each_pair {|k,v| r[k].should == v}
                  end
                end
              end
              
              describe 'on_insert => :error' do
                before(:each) do 
                  @on_insert = :error
                end
                
                it "will work" do
                  UOITest.count.should == @n_incumbents
                  expect {
                    UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
                  }.to raise_error(UpdateOrInsert::InsertError)
                end
              end
              
              describe 'on_insert => :all' do
                before(:each) do 
                  @on_insert = :all
                end
                
                it "will work" do
                  UOITest.count.should == @n_incumbents
                  UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
                end
              end
              
              describe 'on_insert => [:f_integer]' do
                before(:each) do 
                  @on_insert = [:f_integer]
                end
                
                it "will work" do
                  UOITest.count.should == @n_incumbents
                  UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
                end
              end
              
              describe 'on_insert => [:f_float]' do
                before(:each) do 
                  @on_insert = [:f_float]
                end
                
                it "will work" do
                  UOITest.count.should == @n_incumbents
                  UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
                end
              end
              
            end
            
            describe 'on_update => :error' do
              before(:each) do
                @on_update = :error
              end
              
              # NB: Beacuse condition is :none, it will never match a
              # candidate with an incumbent, i.e. it will never
              # update.  Consequently, these tests should never raise
              # an UpdateError.

              describe 'on_insert => :ignore' do
                before(:each) do 
                  @on_insert = :ignore
                end
                
                it "will work" do
                  UOITest.count.should == @n_incumbents
                  UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
                end
              end
              
              describe 'on_insert => :error' do
                before(:each) do 
                  @on_insert = :error
                end
                
                it "will work" do
                  UOITest.count.should == @n_incumbents
                  expect {
                    UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
                  }.to raise_error(UpdateOrInsert::InsertError)
                end
              end
              
              describe 'on_insert => :all' do
                before(:each) do 
                  @on_insert = :all
                end
                
                it "will work" do
                  UOITest.count.should == @n_incumbents
                  UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
                end
              end
              
              describe 'on_insert => [:f_integer]' do
                before(:each) do 
                  @on_insert = [:f_integer]
                end
                
                it "will work" do
                  UOITest.count.should == @n_incumbents
                  UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
                end
              end
              
              describe 'on_insert => [:f_float]' do
                before(:each) do 
                  @on_insert = [:f_float]
                end
                
                it "will work" do
                  UOITest.count.should == @n_incumbents
                  UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
                end
              end
              
            end
            
            describe 'on_update => :all' do
              before(:each) do
                @on_update = :all
              end
                
              describe 'on_insert => :ignore' do
                before(:each) do 
                  @on_insert = :ignore
                end
                
                it "will work" do
                  UOITest.count.should == @n_incumbents
                  UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
                end
              end
              
              describe 'on_insert => :error' do
                before(:each) do 
                  @on_insert = :error
                end
                
                it "will work" do
                  UOITest.count.should == @n_incumbents
                  expect {
                    UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
                  }.to raise_error(UpdateOrInsert::InsertError)
                end
              end
              
              describe 'on_insert => :all' do
                before(:each) do 
                  @on_insert = :all
                end
                
                it "will work" do
                  UOITest.count.should == @n_incumbents
                  UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
                end
              end
              
              describe 'on_insert => [:f_integer]' do
                before(:each) do 
                  @on_insert = [:f_integer]
                end
                
              end
              
              describe 'on_insert => [:f_float]' do
                before(:each) do
                  @on_insert = [:f_float]
                end

                it "will work" do
                  UOITest.count.should == @n_incumbents
                  UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
                end
              end
              
            end
            
            describe 'on_update => [:f_float]' do
              before(:each) do
                @on_update = [:f_float]
              end
              
              describe 'on_insert => :ignore' do
                before(:each) do 
                  @on_insert = :ignore
                end
                
                it "will work" do
                  UOITest.count.should == @n_incumbents
                  UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
                end
              end
              
              describe 'on_insert => :error' do
                before(:each) do 
                  @on_insert = :error
                end
                
                it "will work" do
                  UOITest.count.should == @n_incumbents
                  expect {
                    UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
                  }.to raise_error(UpdateOrInsert::InsertError)
                end
              end
              
              describe 'on_insert => :all' do
                before(:each) do 
                  @on_insert = :all
                end
                
                it "will work" do
                  UOITest.count.should == @n_incumbents
                  UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
                end
              end
              
              describe 'on_insert => [:f_integer]' do
                before(:each) do 
                  @on_insert = [:f_integer]
                end
                
                it "will work" do
                  UOITest.count.should == @n_incumbents
                  UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
                end
              end
              
              describe 'on_insert => [:f_float]' do
                before(:each) do 
                  @on_insert = [:f_float]
                end
                
                it "will work" do
                  UOITest.count.should == @n_incumbents
                  UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
                end
              end
              
            end                 # describe 'on_update => [:f_float]' do
            
          end                   # describe "condition = #{condition}" do
          
        end                     # [[], nil, :none, :all].each do |condition|
        
        describe 'condition = :all' do
          before(:each) do
            @condition = :all
          end

          describe 'on_update => :ignore' do
            before(:each) do
              @on_update = :ignore
            end

            describe 'on_insert => :ignore' do
              before(:each) do 
                @on_insert = :ignore
              end

              it "will work" do
                UOITest.count.should == @n_incumbents
                UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
              end
            end

            describe 'on_insert => :error' do
              before(:each) do 
                @on_insert = :error
              end

              it "will work" do
                UOITest.count.should == @n_incumbents
                expect {
                  UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
                }.to raise_error(UpdateOrInsert::InsertError)
              end
            end

            describe 'on_insert => :all' do
              before(:each) do 
                @on_insert = :all
              end

              it "will work" do
                UOITest.count.should == @n_incumbents
                UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
              end
            end

            describe 'on_insert => [:f_integer]' do
              before(:each) do 
                @on_insert = [:f_integer]
              end

              it "will work" do
                UOITest.count.should == @n_incumbents
                UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
              end
            end

            describe 'on_insert => [:f_float]' do
              before(:each) do 
                @on_insert = [:f_float]
              end

              it "will work" do
                UOITest.count.should == @n_incumbents
                UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
              end
            end

          end

          describe 'on_update => :error' do
            before(:each) do
              @on_update = :error
            end

            # Because condition is :all, and the candidates have different
            # field values than the incumbents, the match will not overlap, 
            # i.e. there will be no updates.  So these tests should never
            # raise an UpdateError

            describe 'on_insert => :ignore' do
              before(:each) do 
                @on_insert = :ignore
              end

              it "will work" do
                UOITest.count.should == @n_incumbents
                UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
              end
            end

            describe 'on_insert => :error' do
              before(:each) do 
                @on_insert = :error
              end

              it "will work" do
                UOITest.count.should == @n_incumbents
                expect {
                  UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
                }.to raise_error(UpdateOrInsert::InsertError)
              end
            end

            describe 'on_insert => :all' do
              before(:each) do 
                @on_insert = :all
              end

              it "will work" do
                UOITest.count.should == @n_incumbents
                UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
              end
            end

            describe 'on_insert => [:f_integer]' do
              before(:each) do 
                @on_insert = [:f_integer]
              end

              it "will work" do
                UOITest.count.should == @n_incumbents
                UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
              end
            end

            describe 'on_insert => [:f_float]' do
              before(:each) do 
                @on_insert = [:f_float]
              end

              it "will work" do
                UOITest.count.should == @n_incumbents
                UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
              end
            end

          end

          describe 'on_update => :all' do
            before(:each) do 
              @on_update = :all
            end
            
            describe 'on_insert => :ignore' do
              before(:each) do 
                @on_insert = :ignore
              end

              it "will work" do
                UOITest.count.should == @n_incumbents
                UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
              end
            end

            describe 'on_insert => :error' do
              before(:each) do 
                @on_insert = :error
              end

              it "will work" do
                UOITest.count.should == @n_incumbents
                expect {
                  UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
                }.to raise_error(UpdateOrInsert::InsertError)
              end
            end

            describe 'on_insert => :all' do
              before(:each) do 
                @on_insert = :all
              end

              it "will work" do
                UOITest.count.should == @n_incumbents
                UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
              end
            end

            describe 'on_insert => [:f_integer]' do
              before(:each) do 
                @on_insert = [:f_integer]
              end

              it "will work" do
                UOITest.count.should == @n_incumbents
                UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
              end
            end

            describe 'on_insert => [:f_float]' do
              before(:each) do
                @on_insert = [:f_float]
              end

              it "will work" do
                UOITest.count.should == @n_incumbents
                UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
              end
            end

          end

          describe 'on_update => [:f_float]' do
            before(:each) do
              @on_update = [:f_float]
            end

            describe 'on_insert => :ignore' do
              before(:each) do 
                @on_insert = :ignore
              end

              it "will work" do
                UOITest.count.should == @n_incumbents
                UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
              end
            end

            describe 'on_insert => :error' do
              before(:each) do 
                @on_insert = :error
              end

              it "will work" do
                UOITest.count.should == @n_incumbents
                expect {
                  UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
                }.to raise_error(UpdateOrInsert::InsertError)
              end
            end

            describe 'on_insert => :all' do
              before(:each) do 
                @on_insert = :all
              end

              it "will work" do
                UOITest.count.should == @n_incumbents
                UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
              end
            end

            describe 'on_insert => [:f_integer]' do
              before(:each) do 
                @on_insert = [:f_integer]
              end

              it "will work" do
                UOITest.count.should == @n_incumbents
                UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
              end
            end

            describe 'on_insert => [:f_float]' do
              before(:each) do 
                @on_insert = [:f_float]
              end

              it "will work" do
                UOITest.count.should == @n_incumbents
                UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
              end
            end

          end

        end                     # describe 'condition = :all' do

        describe 'condition = [:f_boolean]' do
          before(:each) do
            @condition = [:f_boolean]
          end

          describe 'on_update => :ignore' do
            before(:each) do
              @on_update = :ignore
            end

            describe 'on_insert => :ignore' do
              before(:each) do 
                @on_insert = :ignore
              end

              it "will work" do
                UOITest.count.should == @n_incumbents
                UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
              end
            end

            describe 'on_insert => :error' do
              before(:each) do 
                @on_insert = :error
              end

              it "will work" do
                # because condition is [:f_boolean], candidates will
                # always match with at least one incumbent, i.e. there
                # will be no inserts.  Therefore we should never get
                # an InsertError
                UOITest.count.should == @n_incumbents
                UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
              end
            end

            describe 'on_insert => :all' do
              before(:each) do 
                @on_insert = :all
              end

              it "will work" do
                UOITest.count.should == @n_incumbents
                UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
              end
            end

            describe 'on_insert => [:f_integer]' do
              before(:each) do 
                @on_insert = [:f_integer]
              end

              it "will work" do
                UOITest.count.should == @n_incumbents
                UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
              end
            end

            describe 'on_insert => [:f_float]' do
              before(:each) do 
                @on_insert = [:f_float]
              end

              it "will work" do
                UOITest.count.should == @n_incumbents
                UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
              end
            end

          end

          describe 'on_update => :error' do
            before(:each) do
              @on_update = :error
            end

            describe 'on_insert => :ignore' do
              before(:each) do 
                @on_insert = :ignore
              end

              it "will work" do
                UOITest.count.should == @n_incumbents
                expect {
                  UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
                }.to raise_error(UpdateOrInsert::UpdateError)
              end
            end

            describe 'on_insert => :error' do
              before(:each) do 
                @on_insert = :error
              end

              it "will work" do
                UOITest.count.should == @n_incumbents
                expect {
                  UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
                }.to raise_error { |error|
                  # we don't know which error will be raised first
                  error.should satisfy {|e| 
                    e.instance_of?(UpdateOrInsert::InsertError) || e.instance_of?(UpdateOrInsert::UpdateError)
                  }
                }
              end
            end

            describe 'on_insert => :all' do
              before(:each) do 
                @on_insert = :all
              end

              it "will work" do
                UOITest.count.should == @n_incumbents
                expect {
                  UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
                }.to raise_error(UpdateOrInsert::UpdateError)
              end
            end

            describe 'on_insert => [:f_integer]' do
              before(:each) do 
                @on_insert = [:f_integer]
              end

              it "will work" do
                UOITest.count.should == @n_incumbents
                expect {
                  UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
                }.to raise_error(UpdateOrInsert::UpdateError)
              end
            end

            describe 'on_insert => [:f_float]' do
              before(:each) do 
                @on_insert = [:f_float]
              end

              it "will work" do
                UOITest.count.should == @n_incumbents
                expect {
                  UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
                }.to raise_error(UpdateOrInsert::UpdateError)
              end
            end

          end

          describe 'on_update => :all' do
            before(:each) do
              @on_update = :all
            end

            describe 'on_insert => :ignore' do
              before(:each) do 
                @on_insert = :ignore
              end

              it "will work" do
                UOITest.count.should == @n_incumbents
                UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
              end
            end

            describe 'on_insert => :error' do
              before(:each) do 
                @on_insert = :error
              end

              it "will work" do
                # because condition is [:f_boolean], candidates will
                # always match with at least one incumbent, i.e. there
                # will be no inserts.  Therefore we should never get
                # an InsertError
                UOITest.count.should == @n_incumbents
                UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
              end
            end

            describe 'on_insert => :all' do
              before(:each) do 
                @on_insert = :all
              end

              it "will work" do
                UOITest.count.should == @n_incumbents
                UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
              end
            end

            describe 'on_insert => [:f_integer]' do
              before(:each) do 
                @on_insert = [:f_integer]
              end

              it "will work" do
                UOITest.count.should == @n_incumbents
                UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
              end
            end

            describe 'on_insert => [:f_float]' do
              before(:each) do
                @on_insert = [:f_float]
              end

              it "will work" do
                UOITest.count.should == @n_incumbents
                UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
              end
            end

          end

          describe 'on_update => [:f_float]' do
            before(:each) do
              @on_update = [:f_float]
            end

            describe 'on_insert => :ignore' do
              before(:each) do 
                @on_insert = :ignore
              end

              it "will work" do
                UOITest.count.should == @n_incumbents
                UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
              end
            end

            describe 'on_insert => :error' do
              before(:each) do 
                @on_insert = :error
              end

              it "will work" do
                # because condition is [:f_boolean], candidates will
                # always match with at least one incumbent, i.e. there
                # will be no inserts.  Therefore we should never get
                # an InsertError
                UOITest.count.should == @n_incumbents
                UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
              end
            end

            describe 'on_insert => :all' do
              before(:each) do 
                @on_insert = :all
              end

              it "will work" do
                UOITest.count.should == @n_incumbents
                UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
              end
            end

            describe 'on_insert => [:f_integer]' do
              before(:each) do 
                @on_insert = [:f_integer]
              end

              it "will work" do
                UOITest.count.should == @n_incumbents
                UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
              end
            end

            describe 'on_insert => [:f_float]' do
              before(:each) do 
                @on_insert = [:f_float]
              end

              it "will work" do
                UOITest.count.should == @n_incumbents
                UOITest.update_or_insert(@candidate_records, @condition, :on_update => @on_update, :on_insert => @on_insert)
              end
            end

          end

        end                     # describe 'condition = [:f_boolean]' do


=end
      end                       # describe 'with overlap' do

    end                         # describe 'on populated db' do
