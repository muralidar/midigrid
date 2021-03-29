local context={}

function ctx_change_edit_ch(ch)
  edit_ch = ch
  if edit_ch == 2 and edit_pos > two.length then edit_pos = two.length end
  if edit_ch == 1 and edit_pos > one.length then edit_pos = one.length end
  return edit_ch
end

function ctx_change_mode(new_mode)
  mode = new_mode
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
    tab.print(device.aux)
    device.aux.col_handlers[1] = function(self,val)
      local selected_channel
      --if val == 127 then _ENV.key(2,1) end
      if val == 1 then ctx_change_edit_ch(1) end
    end
    device.aux.col_handlers[2] = function(self,val)
      --if val == 127 then _ENV.key(2,1) end
      if val == 1 then ctx_change_edit_ch(2) end
    end
    
    device.aux.col_handlers[5] = function(self,val) if val == 1 then ctx_change_mode(1) end end
    device.aux.col_handlers[6] = function(self,val) if val == 1 then ctx_change_mode(2) end end
    device.aux.col_handlers[7] = function(self,val) if val == 1 then ctx_change_mode(3) end end
    device.aux.col_handlers[8] = function(self,val) if val == 1 then ctx_change_mode(4) end end
  end
end

return context