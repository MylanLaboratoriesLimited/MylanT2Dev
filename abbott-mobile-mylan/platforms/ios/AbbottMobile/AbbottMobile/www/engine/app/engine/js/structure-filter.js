var structure;

if(window.parent.isSPA){
	structure = window.parent.app.structure;
}else{
	structure = require('structureJSON');

	Object.keys(structure.chapters).forEach(function(chapterId){
		var chapter = structure.chapters[chapterId];

		chapter.content = chapter.content.filter(isEnable);
		chapter.id = chapterId;
	});

	structure.storyboard = structure.storyboard.filter(isEnable);
}

function isEnable(id){
	return id.charAt(0) !== "!";
}

module.exports = structure;