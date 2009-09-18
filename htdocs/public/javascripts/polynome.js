function toggle_panel(element, id) {
	Effect.toggle(id, 'blind', { 
		afterFinish: function(effect) { 
			element.className = effect.factor == -1 ? 'panel_header closed' : 'panel_header open'; 
		},
		duration: 0.5 
	});
}

function close_hidden_panels() {
	closed_panels = $$('.panel_header.closed');
	closed_panels.invoke('onclick');
}


Event.observe(window, 'load', close_hidden_panels);
Event.observe(window,"load",function() {
var my_tooltip = new Tooltip('product_1', 'tooltip');
});
