var rivets = require("rivets"),
	parse = require("dom-parser"),
	forEach = Array.prototype.forEach;

function clearNode(node){
	while(node.firstChild){
		node.removeChild(node.firstChild);
	}
}

function html(element, value){
	var template = parse(value),
		model = this.model;

	clearNode(element);
	element.appendChild(template);

	forEach.call(element.childNodes, function(node){
		rivets.bind(node, model);
	});
}

exports.substitute = function(){
	rivets.binders.html = html;
};