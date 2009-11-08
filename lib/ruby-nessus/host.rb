module Nessus
  class Host
    # Host
    attr_reader :host

    # Creates A New Host Object
    # @param [Object] Host Object
    # @example
    # Host.new(object)
    def initialize(host)
      @host = host
    end

    # Return the Host Object hostname.
    # @return [String]
    #   The Host Object Hostname
    # @example
    #   host.hostname #=> "127.0.0.1"
    def hostname
      @hostname ||= @host.at('HostName').inner_text
    end

    # Return the host scan start time.
    # @return [DateTime]
    #   The Host Scan Start Time
    # @example
    #   scan.scan_start_time #=> 'Fri Nov 11 23:36:54 1985'
    def scan_start_time
      @host_scan_time = @host.at('startTime').inner_text
    end

    # Return the host scan stop time.
    # @return [DateTime]
    #   The Host Scan Stop Time
    # @example
    #   scan.scan_start_time #=> 'Fri Nov 11 23:36:54 1985'
    def scan_stop_time
      @host_scan_time = @host.at('stopTime').inner_text
    end
    
    # Return the host run time.
    # @return [String]
    #   The Host Scan Run Time
    # @example
    #   scan.scan_run_time #=> '2 hours 5 minutes and 16 seconds'
    def scan_run_time
      if scan_start_time.empty? | scan_stop_time.empty?; return "N/A"; end
      h = ("#{Time.parse(scan_stop_time).strftime('%H').to_i - Time.parse(scan_start_time).strftime('%H').to_i}").gsub('-', '')
      m = ("#{Time.parse(scan_stop_time).strftime('%M').to_i - Time.parse(scan_start_time).strftime('%M').to_i}").gsub('-', '')
      s = ("#{Time.parse(scan_stop_time).strftime('%S').to_i - Time.parse(scan_start_time).strftime('%S').to_i}").gsub('-', '')
      return "#{h} hours #{m} minutes and #{s} seconds"
    end

    # Return the Host Netbios Name.
    # @return [String]
    #   The Host Netbios Name
    # @example
    #   host.netbios_name #=> "SOMENAME4243"
    def netbios_name
      @netbios_name ||= @host.at('netbios_name').inner_text
    end

    # Return the Host Mac Address.
    # @return [String]
    #   Return the Host Mac Address
    # @example
    #   host.mac_addr #=> "00:11:22:33:44:55"
    def mac_addr
      @mac_addr ||= @host.at('mac_addr').inner_text
    end

    # Return the Host DNS Name.
    # @return [String]
    #   Return the Host DNS Name
    # @example
    #   host.dns_name #=> "snorby.org"
    def dns_name
      @dns_name ||= @host.at('dns_name').inner_text
    end

    # Return the Host OS Name.
    # @return [String]
    #   Return the Host OS Name
    # @example
    #   host.dns_name #=> "Microsoft Windows 2000, Microsoft Windows Server 2003"
    def os_name
      @os_name ||= @host.at('os_name').inner_text
    end

    # Return the scanned port count for a given host object.
    # @return [Integer]
    #   Return the Scanned Port Count For A Given Host Object.
    # @example
    #   host.scanned_ports_count #=> 213
    def scanned_ports_count
      @scanned_ports ||= false_if_zero(
        @host.at('num_ports').inner_text.to_i
      )
    end
    
    def informational_severity_events(&block)
      unless @informational_severity_events
        @informational_severity_events = []
        @informational_severity_count = 0

        @host.xpath("//ReportItem").each do |event|
          next if event.at('severity').inner_text.to_i != 0
          @informational_severity_events << Event.new(event)
          @informational_severity_count += 1
        end

        @informational_severity_count = @host.at('num_lo').inner_text.to_i
      end

      @informational_severity_events.each(&block)
      return @informational_severity_count
    end

    # Return the low severity event count for a given host object.
    # @return [Integer]
    #   Return the low severity event count for a given host object.
    # @example
    #   host.low_severity_events_count #=> 53443
    def low_severity_events(&block)
      unless @low_severity_events
        @low_severity_events = []

        @host.xpath("//ReportItem").each do |event|
          next if event.at('severity').inner_text.to_i != 1
          @low_severity_events << Event.new(event)
        end

        @low_severity_count = @host.at('num_lo').inner_text.to_i
      end

      @low_severity_events.each(&block)
      return @low_severity_count
    end

    # Return the medium severity event count for a given host object.
    # @return [Integer]
    #   Return the low medium event count for a given host object.
    # @example
    #   host.medium_severity_events_count #=> 43
    def medium_severity_events(&block)
      unless @medium_severity_events
        @medium_severity_events = []

        @host.xpath("//ReportItem").each do |event|
          next if event.at('severity').inner_text.to_i != 2
          @medium_severity_events << Event.new(event)
        end

        @high_severity_count = @host.at('num_med').inner_text.to_i
      end

      @medium_severity_events.each(&block)
      return @high_severity_count
    end

    # Return the medium severity event count for a given host object.
    # @return [Integer]
    #   Return the low medium event count for a given host object.
    # @example
    #   host.medium_severity_events_count #=> 43
    def high_severity_events(&block)
      unless @high_severity_events
        @high_severity_events = []

        @host.xpath("//ReportItem").each do |event|
          next if event.at('severity').inner_text.to_i != 3
          @high_severity_events << Event.new(event)
        end

        @high_severity_count = @host.at('num_hi').inner_text.to_i
      end

      @high_severity_events.each(&block)
      return @high_severity_count
    end

    def event_count
      (informational_severity_events + low_severity_events + medium_severity_events + high_severity_events).to_i
    end

    def events(&block)
      @host.xpath("//ReportItem").each do |event|
        block.call(Event.new(event)) if block
      end
    end

  end
end
