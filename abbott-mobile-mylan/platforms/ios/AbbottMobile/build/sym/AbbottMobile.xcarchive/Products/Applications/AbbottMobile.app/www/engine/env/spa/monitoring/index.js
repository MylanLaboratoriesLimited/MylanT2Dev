(function(){
	'use strict';
	var scheme = {},
		metrics = {};

	function addScheme(name, model, options){
		scheme[name] = { validate: validateShema.schema(model), validateObligatory: validateShema.obligatory(options), options: options || {} };
		if(!scheme[name].options.unique){
			metrics[name] = [];
		}
	}

	function validate(name, schema, data){
		if(!schema){
			throw new Error('Unknown schema for "' + name + '"');
		}

		if(!schema.validate(data)){
			throw new Error('Invalid data for "' + name + '": ' + JSON.stringify(data));
		}

		if(!schema.validateObligatory(data)){
			throw new Error('Invalid data for "' + name + '": ' + JSON.stringify(data) + ': obligatory fields should be passed');
		}
	}

	// TODO: use utils.mixin
	function mixin(target, source){
		Object.keys(target).forEach(function(key){
			target[key] = source[key];
		});
	}

	function assign(metrics, name, data, options){
		var key = options.updateBy;
		if(key && metrics[name]){
			(options.update || mixin)(metrics[name], data);
		}else{
			metrics[name] = data;
		}
	}

	function update(metrics, name, data, options){
		var key = options.updateBy, exists;

		if(key){
			metrics[name].filter(function(item){
				return item[key] === data[key];
			}).forEach(function(item){
					exists = true;
					(options.update || mixin)(item, data);
				});
		}

		if(!exists){
			metrics[name].push(data);
		}
	}

	function sync(metrics){
		localStorage.setItem('KPI', JSON.stringify(metrics));
	}

	function getKPI(){
		var currentMetrics = localStorage.getItem('KPI');

		currentMetrics = currentMetrics ? JSON.parse(currentMetrics) : {};

		Object.keys(metrics).filter(function(key){
			return !currentMetrics.hasOwnProperty(key);
		}).forEach(function(key){
				if(!scheme[key].options.unique){
					currentMetrics[key] = [];
				}
			});

		return currentMetrics;
	}

	function submit(name, data){
		var schema = scheme[name],
			metrics = getKPI();
		validate(name, schema, data);

		if(schema.options.unique){
			assign(metrics, name, data);
		}else{
			update(metrics, name, data, schema.options);
		}

		sync(metrics);
	}

	window.submit = {
		data: submit,
		schema: addScheme
	};
})();