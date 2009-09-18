function toggle_panel(element) {
	Effect.toggle(element.id.substr(0, element.id.length - 6) + "panel", 'blind', { 
		afterFinish: function(effect) { 
			element.className = effect.factor == -1 ? 'panel_header closed' : 'panel_header open'; 
		},
		duration: 0.1,
		delay: 0 
	});
}

function show_modal(id, title) {
	Modalbox.show( $(id), {title: title, width: 300, overlayDuration: 0.1, slideDownDuration: 0.1,
			slideUpDuration: 0.1, autoFocusing: false, resizeDuration: 0.1, afterLoad: function() {
		$('dialog_' + id).value = $('hidden_' + id).value;
	}, beforeHide: function() {
		$('hidden_' + id).value = $('dialog_' + id).value;
	}});
}

function close_hidden_panels() {
	closed_panels = $$('.panel_header.closed');
	closed_panels.each(function(element) { Element.hide(element.id.substr(0, element.id.length - 6) + "panel"); });
}


Event.observe(window, 'load', close_hidden_panels);

Event.observe(window,"load",function() {
	$$("*").findAll(function(node){
		return $(node.id + "_tooltip");
	}).each(function(node){
		new Tooltip(node,node.id + "_tooltip");
	});
});
