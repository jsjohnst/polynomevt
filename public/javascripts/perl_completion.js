var done = 0;
var simulation_output = '';
var htmlBody = document.getElementById("bodytag");

function check_perl_completed(prefix) {
	if(!done) {
		var node = document.createElement("script");
		node.src = "/perl/" + prefix + ".done.js?t=" + (new Date).getTime();
		htmlBody.appendChild(node);
		setTimeout("check_perl_completed('" + prefix + "')", 5000);
	} else {
		var node = document.getElementById("completion_msg");
		node.innerHTML = simulation_output + '<br><br><strong>Your data has been generated successfully!</strong>';
	}
}