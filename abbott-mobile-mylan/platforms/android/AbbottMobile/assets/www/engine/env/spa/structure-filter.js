(function(){
	"use strict"

	var params = window.params,
		callNumber = params.callNumber,
		division = params.division,
		structures = [], load = window.utils.load;

	structures.unshift(params.structure || "structure.json");

	if(callNumber || params.isGraph){
		structures.unshift("structure_cn" + callNumber + ".json");
		if(params.visitMode === 'short'){
			structures.unshift("structure_cn" + callNumber + "_short.json");
		}
	}else if(division){
		structures.unshift("structure_" + division + ".json");
	}

	window.app = {};

	structures.some(function(structure){
		var xhr = load(structure),
			fileExists = xhr.status !== 404 && xhr.status !== -1100; // status -1100 - ios 6 abbott clm

		return fileExists && (app.structure = parseStructure(xhr.response));
	});

	function parseStructure(structure){
		structure = JSON.parse(structure);

		Object.keys(structure.chapters).forEach(function(chapterId){
			var chapter = structure.chapters[chapterId];

			chapter.content = chapter.content.filter(isEnable);
			chapter.id = chapterId;
		});

		structure.storyboard = structure.storyboard.filter(isEnable);

		return structure;
	}

	function isEnable(id){
		return id.charAt(0) !== "!";
	}
})();