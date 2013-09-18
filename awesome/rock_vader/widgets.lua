require("awful")
require("beautiful")
require("vicious")
require("mainmenu")
require("freedesktop.utils")
require("freedesktop.menu")
require("volume")
require("mpd")

beautiful.init("~/.config/awesome/theme.lua")

-- MainMenu
mymainmenu = myrc.mainmenu.build()
mylauncher = widget({ type = "textbox" })
mylauncher.text = ' <span color="'..beautiful.fg_focus..'" > MENU</span>'
mylauncher:buttons(awful.util.table.join( awful.button({}, 1, nil, function () mymainmenu:toggle(mainmenu_args) end)))
mainmenu_args = { coords={ x=0, y=0 }, keygrabber = true }
desktopmenu_args = { keygrabber = true }
keymenu_args = { coords={ x=200, y=100 }, keygrabber = true }

-- text color
focus_col = '<span color="'..beautiful.fg_focus..'">'
null_col = '</span>'
colors = {
	black	= '<span color="#202020" >',
	red		= '<span color="#ff6565" >',
	green	= '<span color="#93d44f" >',
	yellow	= '<span color="#eab93d" >',
	blue	= '<span color="#204a87" >',
	magenta	= '<span color="#ce5c00" >',
	cyan	= '<span color="#89b6e2" >',
	white	= '<span color="#cccccc" >',
	null	= '</span>'
}


-- Icon dir
icon_dir = awful.util.getdir("config") .. "/icons/"

-- Start a layoutbox
mylayoutbox = {}

-- Taglist 
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
    awful.button({ }, 1, awful.tag.viewonly),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
    )

-- Clock widget
datewidget = widget({ type = "textbox" })
vicious.register(datewidget, vicious.widgets.date, '<span font="dina 9">'..colors.white..'%a %d %b'..colors.null..'</span>',  10)

--// CPU widget
-- Icon
cpuicon = widget({ type = "imagebox" })
cpuicon.image = image(icon_dir .. "cpu.png")
-- Text
cpuperc = widget({ type = "textbox" })
cpuperc.width = "30"
cpuperc.align = "left"
vicious.register(cpuperc, vicious.widgets.cpu, ' '..colors.red..'$1'..colors.null..' ', 1)

--// Mem Widget
-- Icon
memicon = widget({ type = "imagebox" })
memicon.image = image(icon_dir .. "mem.png")
-- Text
memwidget = widget({ type = "textbox" })
memwidget.align = "left"
vicious.register(memwidget, vicious.widgets.mem, ' '..colors.green..'$1'..colors.null..' $2MB', 17)

--// Battery widget
-- Icon
baticon = widget({ type = "imagebox" })
baticon.image = image(icon_dir .. "bat_full_01.png")
-- Text
batwidget = widget({ type = "textbox" })
batwidget.align = "left"
vicious.register(batwidget, vicious.widgets.bat, ' '..colors.yellow..'$2%'..colors.null..' $1', 23, "BAT0")

--// Temp widget
-- Icon
tempicon = widget({ type = "imagebox" })
tempicon.image = image(icon_dir .. "temp.png")
-- Text
tempwidget1, tempwidget2 = widget({ type = "textbox" }), widget({ type = "textbox" })
tempwidget1.align, tempwidget2.align = "left", "left"
vicious.register(tempwidget1, vicious.widgets.thermal, ' '..colors.blue..'$1'..colors.null..'', 43, "thermal_zone0")
vicious.register(tempwidget2, vicious.widgets.thermal, ' '..colors.blue..'$1'..colors.null..' C', 43, "thermal_zone1")

--/// Net Widget
--neticon = widget({ type = "imagebox" })
netwidget = widget({ type = "textbox" })
netwidget.width = "120"
netwidget.align = "left"
vicious.register(netwidget, vicious.widgets.net, 
    function (widget, args)
        if args["{eth0 carrier}"] == 1 
			then 
--				neticon.image = image(icon_dir .. "/usb.png")
				return ' U '..colors.magenta..args["{eth0 up_kb}"]..colors.null..' D '..colors.magenta..args["{eth0 down_kb}"]..colors.null..''
		elseif args["{wlan0 carrier}"] == 1 
			then 
--				neticon.image = image(icon_dir .. "/wifi_01.png")
				return ' U '..colors.magenta..args["{wlan0 up_kb}"]..colors.null..' D '..colors.magenta..args["{wlan0 down_kb}"]..colors.null..''
	    else 
--			neticon.image = image(icon_dir .. "/empty.png")
			return  'Netwok Disabled '
	   		-- end
		end
    end, 1)
--///

function escape_xml(text)
	xml_entities = {
		["\""]	= "&quot;",
		["&"]	= "&amp;",
		["'"]	= "&apos;",
		["<"]	= "&lt;",
		[">"]	= "&gt;"
	}

	return text and text:gsub("[\"&'<>]", xml_entities)
end

--/// MPD widget ///
-- Inizialize widgets
mpdwidget = widget({ type = "textbox" })
mpdwidget.align = "left"
mpdicon = widget({ type = "imagebox" })
-- Connect to MPD
mpc = mpd:new()
-- Build mpd widget
function widget_mpd(widget, icon)
	local status = mpc:send('status')
	local state = status.state
	local current = mpc:send('currentsong')
	local artist, title, elapsed, totaltime
	local running = true
	
	-- Icon table
	local icon_dir = awful.util.getdir("config").."/icons/"
	local icons = {
		play = icon_dir.."/play.png",
		pause = icon_dir.."/pause.png",
		stop = icon_dir.."/stop.png",
		none = icon_dir.."/empty.png",
		unknow = icon_dir.."/half.png"
	}
	
	-- Get the state and define the icon widget
	if state == "stop" then icon.image = image(icons.stop)
	elseif state == "pause"	then icon.image = image(icons.pause)
	elseif state == "play"	then icon.image = image(icons.play)
	elseif state == nil		then icon.image = image(icons.none)
								 local running = false
	else icon.image = image(icons.unknow)
	end

	-- Get title and artist	
	if running then
		
		-- get artist
		artist = escape_xml(current.artist)
		if artist == nil then artist = "[n/a]" end
		
		-- get title
		title = escape_xml(current.title)
		if title == nil then 
			title = string.gsub(escape_xml(current.file), ".*/", "")
			if title == nil then title = "[n/a]" end
		end
		
		-- get time
		local elapsed, totaltime = status.elapsed, current.time
		if elapsed == nil then elapsed = 0 end
		if totaltime == nil then totaltime = 0 end
		elapsed = string.format("%d:%2.0f", tonumber(elapsed)/60, tonumber(elapsed)%60)
		totaltime = string.format("%d:%2.0f", totaltime/60, totaltime%60)
		if (elapsed == nil) or (totaltime == nil) then elapsed, totaltime = "--", "--" end
		
		-- Put the text in the widget
		widget.text = string.format("%s%s%s - %s [%s%s%s/%s]", colors.cyan, title, colors.null, artist, colors.cyan, elapsed, colors.null, totaltime)
	
	else
		widget.text = ' MPD is closed '
	end

end
-- Start mpd widget
widget_mpd(mpdwidget, mpdicon)
-- Define timer and start it
mpdtimer = timer({ timeout = 2 })
mpdtimer:add_signal("timeout", function() widget_mpd(mpdwidget, mpdicon) end)
mpdtimer:start()

--/// Volume icon ///
volicon = widget({ type = "imagebox" })
volicon.image = image(icon_dir .. "spkr_01.png")

--/// Separator ///
sep = widget({ type = "textbox", align = "center" })
sep.text = '<span color="#404040" > | </span>'

--/// DRAW WIDGETS
for s = 1, screen.count() do
    --// Layoutbox //
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
        awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
        awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end)
	))
    --// Taglist //
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)
    --// I Wibox 
    mywibox = {}
    mywibox[s] = awful.wibox({ position = "top", height = "16", screen = s })
    mywibox[s].widgets = {
        {
            mytaglist[s], sep,
            mpdicon, mpdwidget, 
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s], sep,
        datewidget, sep,
        volumetext, volicon, sep,   
        batwidget, baticon, sep,
        tempwidget2, tempwidget1, tempicon, sep,
	    memwidget, memicon, sep,
        cpuperc, cpuicon, sep, 
        netwidget, --neticon,
        layout = awful.widget.layout.horizontal.rightleft
    }
--	mywibox[s].border_width = "1"
--	mywibox[s].border_color = "#3d5454"
--	mywibox[s].width = "1364"
    --//

end
--///
