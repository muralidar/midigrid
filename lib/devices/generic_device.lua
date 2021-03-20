local device={
  --here we have the 'grid' this looks literally like the grid notes as they are mapped on the apc, they can be changed for other devices
  --note though, that a call to this table will look backwards, i.e, to get the visual x=1 and y=2, you have to enter midigrid[2][1], not the other way around!
  grid_notes= {
    {56,57,58,59,60,61,62,63},
    {48,49,50,51,52,53,54,55},
    {40,41,42,43,44,45,46,47},
    {32,33,34,35,36,37,38,39},
    {24,25,26,27,28,29,30,31},
    {16,17,18,19,20,21,22,23},
    { 8, 9,10,11,12,13,14,15},
    { 0, 1, 2, 3, 4, 5, 6, 7}
  },
  note_to_grid_lookup = {}, -- Intentionally left empty
  width=8,
  height=8,

  vgrid={},
  midi_id = 1,
  refresh_counter = 0,

  -- This MUST contain 15 values that corospond to brightness. these can be strings or tables if you midi send handler requires (e.g. RGB)
  brightness_map = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15},

  -- This defines any Aux buttons, it expects at least one row and one column of 8 buttons
  -- See launchpad.lua for an example. More than 8 buttons could be used for multple row/cols (i.e. LP Mk3 Pro)
  -- Format is { 'cc'/'note', cc or note number, current/default state }
  aux = {
    col = {},
    row = {}
  },
  
  --as of now, order is important here
  quad_leds = {notes = {64,65,66,67}},

  -- the currently displayed quad on the device
  quad_switching_enabled = true,
  current_quad = 1,
  -- here we set the buttons to use when switching quads in multi-quad mode

  force_full_refresh = false,

  device_name = 'generic'
}

--function expects grid brightness from 0-15 and converts in so your midi controller can understand,
-- these values need to be adjusted for your controller!
function device:brightness_handler(val)
  -- remember tables start at 1, but brightness starts at 0
  return self.brightness_map[val+1]
end

function device:change_quad(quad)
    self.current_quad = quad
    self.force_full_refresh = true
end

function device:_reset()
  if self.reset_device_msg then
    midi.devices[self.midi_id]:send(self.reset_device_msg)
  else
    --TODO: Reset all leds on device
  end
end

function device:_init(vgrid)
  self.vgrid = vgrid
  
  self.aux.row.handlers = {}
  self.aux.col.handlers = {}
  
  if #vgrid.quads > 1 then
    for q = 1,#vgrid.quads do
      self.aux.row.handlers[q] = function(self,val) self:change_quad(q) end
    end
  end
  
  self:_reset()
end

function device._update_led(self,x,y,z)
  local vel = self.brightness_map[z+1]
  local note = self.grid_notes[y][x]
  local midi_msg = {0x90,note,vel}
  --TODO: do we accept a few error msg on failed unmount and check device status in :refresh
  if midi.devices[self.midi_id] then midi.devices[self.midi_id]:send(midi_msg) end
end

function device.event(self,vgrid,event)
  -- type="note_on", note, vel, ch
  -- Note that midi msg already translates note on vel 0 to note off type
  local midi_msg = midi.to_msg(event)

  -- Debug incomming midi messages
  -- tab.print(midi_msg)

  -- device-dependent. Reject cc "notes" here.
  if (midi_msg.type == 'note_on' or midi_msg.type == 'note_off') then
    local key = self.note_to_grid_lookup[midi_msg.note]
    local key_state = (midi_msg.type == 'note_on') and 1 or 0
    if key then
      self._key_callback(self.current_quad,key['x'],key['y'],key_state)
    else
      self:_aux_btn_handler('note',midi_msg.note,key_state)
    end
  elseif (midi_msg.type == 'cc') then
    self:_aux_btn_handler('cc',midi_msg.cc,(midi_msg.val>0) and 1 or 0)
  end
end

device._key_callback = function() print('no vgrid event handle callback attached!') end

function device:refresh(quad)
  if quad.id == self.current_quad then
    if self.refresh_counter > 9 then
      self.force_full_refresh = true
      self.refresh_counter = 0
    end
    if self.force_full_refresh then
      quad.each_with(quad,self,self._update_led)
      self.force_full_refresh = false
    else
      quad.updates_with(quad,self,self._update_led)
      self.refresh_counter=self.refresh_counter+1
    end
  end
  self:update_aux()
end

function device:_aux_btn_handler(type, msg, state)
  local aux_event
  if type == 'cc' then
    aux_event = self.aux.cc_lookup[msg]
  else
    aux_event = self.aux.note_lookup[msg]
  end
  
  if aux_event and aux_event[1] == 'row' then
    device:aux_row_handler(aux_event[2], state)
  elseif aux_event and aux_event[1] == 'col' then
    device:aux_col_handler(aux_event[2], state)
  else
    print 'Unrecognised Aux button event'
  end
end

function device:aux_row_handler(btn,val)
  if (self.aux and self.aux.row and self.aux.row.handlers and self.aux.row.handlers[btn]) then
    self.aux.row.handlers[btn](self,val)
  end
end

function device:aux_col_handler(btn,val)
  if (self.aux and self.aux.col and self.aux.col.handlers and self.aux.col.handlers[btn]) then
    self.aux.col.handlers[btn](self,val)
  end
end

function device:update_aux()
  -- TODO would be good to only update on dirty AUX?
  if self.vgrid and #self.vgrid.quads > 1 and self.quad_switching_enabled == true then
    for q = 1,#self.vgrid.quads do
      if self.current_quad == q then z = 16 else z = 2 end
      if self.aux.row and #self.aux.row >= 4 then
        self.aux.row[q][3] = z
      end
    end
  end
  -- Light the Aux LEDs
  if self.aux.row then
    for _,button in ipairs(self.aux.row) do
      if button[1] == 'cc' then
        self:_send_cc(button[2],button[3])
      else
        self:_send_note(button[2],button[3])
      end
    end
  end
  if self.aux.col then
    for _,button in ipairs(self.aux.col) do
      if button[1] == 'cc' then
        self:_send_cc(button[2],button[3])
      else
        self:_send_note(button[2],button[3])
      end
    end
  end
end

function device:_send_note(note,z)
  local vel = self.brightness_map[z]
  local midi_msg = {0x90,note,vel}
  if midi.devices[self.midi_id] then midi.devices[self.midi_id]:send(midi_msg) end
end

function device:_send_cc(cc,z)
  local vel = self.brightness_map[z]
  local midi_msg = {0xb0,cc,vel}
  if midi.devices[self.midi_id] then midi.devices[self.midi_id]:send(midi_msg) end
end

function device:create_rev_lookups()
  --Create reverse lookup for grid notes
  for col = 1,self.height do
    for row = 1,self.width do
      self.note_to_grid_lookup[self.grid_notes[col][row]] = {x=row,y=col}
    end
  end
  
  --Create reverse lookup for aux col and row
  if self.aux and self.aux.cc_lookup == nil then self.aux.cc_lookup = {} end
  if self.aux and self.aux.note_lookup == nil then self.aux.note_lookup = {} end  
  if self.aux.row then
    for btn_number,btn_meta in ipairs(self.aux.row) do
      if btn_meta[1] == 'cc' then
        self.aux.cc_lookup[btn_meta[2]] = {'row', btn_number}
      else
        self.aux.note_lookup[btn_meta[2]] = {'row', btn_number}
      end
    end
  end
  if self.aux.col then
    for btn_number,btn_meta in ipairs(self.aux.col) do
      if btn_meta[1] == 'cc' then
        self.aux.cc_lookup[btn_meta[2]] = {'col', btn_number}
      else
        self.aux.note_lookup[btn_meta[2]] = {'col', btn_number}
      end
    end
  end
end

return device
