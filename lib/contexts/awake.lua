local context={}

function ctx_change_edit_ch(ch)
  edit_ch = ch
  if edit_ch == 2 and edit_pos > two.length then edit_pos = two.length end
  if edit_ch == 1 and edit_pos > one.length then edit_pos = one.length end
  return edit_ch
end

function update_device_leds(devices)
  for _, device in pairs(devices) do
    device:_send_cc(110, (edit_ch==1 and 16 or 1))
    device:_send_cc(111, (edit_ch==2 and 16 or 1))
  end
end

function context.start(devices)
  print("from context")
  for _, device in pairs(devices) do
    device.cc_event_handlers[111] = function(self,val)
      local selected_channel
      --if val == 127 then _ENV.key(2,1) end
      if val == 127 then ctx_change_edit_ch(2) end
      update_device_leds(devices)
    end
    device.cc_event_handlers[110] = function(self,val)
      --if val == 127 then _ENV.key(2,1) end
      if val == 127 then ctx_change_edit_ch(1) end
      update_device_leds(devices)
    end
  end
end

return context