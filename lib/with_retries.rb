module WithRetries
  extend self
  
  WITH_RETRIES_DEFAULT_OPTIONS = {
    :ignore => [],
    :retry => [],
    :max_retries => 3,
    :delay_exponent => 3.0,
    :verbose => true
  }

  # Try executing a block.  If it raises an error that is on the
  # :ignore list, with_retries returns nil.  If it raises an error on
  # the :retry list, it will re-run the block up to max_reties times
  # with exponentially increasing delays.  If the block continues
  # to raise an error, with_retries re-raises that error, otherwise
  # the results of the block are returned.
  #
  def with_retries(options = {}, &block)
    options = WITH_RETRIES_DEFAULT_OPTIONS.merge(options)
    retries = 0
    while true do
      begin
         return yield
      rescue *options[:ignore] => e
        $stderr.puts("=== ignoring #{e.class}: #{e.message}") if options[:verbose]
        return
      rescue *options[:retry] => e
        $stderr.puts("=== rescuing #{e.class}: #{e.message} (retry = #{retries}/#{options[:max_retries]})") if options[:verbose]
        raise if (retries >= options[:max_retries])
        if (options[:delay_exponent] > 0.0) 
          delay_time = options[:delay_exponent] ** retries
          sleep delay_time
        end
        retries += 1
      end
    end
  end

end

