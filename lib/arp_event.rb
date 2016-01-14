require "arp_event/version"

module ArpEvent
  class Device
    attr_reader :name, :mac, :last_seen, :present
    def initialize(name:, mac:)
      @name = name
      @mac = mac
      @prev_present = nil
      @present = false
      @on_arrive_block           = nil
      @on_leave_block            = nil
      @on_initial_presence_block = nil
      @initial_presence_run = false
    end

    def present?
      %x[arp-scan -l --destaddr="#{@mac}" --retry=5].split.include?(@mac)
    end

    def check_presence!
      # on first run, @prev_present is nil, so set it to be the current state
      if @prev_present.nil?
        @present = present?
        @prev_present = @present
      else
        @prev_present = @present
        @present = present?
      end

      call_initial_presence
      if @present
        call_on_arrive
      else
        call_on_leave
      end
      @present
    end

    def on_arrive(&block)
      @on_arrive_block = block
    end

    def on_leave(&block)
      @on_leave_block = block
    end

    def on_initial_presence(&block)
      @on_initial_presence_block = block
    end

    def call_initial_presence
      result = nil
      result = @on_initial_presence_block.call(self) unless @initial_presence_run
      @initial_presence_run = true
      result
    end

    def call_on_arrive
      result = nil
      if !@prev_present && @on_arrive_block.respond_to?(:call)
        result = @on_arrive_block.call(self)
      end
      @last_seen = Time.new
      result
    end

    def call_on_leave
      result = nil
      if @prev_present && @on_leave_block.respond_to?(:call)
        result = @on_leave_block.call(self)
      end
      result
    end
  end
end
