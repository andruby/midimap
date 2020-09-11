require "micromidi"
require "debouncer"

input = UniMIDI::Input.gets

def set_brightness(value)
  @brightness_debouncer ||= Debouncer.new(0.1) do |val|
    spawn("./ddcctl -d 1 -b #{val}")
  end
  @brightness_debouncer.call(value)
end

MIDI.using(input) do
  receive :control_change do |message|
    puts "--"
    puts message.inspect

    if(message.channel == 0 && message.index == 14)
      set_brightness(message.value)
    end

    if(message.channel == 0 && message.index == 15)
      spawn("osascript -e 'set volume output volume #{message.value}'")
    end

  end
  join
end
