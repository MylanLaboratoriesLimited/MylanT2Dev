(function(){
	'use strict';
	function comparator(type){
		return (typeof type === 'function' ? typeAssert : schema)(type);
	}

	function typeAssert(type){
		return function(item){
			return type(item) === item;
		};
	}

	function schema(map){
		return function(target){
			return Object.keys(target).every(function(key){
				var type = map[key];
				if(Array.isArray(type)){
					return Array.isArray(target[key]) && target[key].every(comparator(type[0]));
				}

				return map.hasOwnProperty(key) && comparator(type)(target[key]);
			});
		};
	}

	function schemaObligatory(options){
		var obligatory = ['updateBy'];
		return function(target){
			return !options || obligatory.every(function(key){
				return !options.hasOwnProperty(key) || target.hasOwnProperty(options[key]);
			})
		};
	}

	window.validateShema = {
		schema: schema,
		obligatory: schemaObligatory
	};
})();