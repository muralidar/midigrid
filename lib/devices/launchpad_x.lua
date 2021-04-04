local launchpad = include('midigrid/lib/devices/launchpad_rgb')

--Put the device into programmers mode
launchpad.init_device_msg = { 0xf0,0x0,0x20,0x29,0x02,0x0D,0x00,0x7F,0xf7 }

return launchpad