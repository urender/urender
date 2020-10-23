#!/usr/bin/ucode

push(REQUIRE_SEARCH_PATH,
	"/usr/lib/ucode/*.so",
	"/usr/share/urender/*.uc",
	"/usr/share/urender/lib/*.uc");

let fs = require("fs");

let boardfile = fs.open("/etc/board.json", "r");
let board = json(boardfile.read("all"));
boardfile.close();

capa = {};
let wifi = require("wiphy");
capa.compatible = replace(board.model.id, ',', '_');
capa.model = board.model.name;

if (board.bridge && board.bridge.name == "switch")
	capa.platform = "switch";
else if (length(wifi))
	capa.platform = "ap";
else
	capa.platform = "unknown";

capa.network = {};
macs = {};
for (let k, v in board.network) {
	if (v.ports)
		capa.network[k] = v.ports;
	if (v.device)
		capa.network[k] = [v.device];
	if (v.ifname)
		capa.network[k] = split(replace(v.ifname, /^ */, ''), " ");
	if (v.macaddr)
		macs[k] = v.macaddr;
}

if (length(macs))
	capa.macaddr = macs;

if (board.system?.label_macaddr)
	capa.label_macaddr = board.system?.label_macaddr;

if (board.switch)
	capa.switch = board.switch;
if (length(wifi)) {
	capa.wifi = wifi.phys;
	for (let radio in capa.wifi) {
		delete capa.wifi[radio].channels;
		delete capa.wifi[radio].frequencies;
		delete capa.wifi[radio].dfs_channels;
	}
}

capafile = fs.open("/etc/urender/capabilities.json", "w");
capafile.write(capa);
capafile.close();
