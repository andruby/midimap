require "micromidi"
require "debouncer"

input = UniMIDI::Input.gets

def debouncer(uid, delay, *args, &block)
  @debouncers ||= {}
  @debouncers[uid] ||= Debouncer.new(delay, &block)
  @debouncers[uid].call(*args)
end

MIDI.using(input) do
  receive :control_change do |message|
    puts "--"
    puts message.inspect

    if(message.channel == 0 && message.index == 14)
      debouncer(:brightness, 0.1, message.value) do |val|
        spawn("./ddcctl -d 1 -b #{val}")
      end
    end

    if(message.channel == 0 && message.index == 2)
      debouncer(:volume, 0.05, message.value*(100.0/127.0)) do |val|
        spawn("osascript -e 'set volume output volume #{val}'")
      end
    end

  end
  join
end
