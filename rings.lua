
cpu0 = 0x3b31b6
cpu1 = 0x5b31b6
cpu2 = 0x7b31b6
cpu3 = 0x9b31b6
gpu =  0x1b31b6
cpu_x = 100
cpu_y = 260

temp_x = cpu_x + 95
temp_y = 195
temp_width = 30
temp_sep = 5



settings_table = {
    {
     name='cpu',
     arg='cpu0',
     max=100,
     bg_colour=0xffffff,
     bg_alpha=0.1,
     fg_colour=cpu0,
     fg_alpha=0.6,
     x=cpu_x, y=cpu_y,
     radius=70,
     thickness=10,
     start_angle=140,
     end_angle=450
   },
   {
     name='cpu',
     arg='cpu1',
     max=100,
     bg_colour=0xffffff,
     bg_alpha=0.1,
     fg_colour=cpu1,
     fg_alpha=0.6,
     x=cpu_x, y=cpu_y,
     radius=60,
     thickness=9,
     start_angle=140,
     end_angle=450
   },
   {
     name='cpu',
     arg='cpu2',
     max=100,
     bg_colour=0xffffff,
     bg_alpha=0.1,
     fg_colour=cpu2,
     fg_alpha=0.6,
     x=cpu_x, y=cpu_y,
     radius=50,
     thickness=9,
     start_angle=140,
     end_angle=450
   },
   {
     name='cpu',
     arg='cpu3',
     max=100,
     bg_colour=0xffffff,
     bg_alpha=0.1,
     fg_colour=cpu3,
     fg_alpha=0.6,
     x=cpu_x, y=cpu_y,
     radius=40,
     thickness=9,
     start_angle=140,
     end_angle=450
   }
   ,
   {
     name='exec',
     arg=" nvidia-settings -t -q [gpu:0]/GPUUtilization | awk -F, '{print $1}'|awk -F= '{print $2}'",
     max=100,
     bg_colour=0xffffff,
     bg_alpha=0.1,
     fg_colour=gpu,
     fg_alpha=0.6,
     x=320, y=405,
     radius=40,
     thickness=20,
     start_angle=-90,
     end_angle=180
   }
}


require 'cairo'

function rgb_to_r_g_b(colour,alpha)
  return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
end

function draw_ring(cr,t,pt)
  local w,h=conky_window.width,conky_window.height

  local xc,yc,ring_r,ring_w,sa,ea=pt['x'],pt['y'],pt['radius'],pt['thickness'],pt['start_angle'],pt['end_angle']
  local bgc, bga, fgc, fga=pt['bg_colour'], pt['bg_alpha'], pt['fg_colour'], pt['fg_alpha']

  local angle_0=sa*(2*math.pi/360)-math.pi/2
  local angle_f=ea*(2*math.pi/360)-math.pi/2
  local t_arc=t*(angle_f-angle_0)

  --Draw background ring
  cairo_arc(cr,xc,yc,ring_r,angle_0,angle_f)
  cairo_set_source_rgba(cr,rgb_to_r_g_b(bgc,bga))
  cairo_set_line_width(cr,ring_w)
  cairo_stroke(cr)

  --Draw indicator ring
  cairo_arc(cr,xc,yc,ring_r,angle_0,angle_0+t_arc)
  cairo_set_source_rgba(cr,rgb_to_r_g_b(fgc,fga))
  cairo_stroke(cr)
end

function RoundRect (cr,start_x,start_y,width,height,r,g,b,a)
  x         = start_x
  y         = start_y
  aspect        = 1     
  corner_radius = height / 10.0

  radius = corner_radius / aspect
  degrees = math.pi / 180.0

  cairo_new_sub_path (cr)
  cairo_arc (cr, x + width - radius, y + radius, radius, -90 * degrees, 0 * degrees)
  cairo_arc (cr, x + width - radius, y + height - radius, radius, 0 * degrees, 90 * degrees)
  cairo_arc (cr, x + radius, y + height - radius, radius, 90 * degrees, 180 * degrees)
  cairo_arc (cr, x + radius, y + radius, radius, 180 * degrees, 270 * degrees)
  cairo_close_path (cr)

  cairo_set_source_rgba(cr,r,g,b,a)
  cairo_fill_preserve (cr)
  --cairo_set_source_rgba (cr, 0.5, 0, 0, 0.5)
  --cairo_set_line_width (cr, 0)
  --cairo_stroke (cr)
end

function DrawBars (cr,is_gpu,start_x,start_y,bar_width,bar_height,corenum,r,g,b)
  -- set colour (r,g,b,alpha)
  cairo_set_source_rgba(cr,1,1,1,0.1)
  RoundRect (cr,start_x,start_y,bar_width,bar_height,1,1,1,0.1)
  cairo_fill(cr)
  cairo_set_source_rgba(cr,r,g,b,a)
  if(is_gpu == 1) then
    value = tonumber(conky_parse("${exec nvidia-settings -t -q [gpu:0]/GPUCoreTemp}"))
  else
    value = tonumber(conky_parse(string.format("${exec sensors | grep -o 'Core %s:        +[0-9].' | sed -r 's/%s:|[^0-9]//g'}",corenum,corenum)))
  end
  -- IF TEMP BARS DO NOT SHOW, try commenting the line above with '--' and uncommenting the line below by removing '--'. (Thanks to /u/IAmAFedora)
  --value = tonumber(conky_parse(string.format("${exec sensors | grep -o 'Core %s:         +[0-9].' | sed -r 's/%s:|[^0-9]//g'}",corenum,corenum)))
  max_value=100
  scale=bar_height/max_value
  indicator_height=scale*value
  RoundRect (cr,start_x,start_y+bar_height-indicator_height,bar_width,indicator_height,r,g,b,0.1)
  cairo_fill (cr)
end


function conky_rings()
    local function setup_rings(cr,pt)
        local str=''
        local value=0
        
        str=string.format('${%s %s}',pt['name'],pt['arg'])
        str=conky_parse(str)
        
        value=tonumber(str)
        pct=value/pt['max']
        
        draw_ring(cr,pct,pt)
    end

  --Check that Conky has been running for at least 5s
  if conky_window==nil then return end
  local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual, conky_window.width,conky_window.height)

  local cr=cairo_create(cs)

  local updates=conky_parse('${updates}')
  update_num=tonumber(updates)

    for i in pairs(settings_table) do
      setup_rings(cr,settings_table[i])
    end
  --draw cpu temp bars
  DrawBars(cr,false,temp_x                        ,temp_y,temp_width,120,0,rgb_to_r_g_b(0xffffff))
  DrawBars(cr,false,temp_x+1*(temp_sep+temp_width),temp_y,temp_width,120,1,rgb_to_r_g_b(0xffffff))
  DrawBars(cr,false,temp_x+2*(temp_sep+temp_width),temp_y,temp_width,120,2,rgb_to_r_g_b(0xffffff))
  DrawBars(cr,false,temp_x+3*(temp_sep+temp_width),temp_y,temp_width,120,3,rgb_to_r_g_b(0xffffff))
  -- gpu tem[]
  --DrawBars(cr,true,390,390,temp_width,120,0,rgb_to_r_g_b(0xffffff))
end