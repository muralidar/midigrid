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

push.aux = {}
-- Format is { 'cc'/'note', cc or note number, current/default state (1-16) }
--top to bottom
push.aux.col = {
  {'note', 102, 0},
  {'note', 103, 0},
  {'note', 104, 0},
  {'note', 105, 0},
  {'note', 106, 0},
  {'note', 107, 0},
  {'note', 108, 0},
  {'note', 109, 0}
}
--left to right
push.aux.row = {
  {'note', 20, 0},
  {'note', 21, 0},
  {'note', 22, 0},
  {'note', 23, 0},
  {'note', 24, 0},
  {'note', 25, 0},
  {'note', 26, 0},
  {'note', 27, 0}
}

return push
