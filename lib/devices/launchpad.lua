local launchpad = include('midigrid/lib/devices/generic_device')

launchpad.grid_notes= {
  {  0,  1,  2,  3,  4,  5,  6,  7 },
  { 16, 17, 18, 19, 20, 21, 22, 23 },
  { 32, 33, 34, 35, 36, 37, 38, 39 },
  { 48, 49, 50, 51, 52, 53, 54, 55 },
  { 64, 65, 66, 67, 68, 69, 70, 71 },
  { 80, 81, 82, 83, 84, 85, 86, 87 },
  { 96, 97, 98, 99,100,101,102,103 },
  {112,113,114,115,116,117,118,119 }
}

-- Originally set the grid width to match the 9 columns of the launchpad (right column is A-H aux column)
--launchpad.width = 9

--[[ Valid Launchpad colours based on bits 0..1 Red, 4..5 Green
id  color 
0, 16, 32, 48 - Full Green
1, 17, 33, 49 
2, 18, 34, 50
3, 19, 35, 51 - Full Orange
]]--
-- Tropical
launchpad.brightness_map = {0,16,16,32,32,48,48,49,49,33,33,50,50,34,34,51}
-- Sunrise
--launchpad.brightness_map = {0,16,16,32,32,48,48,49,49,50,50,33,33,51,2,3}
-- Rainbow
--launchpad.brightness_map = {0, 16, 32, 48, 1, 17, 33, 49, 2, 18, 34, 50, 3, 19, 35, 51}

launchpad.reset_device_msg = { 0xB0, 0x00, 0x00 }

launchpad.aux = {}
--top to bottom
launchpad.aux.col = {
  {'note',   8, 1},
  {'note',  24, 2},
  {'note',  40, 3},
  {'note',  56, 4},
  {'note',  72, 10},
  {'note',  88, 12},
  {'note', 104, 14},
  {'note', 120, 16}
}
--left to right
launchpad.aux.row = {
  {'CC',   104, 1},
  {'CC',   105, 2},
  {'CC',   106, 3},
  {'CC',   107, 4},
  {'CC',   108, 5},
  {'CC',   109, 6},
  {'CC',   110, 7},
  {'CC',   111, 8}
}

launchpad.cc_event_handlers = {}

-- "Arrow buttons"
launchpad.quad_leds = {CC = {104,105,106,107}}
launchpad.cc_event_handlers[104] = function(self,val) self:change_quad(1) end
launchpad.cc_event_handlers[105] = function(self,val) self:change_quad(2) end
launchpad.cc_event_handlers[106] = function(self,val) self:change_quad(3) end
launchpad.cc_event_handlers[107] = function(self,val) self:change_quad(4) end

function launchpad:cc_handler(vgrid,midi_msg)
  if self.cc_event_handlers[midi_msg.cc] then
    self.cc_event_handlers[midi_msg.cc](self,midi_msg.val)
  else
    print('Unhandled CC '.. midi_msg.cc)
  end
end

return launchpad