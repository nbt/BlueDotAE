require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'vcr_cassettes'
  c.hook_into :webmock
  c.before_playback(:with_time_frozen) { |interaction|
    Timecop.freeze(interaction.recorded_at)
  }
end
