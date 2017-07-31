

(function(/*! Stitch !*/) {
  if (!this.specs) {
    var modules = {}, cache = {}, require = function(name, root) {
      var path = expand(root, name), indexPath = expand(path, './index'), module, fn;
      module   = cache[path] || cache[indexPath]
      if (module) {
        return module.exports;
      } else if (fn = modules[path] || modules[path = indexPath]) {
        module = {id: path, exports: {}};
        try {
          cache[path] = module;
          fn(module.exports, function(name) {
            return require(name, dirname(path));
          }, module);
          return module.exports;
        } catch (err) {
          delete cache[path];
          throw err;
        }
      } else {
        throw 'module \'' + name + '\' not found';
      }
    }, expand = function(root, name) {
      var results = [], parts, part;
      if (/^\.\.?(\/|$)/.test(name)) {
        parts = [root, name].join('/').split('/');
      } else {
        parts = name.split('/');
      }
      for (var i = 0, length = parts.length; i < length; i++) {
        part = parts[i];
        if (part == '..') {
          results.pop();
        } else if (part != '.' && part != '') {
          results.push(part);
        }
      }
      return results.join('/');
    }, dirname = function(path) {
      return path.split('/').slice(0, -1).join('/');
    };
    this.specs = function(name) {
      return require(name, '');
    }
    this.specs.define = function(bundle) {
      for (var key in bundle)
        modules[key] = bundle[key];
    };
    this.specs.modules = modules;
    this.specs.cache   = cache;
  }
  return this.specs.define;
}).call(this)({
  "controllers/accounts": function(exports, require, module) {(function() {
  var require;

  require = window.require;

  describe('The Accounts Controller', function() {
    var Accounts;
    Accounts = require('controllers/accounts');
    return it('can noop', function() {});
  });

}).call(this);
}, "controllers/activities": function(exports, require, module) {(function() {
  var require;

  require = window.require;

  describe('The Activities Controller', function() {
    var Activities;
    Activities = require('controllers/activities');
    return it('can noop', function() {});
  });

}).call(this);
}, "controllers/home": function(exports, require, module) {(function() {
  var require;

  require = window.require;

  describe('The Home Controller', function() {
    var Home;
    Home = require('controllers/home');
    return it('can noop', function() {});
  });

}).call(this);
}, "controllers/tots": function(exports, require, module) {(function() {
  var require;

  require = window.require;

  describe('The Tots Controller', function() {
    var Tots;
    Tots = require('controllers/tots');
    return it('can noop', function() {});
  });

}).call(this);
}, "controllers/tour-planning": function(exports, require, module) {(function() {
  var require;

  require = window.require;

  describe('The TourPlanning Controller', function() {
    var TourPlanning;
    TourPlanning = require('controllers/tour-planning');
    return it('can noop', function() {});
  });

}).call(this);
}, "models/contact": function(exports, require, module) {(function() {
  var require;

  require = window.require;

  describe('The Contact Model', function() {
    var Contact;
    Contact = require('models/contact');
    return it('can noop', function() {});
  });

}).call(this);
}, "models/entities-collection": function(exports, require, module) {(function() {
  var require;

  require = window.require;

  describe('The EntitiesCollection Model', function() {
    var EntitiesCollection;
    EntitiesCollection = require('models/bll/entities-collection');
    return it('can noop', function() {});
  });

}).call(this);
}, "models/entity": function(exports, require, module) {(function() {
  var require;

  require = window.require;

  describe('The Entity Model', function() {
    var Entity;
    Entity = require('models/entity');
    return it('can noop', function() {});
  });

}).call(this);
}, "models/organization": function(exports, require, module) {(function() {
  var require;

  require = window.require;

  describe('The Organization Model', function() {
    var Organization;
    Organization = require('models/organization');
    return it('can noop', function() {});
  });

}).call(this);
}, "models/organizations-collection": function(exports, require, module) {(function() {
  var require;

  require = window.require;

  describe('The OrganizationsCollection Model', function() {
    var OrganizationsCollection;
    OrganizationsCollection = require('models/bll/organizations-collection');
    return it('can noop', function() {});
  });

}).call(this);
}, "models/reference": function(exports, require, module) {(function() {
  var require;

  require = window.require;

  describe('The Reference Model', function() {
    var Reference;
    Reference = require('models/reference');
    return it('can noop', function() {});
  });

}).call(this);
}
});

require('lib/setup'); for (var key in specs.modules) specs(key);