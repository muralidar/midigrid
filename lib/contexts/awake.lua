local context={
  prev_mode = nil
  peeking_at = nil
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
  if peek then
    context.prev_mode = mode
    ctx_set_peek_aux_row(new_mode)
    mode = new_mode
  else
    mode = context.prev_mode
    ctx_restore_default_aux_row()
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
    device.aux.col_handlers[5] = function(self,val) then ctx_peek_mode(1,val) end
    device.aux.col_handlers[6] = function(self,val) then ctx_peek_mode(1,val) end
    device.aux.col_handlers[7] = function(self,val) then ctx_peek_mode(1,val) end
    device.aux.col_handlers[8] = function(self,val) then ctx_peek_mode(1,val) end
    --save default aux row behavior for post peek mode restore
    context.default_aux_handlers[device.device_number] = device.aux.row_handlers

  end
end

return context
