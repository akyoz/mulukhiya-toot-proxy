module Mulukhiya
  class Reporter < Array
    attr_accessor :response
    attr_accessor :parser
    attr_accessor :account
    attr_reader :temp

    def initialize(size = 0, val = nil)
      super
      @logger = Logger.new
      @temp = {}
    end

    def tags
      @tags ||= TagContainer.new
      return @tags
    end

    def push(entry)
      return unless entry.present?
      super
      @logger.info(entry)
      @dump = nil
    end

    def to_h
      unless @dump
        @dump = {}
        each do |entry|
          unless @account&.notify_verbose?
            next if entry[:verbose] && !entry[:errors].present?
          end
          @dump[entry[:event]] ||= {}
          @dump[entry[:event]][entry[:handler]] ||= []
          [:result, :errors].each do |k|
            @dump[entry[:event]][entry[:handler]].concat(
              entry[k].map {|v| v.is_a?(Hash) ? v.deep_stringify_keys : v},
            )
          end
        end
      end
      return @dump
    end

    def to_s
      return to_h.to_yaml
    end
  end
end
