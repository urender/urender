{%	if (!state.unit) return %}
{%	if (unit.name): %}
set system.@system[-1].description={{ s(unit.name) }}
{%	endif
	if (unit.hostname): %}
set system.@system[-1].hostname={{ s(unit.hostname) }}
	endif %}
	if (unit.location): %}
set system.@system[-1].notes={{ s(unit.location) }}
	endif
	if (unit.timezone): %}
set system.@system[-1].timezone={{ s(unit.timezone) }}
{%	endif
	/* force the restart of the led script */
	services.set_enabled("led", true); %}
set system.@system[-1].leds_off={{ b(!unit.leds_active) }}
{%
	if (unit.random_password !== null)
		shell.password(unit.random_password);
%}
