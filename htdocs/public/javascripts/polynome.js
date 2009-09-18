function toggle_panel(element, id) {
	Effect.toggle(id, 'blind', { 
		afterFinish: function(effect) { 
			element.className = effect.factor == -1 ? 'panel_header closed' : 'panel_header open'; 
		} 
	});
}
