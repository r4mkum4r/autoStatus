gulp    	= 	require 'gulp'
watch 		= 	require 'gulp-watch'
sequence 	= 	require 'gulp-run-sequence'
inject 		= 	require 'gulp-inject'
_ 				= 	require 'lodash'
args			= 	require('yargs')
								.alias('coffee', 'coffee-script')
								.alias('styl', 'stylus')
								.boolean(['coffee', 'stylus', 'less', 'sass'])
								.default('port', 8001)
								.argv
spawn			= 	require('child_process').spawn
exec			= 	require('child_process').exec
fs 				= 	require 'fs'
path 			= 	require 'path'
coffee 		= 	require 'gulp-coffee'
less 			= 	require 'gulp-less'
sass 			= 	require 'gulp-sass'
stylus 		= 	require 'gulp-stylus'
clean 		= 	require 'gulp-clean'
concat 		= 	require 'gulp-concat'
nib 			= 	require 'nib'
del 			= 	require 'del'
mainBowerFiles	= 	require 'main-bower-files'
port 			= 	null
tasks 		= 	null

srcBase 		= 	"src/"
srcBaseJS 	= 	"#{srcBase}js/**/"
srcBaseCSS  = 	"#{srcBase}css/**/"

destBase 		= 	"public/"
destBaseJS 	= 	"#{destBase}javascripts/"
destBaseCSS = 	"#{destBase}stylesheets/"

vendorsPathJS = 	"#{destBase}/vendors/javascripts/"
vendorsPathCSS = 	"#{destBase}/vendors/stylesheets/"

paths  			= 	{
	src :
		js 		: "#{srcBaseJS}*.js"
		coffee	: "#{srcBaseJS}*.coffee"
		css 	: "#{srcBaseCSS}*.css"
		stylus	: "#{srcBaseCSS}*.styl"
		less 	: "#{srcBaseCSS}*.less"
		sass 	: "#{srcBaseCSS}*.scss"
	dest :
		js 		: "#{destBaseJS}**/*.js"
		css		: "#{destBaseCSS}**/*.css"
	vendors :
		js : "#{vendorsPathJS}**/*.js"
		css : "#{vendorsPathJS}**/*.css"
}

availTasks 		= ['coffee', 'stylus', 'less', 'sass', 'js', 'css']
defaultTasks	= ['demon', 'js', 'css', 'watch']

getTasks = (args)->
	_tasks = []
	_.forOwn args, (value, key)->
		if value is true
			task = _.findWhere(availTasks, key)
			if task
				_tasks.push task

	_.uniq _tasks

getIncludes = ->
	fs.readFileSync('includes.json', {
		encoding : 'utf8'
	})

getPath = (path)->
	_path = path.split('/')
	_path.splice(1,1)

	return _path.join('/')

gulp.task 'cleanCSS', ->
	gulp.src paths.dest.css, {read: false}
		.pipe(clean())

gulp.task 'cleanJS', ->
	gulp.src paths.dest.js, {read: false}
		.pipe(clean())

gulp.task 'cleanVendor:js', ->
	gulp.src paths.vendors.js, {read: false}
		.pipe(clean())

gulp.task 'cleanVendor:css', ->
	gulp.src paths.vendors.css, {read: false}
		.pipe(clean())

gulp.task 'js', ['cleanJS'], ->
	gulp.src paths.src.js
		.pipe gulp.dest("#{destBaseJS}")

gulp.task 'coffee', ['cleanJS'],->
	gulp.src paths.src.coffee
		.pipe(coffee({bare:true}))
		.pipe(gulp.dest("#{destBaseJS}"))

gulp.task 'css', ['cleanCSS'], ->
	gulp.src paths.src.css
		.pipe gulp.dest("#{destBaseCSS}")

gulp.task 'stylus', ['cleanCSS'], ->
	gulp.src paths.src.stylus
		.pipe(stylus({use: nib()}))
		.pipe(gulp.dest("#{destBaseCSS}"))

gulp.task 'less', ['cleanCSS'], ->
	gulp.src paths.src.less
		.pipe(less({
			paths : [path.join __dirname, 'src/css/']
		}))
		.pipe(gulp.dest("#{destBaseCSS}"))

gulp.task 'sass', ['cleanCSS'], ->
	gulp.src paths.src.sass
		.pipe(sass())
		.pipe(gulp.dest("#{destBaseCSS}"))

gulp.task 'inject:author', ->
	_target  = gulp.src './views/layout.jade'
	_sources = gulp.src(["#{paths.dest.css}", "#{paths.dest.js}"], read: false)

	_target
		.pipe inject(_sources,{
			transform : (filepath)->
				filepath = getPath(filepath)
				if filepath.slice(-2) is "js"
					return "script(src=\'#{filepath}\')"
				else
					return "link(rel=\'stylesheet\', href=\'#{filepath}\')"
		})
		.pipe gulp.dest "./views/"

gulp.task 'inject:vendor', ->
	_target  = gulp.src './views/layout.jade'
	_includes = JSON.parse(getIncludes()).deps

	gulp.src(_includes)
		.pipe(concat('vendors.js'))
		.pipe(gulp.dest(vendorsPathJS))

	_sources = gulp.src(paths.vendors.js, {read: false})

	_target
		.pipe inject(_sources,{
			name : 'vendor',
			transform : (filepath)->
				filepath = getPath(filepath)
				if filepath.slice(-2) is "js"
					return "script(src=\'#{filepath}\')"
				else
					return "link(rel=\'stylesheet\', href=\'#{filepath}\')"
		})
		.pipe gulp.dest './views'


gulp.task 'inject', ->
	sequence 'cleanVendor:js', 'inject:vendor', 'inject:author'


gulp.task 'demon', ->
	port    = port || args.port
	python  = spawn 'node', ["app.js"], { stdio : 'inherit', stderr: 'inherit'}

	exec("open http://localhost:3000")

gulp.task 'watch', ->
	gulp.watch paths.src.js, ['js']
	gulp.watch paths.src.coffee, ['coffee']
	gulp.watch paths.src.css, ['css']
	gulp.watch paths.src.less, ['less']
	gulp.watch paths.src.stylus, ['stylus']
	gulp.watch paths.src.sass, ['sass']

	# gulp.watch "#{destBase}**/*.*", ['inject']


gulp.task 'default', ->
	port  = args.port
	sequence 'coffee', 'stylus', 'inject', 'watch', 'demon'
