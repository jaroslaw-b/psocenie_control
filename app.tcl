package require Tk

global DEBUG
global temps

set temps(1) 11
set temps(2) 22
set temps(3) 55
set temps(4) 99
set temps(5) 99

set temps(c1) red
set temps(c2) white
set temps(c3) white
set temps(c4) white
set temps(c5) white

set temps_pos_list [list]
set cfg [open cfg.ini]
set cfg_file [read $cfg]
global data
set data [split $cfg_file "\n"]


puts $temps_pos_list
global current_power
set current_power 2137

global cost
global energy
global cost_d
global energy_d
set cost 0
set energy 0

global counting_flag
set counting_flag 0

global phases
set phases(1) 0
set phases(2) 0
set phases(3) 0

global _cfg
set _cfg(type) 0


option add *Entry.relief sunken
bind . <KeyPress-Escape> {
  exit
}

bind . <KeyPress-c> {
	console show
}

proc drawGUI {} {
	global data
	global temps cost energy
	global cost
	global energy
	global cost_d
	global energy_d
	global phases
	frame .c
	labelframe .c.temps -width 400 -text "Odczyt temperatur"
	labelframe .c.power -width 400 -text "Kontrola mocy" -height 700
	labelframe .c.control -width 400 -text "Kontrola programu"
	canvas .c.temps.column_schema -height 700 -width 400

	font create temps_font -family Arial -size 16 -weight bold

	label .c.temps.column_schema.t1 -textvar temps(1) -wraplength 100 -borderwidth 2 -font temps_font
	label .c.temps.column_schema.t2 -textvar temps(2) -width 50 -borderwidth 2 -font temps_font
	label .c.temps.column_schema.t3 -textvar temps(3) -width 50 -borderwidth 2 -font temps_font
	label .c.temps.column_schema.t4 -textvar temps(4) -width 50 -borderwidth 2 -font temps_font

	grid .c -column 0 -row 0
	grid .c.power -column 1 -row 0
	grid .c.temps -column 0 -row 0 -rowspan 3
	grid .c.control -column 2 -row 0

	set myImage [image create photo -file kolumna_schemat.png]

	
	.c.temps.column_schema create image 200 350 -image $myImage 
	.c.temps.column_schema create window [lindex $data 0] -window .c.temps.column_schema.t1 -width 30
	.c.temps.column_schema create window [lindex $data 1] -window .c.temps.column_schema.t2 -width 30
	.c.temps.column_schema create window [lindex $data 2] -window .c.temps.column_schema.t3 -width 30
	.c.temps.column_schema create window [lindex $data 3] -window .c.temps.column_schema.t4 -width 30

	grid .c.temps.column_schema -column 0 -row 0

	font create control_power_button -family Arial -size 12 -weight bold
	button .c.power.full_power -text "Ca³a naprzód!" -command [list setpower + 10000] -width 20 -height 2 -background red -font control_power_button
	button .c.power.plus100 -text "+100" -command [list setpower + 100] -width 20 -height 2 -background red -font control_power_button
	button .c.power.plus10 -text "+10" -command [list setpower + 10] -width 20 -height 2 -background red -font control_power_button
	button .c.power.plus1 -text "+1" -command [list setpower + 1] -width 20 -height 2 -background red -font control_power_button
	entry .c.power.cur_power -textvariable current_power -width 20
	button .c.power.minus1 -text "-1" -command [list setpower - 1] -width 20 -height 2 -background cyan -font control_power_button
	button .c.power.minus10 -text "-10" -command [list setpower - 10] -width 20 -height 2 -background cyan -font control_power_button
	button .c.power.minus100 -text "-100" -command [list setpower - 100] -width 20 -height 2 -background cyan -font control_power_button
	button .c.power.no_power -text "Koniec psot!" -command [list setpower - 10000] -width 20 -height 2 -background cyan -font control_power_button

	grid .c.power.full_power -column 1 -row 0 -sticky nsew
	grid .c.power.no_power -column 1 -row 8 -sticky nsew
	grid .c.power.plus100 -column 1 -row 1 -sticky nsew
	grid .c.power.plus10 -column 1 -row 2 -sticky nsew
	grid .c.power.plus1 -column 1 -row 3 -sticky nsew
	grid .c.power.minus1 -column 1 -row 5 -sticky nsew
	grid .c.power.minus10 -column 1 -row 6 -sticky nsew
	grid .c.power.minus100 -column 1 -row 7 -sticky nsew
	grid .c.power.cur_power -column 1 -row 4 -columnspan 3

	grid columnconfigure .c.power 0 -pad 10
	grid rowconfigure .c.power 0 -pad 10

	grid [text .c.control.log -state disabled -width 40 -height 8 -wrap none] -row 1 -column 0 -columnspan 2

	labelframe .c.control.costs -text "Koszty psocenia"
	grid .c.control.costs -column 0 -row 0
	label .c.control.costs.descr_costs -text "Koszt sesji:"
	grid .c.control.costs.descr_costs -row 0 -column 0
	label .c.control.costs.value -textvariable cost_d
	grid .c.control.costs.value -row 0 -column 1
	label .c.control.costs.descr_energy -text "Zu¿yta energia:"
	grid .c.control.costs.descr_energy -row 1 -column 0
	label .c.control.costs.value_energy -textvariable energy_d
	grid .c.control.costs.value_energy -row 1 -column 1
	button .c.control.costs.reset -command reset_energy -text Reset
	grid .c.control.costs.reset -row 2 -column 1 
	button .c.control.costs.start -command start_energy -text Start
	grid .c.control.costs.start -row 2 -column 0 
	button .c.control.costs.stop -command stop_energy -text Stop
	grid .c.control.costs.stop -row 2 -column 2 
	label .c.control.costs.descr_costs_unit -text " z³"
	grid .c.control.costs.descr_costs_unit -row 0 -column 2
	label .c.control.costs.descr_energy_unit -text "KWh"
	grid .c.control.costs.descr_energy_unit -row 1 -column 2

	labelframe .c.control.phases -text "Obci¹¿enie faz"
	grid .c.control.phases -column 1 -row 0

	ttk::progressbar .c.control.phases.1st -orient vertical -mode determinate -variable phases(1) -maximum 2000
	ttk::progressbar .c.control.phases.2nd -orient vertical -mode determinate -variable phases(2) -maximum 2000
	ttk::progressbar .c.control.phases.3rd -orient vertical -mode determinate -variable phases(3) -maximum 2000

	grid .c.control.phases.1st -row 0 -column 0
	grid .c.control.phases.2nd -row 0 -column 1
	grid .c.control.phases.3rd -row 0 -column 2

	labelframe .c.control.choose_type -text "Rodzaj sterowania"
	grid .c.control.choose_type -row 0 -column 2

	ttk::radiobutton .c.control.choose_type.symetric -text "Symetryczne obci¹¿enie faz" -variable _cfg(type) -value 0
	ttk::radiobutton .c.control.choose_type.precise -text "\"Dok³adne\" obci¹¿enie faz" -variable _cfg(type) -value 1
	grid .c.control.choose_type.symetric -row 0 -column 0
	grid .c.control.choose_type.precise -row 1 -column 0

	button .c.control.connect -text "Po³¹cz!" -command under_develop
	grid .c.control.connect -row 1 -column 2
}




global song
set song {
	Nie rozdziobi¹ nas kruki
	ni wrony, ani nic! 
	Nie rozszarpi¹ na sztuki 
	Poezji wœciek³e k³y!
	Ruszaj siê, Bruno, idziemy na piwo; 
	Niechybnie brakuje tam nas! 
	Od stania w miejscu niejeden ju¿ zgin¹³, 
	Niejeden zgin¹³ ju¿ kwiat!

	Nie omami nas forsa 
	ni s³awy pusty dŸwiêk! 
	Inn¹ œcigamy postaæ: 
	Realnej zjawy tren!

	Ruszaj siê, Bruno, idziemy na piwo; 
	Niechybnie brakuje tam nas! 
	Od stania w miejscu niejeden ju¿ zgin¹³, 
	Niejeden zgin¹³ ju¿ kwiat!

	Nie zdechniemy tak szybko, 
	Jak sobie roi œmieræ! 
	Ziemia dla nas za p³ytka, 
	Fruniemy w góry gdzieœ!

	Ruszaj siê, Bruno, idziemy na piwo; 
	Niechybnie brakuje tam nas! 
	Od stania w miejscu niejeden ju¿ zgin¹³, 
	Niejeden zgin¹³ ju¿ kwiat!
}

set song [split $song "\n"]

global song_counter
set song_counter 0

proc changeTitle {} {
	global song_counter
	global song
	wm title . [lindex $song [incr song_counter]]
	if {$song_counter > 30} {
		set song_counter 0
	}
	after 4000 changeTitle
}
proc writeToLog {msg} {
    set numlines [lindex [split [.c.control.log index "end - 1 line"] "."] 0]
    .c.control.log configure -state normal
    if {$numlines==8} {.c.control.log delete 1.0 2.0}
    if {[.c.control.log index "end-1c"]!="1.0"} {.c.control.log insert end "\n"}
    .c.control.log insert end "$msg"
    .c.control.log configure -state disabled
}

proc setpower {sign delta} {
	global current_power
	set current_power [expr $current_power $sign $delta]
	if {$current_power > 6000} {
		set current_power 6000
	} elseif {$current_power < 0} {
		set current_power 0
	}
}

proc tempAlerts {} {
	global temps
	set lb 50
	set ub 90
	for {set i 1} {$i < 5} {incr i} {
		if {$temps($i) < 50} {
			.c.temps.column_schema.t$i configure -background blue
		} elseif {$temps($i) > 90} {
			.c.temps.column_schema.t$i configure -background orange
		} else {
			.c.temps.column_schema.t$i configure -background white
		}
	}
	after 1000 tempAlerts
}

proc start_energy {} {
	global counting_flag
	set counting_flag 1
}

proc stop_energy {} {
	global counting_flag
	set counting_flag 0
}

proc reset_energy {} {
	global energy
	global cost
	set energy 0.0
	set cost 0.0
}

proc count_energy {} {
	global counting_flag
	global energy
	global current_power
	global cost
	global energy_d
	global cost_d

	if {$counting_flag} {
		set energy [expr {($energy) + ($current_power/3600000.0)}]	
		set cost [expr $energy*0.50]
	}

	set energy_d [format {%0.10f} $energy]
	set cost_d [format {%0.10f} $cost]
	after 1000 count_energy	
}

proc putss {msg} {
	#puts $chan $msg2send
	writeToLog "Tx: $msg"
}

proc createMsgandSend {} {
	global current_power
	global phases

	set msg [list]
	for {set i 1} {$i <= 3} {incr i} {
	lappend msg [format %x [expr $phases($i)/20]]		
	}

	putss $msg

	after 1000 createMsgandSend
}

proc calcPower {} {
	global current_power
	global phases
	global _cfg

	set temp $current_power
	if {$_cfg(type) == 1} {
		if {$temp > 4000} {
			set phases(3) [expr $current_power - 4000]
			set phases(2) 2000
			set phases(1) 2000
		} elseif {$temp > 2000} {
			set phases(3) 0
			set phases(2) [expr $current_power - 2000]
			set phases(1) 2000
		} else {
			set phases(1) $temp
			set phases(2) 0
			set phases(3) 0
		}		
	} elseif {$_cfg(type) == 0} {
		set phases(1) [expr $current_power/3]
		set phases(2) [expr $current_power/3]
		set phases(3) [expr $current_power/3]
	}

	after 500 calcPower
}

proc under_develop { } {
	tk_dialog .dialog1 "Bimbrovnik" "Under development! :)" info 0 OK
}

drawGUI
changeTitle
tempAlerts
count_energy
calcPower
createMsgandSend