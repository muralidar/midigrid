-- mods on the generic device for Push 2
local push = include('midigrid/lib/devices/generic_device')

print('loading push')

-- mapping for Push's main pads
push.grid_notes = {
      {92, 93, 94, 95, 96, 97, 97, 99},
      {84, 85, 86, 97, 88, 89, 90, 91},
      {76, 77, 78, 79, 80, 81, 82, 83},
      {68, 69, 70, 71, 72, 73, 74, 75},
      {60, 61, 62, 63, 64, 65, 66, 67},
      {52, 53, 54, 55, 56, 57, 58, 59},
      {44, 45, 46, 47, 48, 49, 50, 51},
      {36, 37, 38, 39, 40, 41, 42, 43}
}

-- probably want to change these as I've not thought to much about them at this point :-)
push.brightness_map = {0,11,11,9,9,9,13,13,51,51,51,49,49,59,59,57}


push.auxcol = {102,103,104,105,106,107,108,109}
push.auxrow = {20,21,22,23,24,25,26,27}

-- no pads to control quad
push.quad_leds = {notes = nil}

-- todo: add CCs for controlling quads?
-- push.quad_leds = {CC = {}}

-- todo decide what to do here as we have a lot of buttons
push.cc_event_handlers = {}
push.cc_event_handlers[20] = function(self,val)  self:change_quad(1) end
push.cc_event_handlers[21] = function(self,val)  self:change_quad(2) end
push.cc_event_handlers[22] = function(self,val)  self:change_quad(3) end
push.cc_event_handlers[23] = function(self,val)  self:change_quad(4) end

function push:cc_handler(vgrid,midi_msg)
      if self.cc_event_handlers[midi_msg.cc] then
            self.cc_event_handlers[midi_msg.cc](self,midi_msg.val)
      else
            print('Unhandled CC '.. midi_msg.cc)
      end
end

return push
