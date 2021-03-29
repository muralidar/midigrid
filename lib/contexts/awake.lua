local context={}

function ctx_change_edit_ch(ch)
  edit_ch = ch
  if edit_ch == 2 and edit_pos > two.length then edit_pos = two.length end
  if edit_ch == 1 and edit_pos > one.length then edit_pos = one.length end
  return edit_ch
end

function context.update(device)
  -- Update edit channel 
  device:aux_col_led(1,(edit_ch==1 and 15 or 1))
  device:aux_col_led(2,(edit_ch==2 and 15 or 1))
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
  end
end

return context