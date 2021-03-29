local launchpad = include('midigrid/lib/devices/generic_device')

launchpad.grid_notes= {
  {81,82,83,84,85,86,87,88},
  {71,72,73,74,75,76,77,78},
  {61,62,63,64,65,66,67,68},
  {51,52,53,54,55,56,57,58},
  {41,42,43,44,45,46,47,48},
  {31,32,33,34,35,36,37,38},
  {21,22,23,24,25,26,27,28},
  {11,12,13,14,15,16,17,18}
}

launchpad.brightness_map = {
  0,
  11,
  100,
  125,
  83,
  117,
  14,
  62,
  99,
  118,
  126,
  97,
  109,
  13,
  12,
  119
}

launchpad.aux = {}

-- Format is { 'cc'/'note', cc or note number, current/default state (1-16) }
--top to bottom

--these are LP keys to the sides of our grid
--not necessary for strict grid emulation but handy!
--they are up to down, so 89 is the auxkey to row 1
launchpad.aux.col = {
  {'note', 89, 0},
  {'note', 79, 0},
  {'note', 69, 0},
  {'note', 59, 0},
  {'note', 49, 0},
  {'note', 39, 0},
  {'note', 29, 0},
  {'note', 19, 0}
}
--left to right, 91 is aux key to column 1
launchpad.aux.row = {
  {'note', 91, 0},
  {'note', 92, 0},
  {'note', 93, 0},
  {'note', 94, 0},
  {'note', 95, 0},
  {'note', 96, 0},
  {'note', 97, 0},
  {'note', 98, 0}
}

return launchpad
