# ArpEvent

This gem is a library for triggering events based on the presence of a device
on the Local Area Network (LAN). It is a light wrapper around the `arp-scan`
command-line utility.  Presently, there are 3 events available:

* on_initial_presence - Triggered on the first run of `check_presence!`
* on_arrive - Triggered when a device is detected to have joined the network
* on_leave - Triggered when a device is leaves the network

## Installation

Install the `arp-scan` utility.

```bash
# OSX
brew install arp-scan

# Debian/Ubuntu
apt-get install arp-scan
```

Add this line to your application's Gemfile:

```ruby
gem 'arp_event'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install arp_event

## Usage

Sample code:

```ruby
#!/usr/bin/env ruby
require 'arp_event'

DEVICES = [
  ArpEvent::Device.new(name: 'Joe', mac: '1a:2b:3c:4d:5e:6f'),
  ArpEvent::Device.new(name: 'Jane', mac: 'a1:b2:c3:d4:e5:f6')
]

DEVICES.each do |device|
  device.on_initial_presence do |dev|
    if dev.present
      puts "#{dev.name} is home"
    else
      puts "#{dev.name} is away"
    end
  end

  device.on_arrive do |dev|
    msg = "#{dev.name} %s (last seen: #{dev.last_seen})"
    puts sprintf(msg, 'came home')
  end

  device.on_leave do |dev|
    msg = "#{dev.name} %s (last seen: #{dev.last_seen})"
    puts sprintf(msg, 'left')
  end
end

loop do
  DEVICES.each { |device| device.check_presence! }
  sleep 5
end
```

This will output something like:

```
Joe is home
Jane is home
Joe left (last seen: 2016-01-14 12:41:34 -0500)
Joe came home (last seen: 2016-01-14 12:41:34 -0500)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/aaronbbrown/arp_event/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
