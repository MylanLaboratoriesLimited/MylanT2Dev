var es = require('event-stream'),
	gulp = require('gulp'),
	gutil = require('gulp-util'),
	path = require('path'),
	settings = require('./app/settings/app.json'),
	environments = require('gulp-environments'),
	structure, slidesToBuild, slides, clm;

gutil.env.dest = gutil.env.dest || 'build';
gutil.env.structure = gutil.env.structure ? (/.json/.test(gutil.env.structure) ? gutil.env.structure : gutil.env.structure + '.json') : 'structure.json';
structure = require('./' + gutil.env.structure);

slidesToBuild = gutil.env.slides ? gutil.env.slides.split(' ').map(validate) : Object.keys(structure.slides);

slides = slidesToBuild.map(function(slide){
	var prefixed = (settings[gutil.env.clm + 'Prefix'] ? settings[gutil.env.clm + 'Prefix'] + '_' : '') + slide,
		template = structure.slides[slide].template,
		sid = gutil.env.visit ? gutil.env.prefix + '_' + slide : slide;

	return {
		src: template,
		dest: path.join(gutil.env.dest, gutil.env.clm, '/slides/', prefixed),
		id: template.split(/\/+/).pop().slice(0, -5),
		sid: sid,
		name: structure.slides[slide].name,
		prefixed: prefixed
	};
});

clm = (gutil.env.clm || '').replace(/^(iplanner)$/, 'spa');

environments.common(gulp, slides, settings);
environments[clm](gulp, slides, settings);

gulp.task('default', ['clean'], function(){
	// clm: irep | spa | mitouch | viseven | iplanner
	// slides: %slide id%
	// zip

	var tasks = [clm + '-build'];

	if(gutil.env.zip){
		tasks = tasks.concat(clm + '-zip');
	}

	return gulp.start.apply(gulp, tasks);
});

function validate(id){
	if(!structure.slides.hasOwnProperty(id)){
		throw "Slide '" + id + "' is not defined";
	}
	return id;
}