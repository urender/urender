{%
	if (!length(gps))
		return;
%}
set gps.@gps[-1].disabled=0
set gps.@gps[-1].adjust_time={{ b(gps.adjust_time) }}
