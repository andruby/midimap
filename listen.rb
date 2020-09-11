require "micromidi"
require "debouncer"

DDCCTL_BIN = "./ddcctl"
DISPLAY_NUMBER = 1
MIDI_CHANNEL = 0
MIDI_INDEX = 14

input = UniMIDI::Input.gets

def set_brightness(value)
  @brightness_debouncer ||= Debouncer.new(0.1) do |val|
    puts "Changing screen brightness: #{val}"
    spawn("#{DDCCTL_BIN} -d #{DISPLAY_NUMBER} -b #{val}")
  end
  @brightness_debouncer.call(value)
end

MIDI.using(input) do
  receive :control_change do |message|
    puts "--"
    puts message.inspect
    if(message.channel == MIDI_CHANNEL && message.index == MIDI_INDEX)
      set_brightness(message.value)
    end
  end
  join
end
