# EP 2020-10-25 synthesize breadboard for ice40up5k
all: top.bin

VERILOGS=top.v tms9900.v alu9900.v tms9902.v ram.v rom.v spram.v

top.json: 
	yosys \
		-q \
		-p 'read_verilog $(VERILOGS)' \
		-p 'synth_ice40 -top top -json top.json' \
		-E .top.d

top.asc: top.json upduino.pcf
	nextpnr-ice40 \
		--up5k \
		--package sg48 \
		--asc top.asc \
		--pcf upduino.pcf \
		--json top.json \
		--freq 12

top.bin: top.asc
	icepack top.asc top.bin

