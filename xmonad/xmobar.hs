-- xmobar config used by Vic Fryzel
-- Author: Vic Fryzel
-- http://github.com/vicfryzel/xmonad-config

-- This is setup for dual 1920x1080 monitors, with the right monitor as primary
Config {
    font = "xft:Fixed-8",
--    font = "xft:Bitstream Vera Sans Mono:size=8:bold:antialias=true",
    bgColor = "#000000",
    fgColor = "#ffffff",
--    position = Static { xpos = 0, ypos = 0, width = 0, height = 16 },
--    border = BottomB,
--    borderColor = "grey",
    lowerOnStart = False
    commands = [
        Run Weather "EDLW" ["-t","<tempC>C","-L","64","-H","77","-n","#CEFFAC","-h","#FFB6B0","-l","#96CBFE"] 36000,
--        Run MultiCpu ["-t","Cpu: <total0><total1><total2><total3>","-L","30","-H","60","-h","#FFB6B0","-l","#CEFFAC","-n","#FFFFCC","-w","3"] 10,
	Run Cpu ["-t", "Cpu: <total>%", "-L","30","-H","60","-h","#FFB6B0","-l","#CEFFAC","-n","#FFFFCC","-w","3"] 10,
        Run Memory ["-t","Mem: <usedratio>%","-H","8192","-L","4096","-h","#FFB6B0","-l","#CEFFAC","-n","#FFFFCC"] 10,
--        Run Swap ["-t","Swap: <usedratio>%","-H","1024","-L","512","-h","#FFB6B0","-l","#CEFFAC","-n","#FFFFCC"] 10,
        Run Network "eth0" ["-t","<dev>: <rx>, <tx>","-H","200","-L","10","-h","#FFB6B0","-l","#CEFFAC","-n","#FFFFCC"] 10,
        Run Date "%H:%M" "date" 10,
	Run ThermalZone 0 ["-t","0: <temp>C"] 30,
--        Run Com "sh" ["~/bin/mpc_title.sh"] "mpc" 10,
	Run Com "uname" ["-r", "-n"] "" 0,
--	Run MPD ["-t", "<state>: <artist> - <track>"] 10, --requires xmobar-git with haskell-libmpd
	Run StdinReader

    ],
    sepChar = "%",
    alignSep = "}{",
    template = "%StdinReader% }{ %cpu%  %memory%  %eth0% %EDLW% %uname% <fc=#FFFFCC>%date%</fc>"
}
