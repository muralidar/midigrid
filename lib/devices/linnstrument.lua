-- Linnstrument support file by @nightmachines
-- 2021-05-17
--
-- Thanks to @jaggednz


local prevBuffer1 = {
  {0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0},
}
local prevBuffer2 = {
  {0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0},
}

local device={
  
  width=16,
  height=8,

  vgrid={},
  midi_id = 1,
  refresh_counter = 0,

  brightness_map = {7,1,1,9,9,9,2,2,2,10,10,10,4,4,4,8},
  -- 0=as set in Note Lights settings, 1=red, 2=yellow, 3=green, 4=cyan, 5=blue, 6=magenta, 7=OFF, 8=white, 9= orange, 10=lime and 11=pink

  
  init_device_msg = {}, -- TODO figure out how to send NPRN 245 value 1

  current_quad = 1,

}

function device:_init(vgrid,device_number)
  self.vgrid = vgrid
  self:_reset()
end


function device:_reset()
  if self.init_device_msg then
    midi.devices[self.midi_id]:send(self.init_device_msg)
  else
    --TODO: Reset all leds on device
  end
end

function device._update_led(self,x,y,z)
  if midi.devices[self.midi_id] then
    midi.devices[self.midi_id]:cc(20,x,1) -- row
    midi.devices[self.midi_id]:cc(21,9-y-1,1) -- col
    midi.devices[self.midi_id]:cc(22,self.brightness_map[z+1],1) -- brightness
  end
end

function device.event(self,vgrid,event)

  local midi_msg = midi.to_msg(event)

  -- Debug incomming midi messages
--  print(midi_msg.type)

  if (midi_msg.type == 'note_on' or midi_msg.type == 'note_off') then
    local state = (midi_msg.type == 'note_on') and 1 or 0
    local x = midi_msg.note
    local y = midi_msg.ch
    if key then
      self._key_callback(self.current_quad,x,9-y,state)
    end
  end
end



device._key_callback = function() print('no vgrid event handle callback attached!') end




function device:refresh(quad)
  if quad.id == 1 then
    for x = 1,self.width do
      for y = 1,self.height do
        if x <= 8 then
          if self.vgrid.quads[1].buffer[x][y] ~= prevBuffer1[x][y] then
            self._update_led(self,x,y,self.vgrid.quads[1].buffer[x][y])
            prevBuffer1[x][y] = self.vgrid.quads[1].buffer[x][y]
          end
        else
          if self.vgrid.quads[2].buffer[x-8][y] ~= prevBuffer2[x-8][y] then
            self._update_led(self,x,y,self.vgrid.quads[2].buffer[x-8][y])
            prevBuffer2[x-8][y] = self.vgrid.quads[2].buffer[x-8][y]
          end
        end
      end
    end
  end  
end

return device
