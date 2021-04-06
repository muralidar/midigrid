local context={
  prev_mode = 1,
  peeking_mode = nil,
  default_aux_handlers = {}
}

-- These functions are declared in "Global" script scope so they can
-- modify script varibles without issue.
-- Namespaced by adding the ctx_ prefix avoids overriding any original script
-- functions.

function ctx_change_edit_ch(ch)
  edit_ch = ch
  if edit_ch == 2 and edit_pos > two.length then edit_pos = two.length end
  if edit_ch == 1 and edit_pos > one.length then edit_pos = one.length end
  return edit_ch
end

function ctx_change_mode(new_mode)
  mode = new_mode
end

function ctx_peek_at_mode(new_mode,peek)
  if peek==1 then
    context.prev_mode = mode
    ctx_set_peek_aux_row(new_mode)
    context.peeking_mode = new_mode
    mode = new_mode
  else
    mode = context.prev_mode
    ctx_restore_default_aux_row()
    context.peeking_mode = nil
  end
end

function ctx_aux_row_handler(button,val,device_number)
   if context.peeking_mode == 1 and val == 1 then
     new_pos = button-1
     if edit_ch == 1 and new_pos <= one.length then one.pos = new_pos end
     if edit_ch == 2 and new_pos <= two.length then two.pos = new_pos end
   elseif context.peeking_mode == 2 and val == 1 then
     new_length = button
     
     if edit_ch == 1 then 
       one.length = new_length
       if edit_pos > one.length then edit_pos = one.length end
     end
     
     if edit_ch == 2 then 
       two.length = new_length
       if edit_pos > two.length then edit_pos = two.length end
     end
     
   elseif context.peeking_mode == 3 and val == 1 then
     new_cutoff = button * 100
     params:set(snd_params[1],new_cutoff)
   elseif context.peeking_mode == 4 and val == 1 then
   end
   
end

function ctx_set_peek_aux_row(mode)

end

function ctx_restore_default_aux_row()

end

function context.update(device)
  -- Update edit channel
  device:aux_col_led(1,(edit_ch==1 and 15 or 1))
  device:aux_col_led(2,(edit_ch==2 and 15 or 1))

  --Update mode
  device:aux_col_led(5,(mode==1 and 15 or 1))
  device:aux_col_led(6,(mode==2 and 15 or 1))
  device:aux_col_led(7,(mode==3 and 15 or 1))
  device:aux_col_led(8,(mode==4 and 15 or 1))
end

function context.start(devices)
  for _, device in pairs(devices) do
    -- Set new column handlers

    -- Easy track/channel switching top two aux column buttons
    device.aux.col_handlers[1] = function(self,val)
      if val == 1 then ctx_change_edit_ch(1) end
    end
    device.aux.col_handlers[2] = function(self,val)
      if val == 1 then ctx_change_edit_ch(2) end
    end

    -- Bottom 4 aux column buttons, sswitch pages / mode

    --[[ Simple mode switching, same as turning encoder
    device.aux.col_handlers[5] = function(self,val) if val == 1 then ctx_change_mode(1) end end
    device.aux.col_handlers[6] = function(self,val) if val == 1 then ctx_change_mode(2) end end
    device.aux.col_handlers[7] = function(self,val) if val == 1 then ctx_change_mode(3) end end
    device.aux.col_handlers[8] = function(self,val) if val == 1 then ctx_change_mode(4) end end
    ]]
    --[[ Advanced mode "peeking", shows that page/mode while the button is held ]]
    device.aux.col_handlers[5] = function(self,val) ctx_peek_at_mode(1,val) end
    device.aux.col_handlers[6] = function(self,val) ctx_peek_at_mode(2,val) end
    device.aux.col_handlers[7] = function(self,val) ctx_peek_at_mode(3,val) end
    device.aux.col_handlers[8] = function(self,val) ctx_peek_at_mode(4,val) end
    --save default aux row behavior for post peek mode restore
    context.default_aux_handlers[device.device_number] = device.aux.row_handlers
    
    for row_btn = 1,8 do
      device.aux.row_handlers[row_btn] = function(self,val) 
        ctx_aux_row_handler(row_btn+((self.current_quad-1)*8),val,self.device_number) 
      end
    end
    

  end
end

return context
