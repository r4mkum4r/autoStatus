gulp    	= 	require 'gulp'
watch 		= 	require 'gulp-watch'
sequence 	= 	require 'gulp-run-sequence'
inject 		= 	require 'gulp-inject'
_ 			= 	require 'lodash'
args		= 	require('yargs')
					.alias('coffee', 'coffee-script')
					.alias('styl', 'stylus')
					.boolean(['coffee', 'stylus', 'less', 'sass'])
					.default('port', 8001)
					.argv
spawn		= 	require('child_process').spawn
exec		= 	require('child_process').exec
path 		= 	require 'path'
coffee 		= 	require 'gulp-coffee'
less 		= 	require 'gulp-less'
sass 		= 	require 'gulp-sass'
stylus 		= 	require 'gulp-stylus'
clean 		= 	require 'gulp-clean'
nib 		= 	require 'nib'
del 		= 	require 'del'
port 		= 	null
tasks 		= 	null

srcBase 	= 	"src/"
srcBaseJS 	= 	"#{srcBase}js/**/"
srcBaseCSS  = 	"#{srcBase}css/**/"

destBase 	= 	"public/"
destBaseJS 	= 	"#{destBase}javascripts/"
destBaseCSS = 	"#{destBase}stylesheets/"

paths  	= 	{
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

gulp.task 'cleanCSS', ->
	gulp.src paths.dest.css, {read: false}
		.pipe(clean())

gulp.task 'cleanJS', ->
	gulp.src paths.dest.js, {read: false}
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

gulp.task 'inject', ->
	_target  = gulp.src './views/layout.jade'
	_sources = gulp.src(["#{paths.dest.css}", "#{paths.dest.js}"])

	_target
		.pipe inject(_sources,{
			read: false,
			transform : (filepath)->
				filepath = filepath.split('/')
				filepath.splice(1,1)
				filepath = filepath.join('/')
				if filepath.slice(-2) is "js"
					return "script(src=\'#{filepath}\')"
				else
					return "link(rel=\'stylesheet\', href=\'#{filepath}\')"
		})
		.pipe gulp.dest "./views/"

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

	gulp.watch "#{destBase}**/*.*", ['inject']


gulp.task 'default', ->
	port  = args.port
	sequence 'coffee', 'stylus', 'inject', 'watch', 'demon'
