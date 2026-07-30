local M = {}

M.boolean = {
  { { 'true',    'false'    }, true },
  { { 'yes',     'no'       }, true },
  { { 'on',      'off'      }, true },
  { { 'enable',  'disable'  }, true },
  { { 'enabled', 'disabled' }, true },
}

M.weekdays = {
  {
    {
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    },
    true,
  },
  {
    {
      'mon',
      'tue',
      'wed',
      'thu',
      'fri',
      'sat',
      'sun',
    },
    true,
  },
}

M.months = {
  {
    {
      'january',
      'february',
      'march',
      'april',
      'may',
      'june',
      'july',
      'august',
      'september',
      'october',
      'november',
      'december',
    },
    true,
  },
}

M.colors = {
  {
    {
      'red',
      'orange',
      'yellow',
      'green',
      'blue',
      'indigo',
      'violet',
    },
  },

  {
    {
      'White',
      'Snow',
      'Ivory',
      'Linen',
      'AntiqueWhite',
      'Beige',
      'WhiteSmoke',
      'LavenderBlush',
      'OldLace',
      'AliceBlue',
      'SeaShell',
      'GhostWhite',
      'Honeydew',
      'FloralWhite',
      'Azure',
      'MintCream',
    },
  },

  {
    {
      'Black',
      'DarkSlateGray',
      'DimGray',
      'SlateGray',
      'Gray',
      'LightSlateGray',
      'Silver',
      'LightGray',
      'Gainsboro',
    },
  },

  {
    {
      'Pink',
      'LightPink',
      'HotPink',
      'PaleVioletRed',
      'DeepPink',
      'MediumVioletRed',
    },
  },

  {
    {
      'Indigo',
      'Purple',
      'DarkMagenta',
      'DarkViolet',
      'DarkSlateBlue',
      'BlueViolet',
      'DarkOrchid',
      'Fuchsia',
      'Magenta',
      'SlateBlue',
      'MediumSlateBlue',
      'MediumOrchid',
      'MediumPurple',
      'Orchid',
      'Violet',
      'Plum',
      'Thistle',
      'Lavender',
    },
  },

  {
    {
      'DarkRed',
      'Red',
      'Firebrick',
      'Crimson',
      'IndianRed',
      'LightCoral',
      'Salmon',
      'DarkSalmon',
      'LightSalmon',
    },
  },

  {
    {
      'OrangeRed',
      'Tomato',
      'DarkOrange',
      'Coral',
      'Orange',
    },
  },

  {
    {
      'DarkKhaki',
      'Gold',
      'Khaki',
      'PeachPuff',
      'Yellow',
      'PaleGoldenRod',
      'Moccasin',
      'PapayaWhip',
      'LightGoldenRodYellow',
      'LemonChiffon',
      'LightYellow',
    },
  },

  {
    {
      'MidnightBlue',
      'Navy',
      'DarkBlue',
      'MediumBlue',
      'Blue',
      'RoyalBlue',
      'SteelBlue',
      'DodgerBlue',
      'DeepSkyBlue',
      'CornflowerBlue',
      'SkyBlue',
      'LightSkyBlue',
      'LightSteelBlue',
      'LightBlue',
      'PowderBlue',
    },
  },

  {
    {
      'Maroon',
      'Brown',
      'SaddleBrown',
      'Sienna',
      'Chocolate',
      'DarkGoldenRod',
      'Peru',
      'RosyBrown',
      'GoldenRod',
      'SandyBrown',
      'Tan',
      'BurlyWood',
      'Wheat',
      'NavajoWhite',
      'Bisque',
      'BlanchedAlmond',
      'Cornsilk',
    },
  },

  {
    {
      'Teal',
      'DarkCyan',
      'LightSeaGreen',
      'CadetBlue',
      'DarkTurquoise',
      'MediumTurquoise',
      'Turquoise',
      'Aqua',
      'Cyan',
      'Aquamarine',
      'PaleTurquoise',
      'LightCyan',
    },
  },

  {
    {
      'DarkGreen',
      'Green',
      'DarkOliveGreen',
      'ForestGreen',
      'SeaGreen',
      'Olive',
      'OliveDrab',
      'MediumSeaGreen',
      'LimeGreen',
      'Lime',
      'SpringGreen',
      'MediumSpringGreen',
      'DarkSeaGreen',
      'MediumAquamarine',
      'YellowGreen',
      'LawnGreen',
      'Chartreuse',
      'LightGreen',
      'GreenYellow',
      'PaleGreen',
    },
  },
}

return M
