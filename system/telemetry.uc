#!/usr/bin/ucode
{%
let fs = require("fs");
let f = fs.open("/tmp/urender.telemetry", "w");
if (f)
	f.close();

telemetry = true;
include("state.uc");
%}
