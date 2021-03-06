QuickScript.initKO = ->
	# plugins
	ko.punches.enableAll()

	# binding handlers
	ko.bindingHandlers.viewbox =
		init : (element, valueAccessor, bindingsAccessor, viewModel, bindingContext) ->
			ko.applyBindingsToNode(element, {template : 'viewbox'}, bindingContext)

	ko.bindingHandlers.fadeVisible =
		init : (element, valueAccessor) ->
			shouldDisplay = ko.utils.unwrapObservable(valueAccessor())
			if shouldDisplay then $(element).show() else $(element).hide()
		update : (element, value) ->
			shouldDisplay = value()
			if shouldDisplay
				$(element).fadeIn('slow')
			else
				$(element).hide()

	ko.bindingHandlers.slideVisible =
		init : (element, valueAccessor) ->
			shouldDisplay = ko.utils.unwrapObservable(valueAccessor())
			if shouldDisplay then $(element).show() else $(element).hide()
		update : (element, valueAccessor) ->
			shouldDisplay = ko.utils.unwrapObservable(valueAccessor())
			if shouldDisplay then $(element).slideDown('slow') else $(element).slideUp()
	
	ko.bindingHandlers.visibleWithText =
		update : (element, valueAccessor) ->
			text = ko.unwrap(valueAccessor())
			$(element).text(text)
			if (text? && text.length > 0) then $(element).show() else $(element).hide()

	ko.bindingHandlers.dim =
		init : (element, valueAccessor) ->
			shouldDim = ko.utils.unwrapObservable(valueAccessor())
			if shouldDim then $(element).css({opacity : 0.3}) else $(element).css({opacity: 1.0})
		update : (element, valueAccessor) ->
			shouldDim = ko.utils.unwrapObservable(valueAccessor())
			if shouldDim then $(element).animate({opacity : 0.3}) else $(element).animate({opacity: 1.0})

	# buttonStatus - [is_loading, ready_str, loading_str, icon_classes]
	ko.bindingHandlers.buttonStatus =
		update : (element, valueAccessor) ->
			opts = ko.utils.unwrapObservable(valueAccessor())
			if opts[0]
				$(element).html(opts[2])
				$(element).attr('disabled', 'true')
			else
				if opts[3]?
					txt = "<i class='#{opts[3]}'></i> #{opts[1]}"
				else
					txt = opts[1]
				$(element).html(txt)
				$(element).removeAttr('disabled')

	# listStatus - [collection, none_str, loading_str, list]
	ko.bindingHandlers.listStatus =
		init : (element, valueAccessor, bindingsAccessor, viewModel) ->
			opts = ko.utils.unwrapObservable(valueAccessor())
			opts = {collection : opts[0], empty_str : opts[1], loading_str : opts[2], list : opts[3] || opts[0].views} if opts instanceof Array
			ko.computed ->
				if opts.collection.is_loading()
					if opts.loading_img?
						$(element).html("<img src='#{opts.loading_img}'/>")
					else
						$(element).html(opts.loading_str)
					$(element).show('fast')
				else
					if opts.list().length > 0
						$(element).hide('fast')
					else
						$(element).show()
						$(element).html(opts.empty_str)
			, viewModel
			#fn()
			#opts.list.is_loading.subscribe(fn)

	# viewOptions - [views, view_string_fn, view_val_fn, default_str (optional)]
	ko.bindingHandlers.viewOptions =
		update : (element, valueAccessor) ->
			$(element).empty()
			opts = valueAccessor()
			views = ko.utils.unwrapObservable(opts[0])
			for view in views
				$(element).append("<option value='#{opts[2](view)}'>#{opts[1](view)}</option>")
			if opts[3]?
				$(element).prepend("<option>#{opts[3]}</option>")

	ko.bindingHandlers.handleEnter =
		init : (element, valueAccessor, bindingsAccessor, viewModel) ->
			$(element).keypress (ev)->
				if (ev.keyCode == 13 && !ev.shiftKey)
					action = valueAccessor()
					val = bindingsAccessor().value
					val($(element).val())
					action.call(viewModel)
					return false

	ko.bindingHandlers.handleTab =
		init : (element, valueAccessor, bindingsAccessor, viewModel) ->
			$(element).keydown (ev)->
				if (ev.keyCode == 9 && !ev.shiftKey)
					action = valueAccessor()
					val = bindingsAccessor().value
					val($(element).val())
					action.call(viewModel)
					return false

	ko.bindingHandlers.selected =
		update : (element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) ->
			selected = ko.utils.unwrapObservable(valueAccessor())
			element.select() if selected

	ko.bindingHandlers.touchstart =
		init : (element, valueAccessor, bindingsAccessor, viewModel) ->
			element.addEventListener('touchstart', valueAccessor().bind(viewModel))

	ko.bindingHandlers.validate =
		update : (element, valueAccessor, bindingsAccessor, viewModel) ->
			opts = valueAccessor()
			test_fn = bindingsAccessor().value.is_valid
			err_css = 'field_invalid'
			ok_css = 'field_valid'
			if test_fn()
				$(element).removeClass(err_css)
				$(element).addClass(ok_css)
			else
				$(element).removeClass(ok_css)
				$(element).addClass(err_css)
				#opts.on_err() if opts.on_err?

	ko.bindingHandlers.allowChars =
		update : (element, valueAccessor, bindingsAccessor, viewModel) ->
			reg = new RegExp(valueAccessor(), 'g')
			$(element).keyup (ev)->
				if this.value.match(reg)
					this.value = this.value.replace(reg, '')

	ko.bindingHandlers.cropImage =
		update : (element, valueAccessor) ->
			opts = valueAccessor()
			if opts[0]?
				$(element).css
					background : 'url(' + ko.utils.unwrapObservable(opts[0]) + ')',
					backgroundSize: 'cover',
					'background-position': 'center',
					width: opts[1],
					height: opts[2],
					display: 'inline-block'

	ko.bindingHandlers.containImage =
		update : (element, valueAccessor) ->
			opts = valueAccessor()
			if opts[0]?
				$(element).css
					background : 'url(' + ko.utils.unwrapObservable(opts[0]) + ')',
					backgroundSize: 'contain',
					'background-position': 'center',
					backgroundRepeat: 'no-repeat',
					width: opts[1],
					height: opts[2],
					display: 'inline-block'

	ko.bindingHandlers.fadeInImage =
		update : (element, valueAccessor) ->
			src = ko.utils.unwrapObservable(valueAccessor())
			$(element).css(opacity: 0)
			img = new Image()
			img.onload = ->
				$(element).animate({opacity: 1.0}, 1000)
				element.src = src if element.tagName == "IMG"
			img.src = src

	ko.bindingHandlers.onImageLoad =
		init : (element, valueAccessor) ->
			element.onload = ->
				valueAccessor()(element)

	ko.bindingHandlers.preloadImage =
		init : (element, valueAccessor) ->
			opts = valueAccessor()
			img = new Image()
			img.onload = ->
				opts.after(element)
			img.src = opts.src
	
	ko.bindingHandlers.toggleHover =
		init: (element, valueAccessor, allBindingsAccessor) ->
			$(element).on 'mouseover', ->
				valueAccessor()(true)
			$(element).on 'mouseout', ->
				valueAccessor()(false)

	ko.bindingHandlers.checkedInt =
		init: (element, valueAccessor, allBindingsAccessor) ->
			observable = valueAccessor()
			interceptor = ko.computed
				read: ->
					return observable().toString()
				write: (newValue) ->
					observable(+newValue)
				owner: this
			ko.applyBindingsToNode(element, { checked: interceptor })

	ko.bindingHandlers.untabbable =
		update : (element, valueAccessor, bindingsAccessor, viewModel) ->
			if (valueAccessor())
				$(element).find('iframe, input, textarea, a, iframe').attr('tabIndex', -1)
			else
				$(element).find('input, textarea, a, iframe').removeAttr('tabIndex')

	ko.bindingHandlers.carousel =
		init : (element, valueAccessor, bindingsAccessor, viewModel) ->
			setTimeout ->
				idx = viewModel.getViewBoxIndex(viewModel.task())
				new_el = $(element).find('.slide-item-' + idx).first()
				#new_el.addClass('active')
			, 0
		update : (element, valueAccessor, bindingsAccessor, viewModel) ->
				opts = viewModel.transition.opts
				if viewModel.task() != null
					setTimeout ->
						idx = viewModel.getViewBoxIndex(viewModel.task())
						console.log(viewModel.name + ': updating slider to ' + idx)
						old_idx = opts.slide_index()
						new_el = $(element).find('.slide-item-' + idx).first()
						old_el = $(element).find('.slide-item-' + old_idx).first()
						if idx > old_idx
							new_el.addClass('next')
							new_el[0].offsetWidth if new_el[0]?
							old_el.addClass('left')
							new_el.addClass('left')
						else
							new_el.addClass('prev')
							new_el[0].offsetWidth if new_el[0]?
							old_el.addClass('right')
							new_el.addClass('right')
						setTimeout ->
							new_el.removeClass('next left prev right')
							old_el.removeClass('next left prev right')
							old_el.removeClass('active')
							new_el.addClass('active')
						, 600
						opts.slide_index(idx)
					, 0
	
	ko.bindingHandlers.formError =
		update : (element, valueAccessor) ->
			error = ko.unwrap(valueAccessor())
			$el = $(element)
			# reset element
			$el.removeClass('has-error')
			$el.find('.help-block-error').remove()

			if error?
				$el.addClass('has-error')
				$el.append("<div class='help-block help-block-error'>#{error}</div>")

	ko.bindingHandlers.bindelem =
		init : (element, valueAccessor, bindingsAccessor, viewModel) ->
			viewModel.element = element

	ko.bindingHandlers.jsfileupload =
		init : (element, valueAccessor, bindingsAccessor, viewModel) ->
			model = valueAccessor()
			$(element).fileupload(model.input.options)
			$(element).change (evt)->
				model.input.files(evt.target.files)
			model.fileupload = $(element).fileupload.bind($(element))
			model.selectFile = ->
				$(element).click()

	ko.bindingHandlers.fileupload =
		init : (element, valueAccessor, bindingsAccessor, viewModel) ->
			model = valueAccessor()
			$(element).change (evt)->
				model.input.files(evt.target.files)
			model.selectFile = ->
				$(element).click()

	ko.bindingHandlers.jqtabs =
		init : (element, valueAccessor, bindingsAccessor, viewModel) ->
			$(element).addClass('ui-tabs ui-widget ui-widget-content ui-corner-all')
			$(element).children('ul').first().addClass('ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all')
			$(element).children('ul').first().children('li').addClass('ui-state-default ui-corner-top')
			$(element).children('div').addClass('ui-tabs-panel ui-widget-content ui-corner-bottom')
			$(element).children('ul').first().find('li a').each (idx, el)->
				tab_id = $(el).parent()[0].id
				$(el).click ->
					valueAccessor()(tab_id)
		update : (element, valueAccessor, bindingsAccessor, viewModel) ->
			sel_tab = ko.utils.unwrapObservable(valueAccessor())
			$(element).children('ul').first().children('li').removeClass('ui-tabs-selected ui-state-active')
			$(element).children('ul').first().children("li##{sel_tab}").addClass('ui-tabs-selected ui-state-active')
			$(element).children('div').addClass('ui-tabs-hide')
			$(element).children("div##{sel_tab}").removeClass('ui-tabs-hide')

	ko.bindingHandlers.tabs =
		init : (element, valueAccessor, bindingsAccessor, viewModel) ->
			$(element).children('li').each (idx, el)->
				tab_id = $(el)[0].id
				$(el).click ->
					valueAccessor()(tab_id)
		update : (element, valueAccessor, bindingsAccessor, viewModel) ->
			sel_tab = ko.utils.unwrapObservable(valueAccessor())
			$(element).children('li').removeClass('active')
			$(element).children("li##{sel_tab}").addClass('active')
	ko.bindingHandlers.tab_views =
		update : (element, valueAccessor, bindingsAccessor, viewModel) ->
			sel_tab = ko.utils.unwrapObservable(valueAccessor())
			$(element).children('div').addClass('hidden').removeClass('active')
			$(element).children("div##{sel_tab}").addClass('active').removeClass('hidden')

	ko.bindingHandlers.tabpanes =
		init : (element, valueAccessor, bindingsAccessor, viewModel) ->
			# find panes
			$el = $(element)
			$panes = $el.children('pane')
			pane_data = $panes.toArray().map (p)->
				$p = $(p)
				return {
					title: $p.attr('title'),
					key: $p.attr('data-key'),
					html: p.innerHTML,
					visible: $p.attr('data-visible')
				}

			# prepare observable
			tab_obs = valueAccessor()
			viewModel[tab_obs] = ko.observable(pane_data[0].key) unless viewModel[tab_obs]?

			# build panes properly
			str = "<div class='tabbable'><ul class='nav nav-tabs'>"
			for pane in pane_data
				click_db = "click : function(){#{tab_obs}('#{pane.key}');}"
				visible_db = if pane.visible? then ", visible : #{pane.visible}" else ""
				str += "<li data-bind=\"css : {active : #{tab_obs}() == '#{pane.key}'}\"><a href='' data-bind=\"#{click_db}#{visible_db}\">#{pane.title}</a></li>"
			str += "</ul>"
			str += "<div class='tab-content'>"
			for pane in pane_data
				str += "<div class='tab-pane' data-bind=\"css : {active : #{tab_obs}() == '#{pane.key}'}\">#{pane.html}</div>"
			str += "</div></div>"
			element.innerHTML = str

			# bindings applied automatically to descendants

	ko.bindingHandlers.calendar =
		init : (element, valueAccessor, bindingsAccessor, viewModel) ->
			console.log('calendar init')
			$(element).fullCalendar('destroy')
			opts = $.extend({}, ko.utils.unwrapObservable(valueAccessor()))
			$(element).fullCalendar(opts)
			viewModel.calendar = $(element).fullCalendar.bind($(element))

	ko.bindingHandlers.center =
		init : (element, valueAccessor, bindingsAccessor, viewModel) ->
			fn = ->
				setTimeout ->
						$(element).center()
					, 1
			viewModel.task.subscribe(fn)
			viewModel.is_visible.subscribe(fn)

	ko.bindingHandlers.placeholder =
		init: (element, valueAccessor) ->
			fn = ->
				if ($(element).val().length > 0)
					$(element).siblings('label').hide()
				else
					$(element).siblings('label').show()
			$(element).on('blur change keyup', fn)
		update: (element, valueAccessor) ->
			if ($(element).val().length > 0)
				$(element).siblings('label').hide()
			else
				$(element).siblings('label').show()

	ko.bindingHandlers.linkify =
		update : (element, valueAccessor, bindingsAccessor, viewModel, bindingContext) ->
			text = ko.utils.unwrapObservable(valueAccessor())
			$(element).html(QS.utils.linkify(text))
	
	# radioClick : [<observable>, <value>]
	ko.bindingHandlers.radioClick =
		init : (element, valueAccessor) ->
			obs = valueAccessor()[0]
			val = valueAccessor()[1]
			$(element).click ->
				obs(val)
				return false
		update : (element, valueAccessor) ->
			obs = valueAccessor()[0]
			val = valueAccessor()[1]
			if obs() == val
				$(element).addClass('active')
			else
				$(element).removeClass('active')
	
	ko.bindingHandlers.viewComponents =
		init : (element, valueAccessor, bindingsAccessor, viewModel, bindingContext) ->
			$el = $(element)
			opts = valueAccessor()
			name = opts.name
			data = opts.data
			owner = opts.owner
			view = opts.view || View
			if !ko.components.isRegistered(name)
				# component not registered, add it
				#tpl = $el.html()
				tpl = (node.outerHTML for node in ko.virtualElements.childNodes(element)).join(" ")
				tpl_name = "component-#{name}"
				ko.addTemplate tpl_name, tpl
				view.registerComponent(name, tpl_name)
			bindingContext.componentOwner = owner || viewModel
			bindingContext.componentData = data
			$tpl = $("
				<!-- ko component : {name: '#{name}', params: {model: $data, owner: $parentContext.componentOwner}} -->
				<!-- /ko -->
			")
			ko.virtualElements.setDomNodeChildren(element, $tpl)
			ko.applyBindingsToNode(element, {foreach: data}, bindingContext)
			return {controlsDescendantBindings: true}
	ko.virtualElements.allowedBindings.viewComponents = true

	ko.bindingHandlers.updateContext =
		init : (element, valueAccessor, bindingsAccessor, viewModel, bindingContext) ->
			props = valueAccessor()
			if typeof(props) == "string"
				bindingContext[props] = viewModel
			else
				for prop, val of props
					bindingContext[prop] = val
	ko.bindingHandlers.context = ko.bindingHandlers.updateContext
	ko.bindingHandlers.scopeAs =
		init : (element, valueAccessor, bindingsAccessor, viewModel, bindingContext) ->
			props = valueAccessor()
			bindingContext[props] = viewModel

	## EXTENDERS
	
	ko.extenders.usd = (target) ->
		target.usd = ko.computed
			read : ->
				return null if !target()?
				target() / 100.0
			write : (val)->
				target(val * 100.0)
		target.usd_str = ko.computed
			read : ->
				return "$ -" if !target()?
				"$ #{target.usd().toFixed(2)}"
			deferEvaluation : true
		return target

	ko.extenders.date = (target) ->
		target.date = ko.computed
			read : ->
				Date.from_utc(target())
			deferEvaluation : true
		target.date_str = ko.computed
			read : ->
				target.date().format('mmm d, yyyy')
			deferEvaluation : true
		target.ago_str = ko.computed
			read : ->
				"#{(new TimeLength(target.date())).toString()} ago"
			deferEvaluation : true
		return target

	ko.extenders.errors = (target) ->
		target.has = (field)->
			ko.computed ->
				return target()[field]?
			, target
		target.for = (field)->
			ko.computed ->
				if target()[field]? then target()[field][0] else null
			, target
		target.any = ko.computed ->
				!jQuery.isEmptyObject(target())
			, target
		return target

	## PREPROCESSORS
	
	ko.punches.utils.setNodePreprocessor (node)->
		# only for <a> links
		if node.nodeType == 1 && node.nodeName == "A" && node.getAttribute('iref') != null
			iref = node.getAttribute('iref')
			click_db = "click : function() { App.redirectTo('#{iref}'); }"
			ko.utils.appendNodeDataBind(node, click_db)

	## COMPONENT LOADER

	ko.components.loaders.unshift
		loadTemplate : (name, config, callback)->
			callback(null) if config.loader != 'QuickScript'

			errorCallback = (msg)->
				throw new Error("Component '#{name}': #{msg}.")
			applyStyles = (el)->
				if config.style?
					if typeof(config.style) == 'string'
						$('head').append("<style>#{config.style}</style>")
						callback(el)
					else
						$el = $(el)
						for sel, props of config.style
							$el.filter(sel).add($el.find(sel)).css(props)
						callback($el.toArray())
				else
					callback(el)
			if config.element_id?
				# specifies id, load from element
				el = document.getElementById(config.element_id)
				if el?
					applyStyles(ko.utils.parseHtmlFragment(el.text))
				else
					errorCallback("Template with id '#{config.element_id}' not found")
			else if config.html?
				applyStyles(ko.utils.parseHtmlFragment(config.html))
			else if config.haml?
				errorCallback("You must include haml-js for haml support") if !Haml?
				html = Haml.render(config.haml.replace(/\t/g, "  "))
				applyStyles(ko.utils.parseHtmlFragment(html))
			else
				errorCallback("You must specify an element id or a markup")


	## UTILS
	
	ko.utils.appendNodeDataBind = (node, bind)->
		db = node.getAttribute('data-bind')
		if db?
			node.setAttribute('data-bind', "#{db}, #{bind}")
		else
			node.setAttribute('data-bind', bind)
				
	
	ko.absorbModel = (data, self) ->
		for prop, val of data
			continue if typeof(val) == "function"
			if !self[prop]?
				if self.submodels? && self.submodels[prop]?
					# add submodel
					ko.addSubModel(prop, self.submodels[prop], self)
					self[prop].handleData(val)
				else
					# add regular observable
					self[prop] = ko.observable(val)
			else if (typeof(self[prop].handleData) == "function")
				self[prop].handleData(val)
			else
				self[prop](val)
			self.fields.pushOnce(prop)
		self.model_state(ko.modelStates.READY)

	ko.addFields = (fields, val, self) ->
		for prop in fields
			ko.addField prop, val, self

	ko.addField = (field, val, valid_fn, self) ->
		if !self?
			self = valid_fn
			valid_fn = null
		if (typeof(self[field]) != "function")
			if (val instanceof Array)
				self[field] = ko.observableArray()
			else
				self[field] = ko.observable(val)

			self["#{field}_valid"] = ko.computed( (-> (valid_fn.bind(self))(self[field]())), self) if valid_fn?
		else
			self[field](val)
		if (typeof(field) == "string")
			self.fields.pushOnce(field)
	
	ko.addComputed = (field, fn_opts, self) ->
		opts = {}
		if QS.utils.isFunction(fn_opts)
			opts = {read: fn_opts}
		else
			opts = fn_opts
		opts.owner = self
		opts.deferEvaluation = true
		self[field] = ko.computed opts, self
	
	ko.validate_for = (field, fn, msg, self) ->
		self.validations = {} unless self.validations?
		self.validations[field] = [] unless self.validations[field]?
		self.validations[field].push {test : fn.bind(self), msg : msg}
		self[field].is_valid = ko.computed ->
			valid = true
			for val_obj in self.validations[field]
				valid &&= val_obj.test(self[field]())
			valid
		, self unless self[field].is_valid?


	ko.validate_fields = (fields, fn, self) ->
		msgs = []
		for field in fields
			for val_obj in self.validations[field]
				if !val_obj.test(self[field]())
					msgs.push val_obj.msg
		fn(msgs)

	ko.addSubModel = (field, model, self) ->
		if self[field]?
			self[field].reset()
		else
			self[field] = new model({}, self, {is_submodel : true})
		self.fields.pushOnce(field) if typeof(field) == "string"

	ko.intercepter = (observable, write_fn, self) ->
		underlying_observable = observable
		return ko.dependentObservable
			read: underlying_observable,
			write: (val) ->
				if (val != underlying_observable())
					write_fn.call(self, underlying_observable, underlying_observable(), val)

	ko.dirtyFlag = (root, isInitiallyDirty) ->
			result = ->
			_initialState = ko.observable(ko.toJSON(root))
			_isInitiallyDirty = ko.observable(isInitiallyDirty)

			result.isDirty = ko.dependentObservable ->
				return _isInitiallyDirty() || (_initialState() != ko.toJSON(root))

			result.reset = ->
				_initialState(ko.toJSON(root))
				_isInitiallyDirty(false)

			return result

	ko.copyObject = (obj, fields) ->
		ret = {}
		for prop in fields
			ret[prop] = obj[prop]
		return ret

	ko.addTemplate = (templateName, templateMarkup) ->
		$('head').append("<script type='text/html' id='" + templateName + "'>" + templateMarkup + "<" + "/script>")

	ko.modelStates = {}
	ko.modelStates.READY = 1
	ko.modelStates.LOADING = 2
	ko.modelStates.SAVING = 3
	ko.modelStates.EDITING = 4
	ko.modelStates.INSERTING = 5
	ko.modelStates.APPENDING = 6
	ko.modelStates.UPDATING = 7
	ko.editors = {}

jQuery.fn.extend
	to_s : ->
		$('<div>').append(this.clone()).remove().html()
	center : ->
		this.css("position","absolute")
		this.css("top", (($(window).height() - this.outerHeight(true)) / 2) + $(window).scrollTop() + "px")
		this.css("left", (($(window).width() - this.outerWidth(true)) / 2) + $(window).scrollLeft() + "px")
		return this
	koBind : (viewModel) ->
		this.each ->
			$(this).koClean()
			#$(this).attr('data-bind', "template : '#{tmpl}'") if tmpl?
			ko.applyBindings(viewModel, this)
	koClean : ->
		this.each ->
			#$(this).removeAttr('data-bind')
			ko.cleanNode(this)

