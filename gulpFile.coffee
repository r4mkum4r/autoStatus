gulp    = 	require 'gulp'
watch 	= 	require 'gulp-watch'
sequence = 	require 'gulp-run-sequence'
inject 	= 	require 'gulp-inject'
_ 			= 	require 'lodash'
args		= 	require('yargs')
					.alias('coffee', 'coffee-script')
					.alias('styl', 'stylus')
					.boolean(['coffee', 'stylus', 'less', 'sass'])
					.default('port', 8001)
					.argv
spawn		= 	require('child_process').spawn
path 		= 	require 'path'
coffee 	= 	require 'gulp-coffee'
less 		= 	require 'gulp-less'
sass 		= 	require 'gulp-sass'
stylus 	= 	require 'gulp-stylus'
clean 	= 	require 'gulp-clean'
nib 		= 	require 'nib'
del 		= 	require 'del'
port 		= 	null
tasks 	= 	null

srcBase 		= 	"src/"
srcBaseJS 	= 	"#{srcBase}js/**/"
srcBaseCSS  = 	"#{srcBase}css/**/"

destBase 		= 	"dest/"
destBaseJS 	= 	"#{destBase}js/**/"
destBaseCSS = 	"#{destBase}css/**/"

paths  	= 	{
	src :
		js 		 : "#{srcBaseJS}*.js"
		coffee : "#{srcBaseJS}*.coffee"
		css 	 : "#{srcBaseCSS}*.css"
		stylus : "#{srcBaseCSS}*.styl"
		less 	 : "#{srcBaseCSS}*.less"
		sass 	 : "#{srcBaseCSS}*.scss"
	dest :
		js : "#{destBaseJS}*.js"
		css: "#{destBaseCSS}*.css"
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
		.pipe gulp.dest("#{destBase}js/")

gulp.task 'coffee', ['cleanJS'],->
	gulp.src paths.src.coffee
		.pipe(coffee({bare:true}))
		.pipe(gulp.dest("#{destBase}js/"))

gulp.task 'css', ['cleanCSS'], ->
	gulp.src paths.src.css
		.pipe gulp.dest("#{destBase}css/")

gulp.task 'stylus', ['cleanCSS'], ->
	gulp.src paths.src.stylus
		.pipe(stylus({use: nib()}))
		.pipe(gulp.dest("#{destBase}css/"))

gulp.task 'less', ['cleanCSS'], ->
	gulp.src paths.src.less
		.pipe(less({
			paths : [path.join __dirname, 'src/css/']
		}))
		.pipe(gulp.dest("#{destBase}css/"))

gulp.task 'sass', ['cleanCSS'], ->
	gulp.src paths.src.sass
		.pipe(sass())
		.pipe(gulp.dest("#{destBase}css/"))

gulp.task 'inject', ->
	_target  = gulp.src 'index.html'
	_sources = gulp.src ["#{paths.dest.css}", "#{paths.dest.js}"], {read: false}

	_target
		.pipe inject(_sources, { addRootSlash : true})
		.pipe gulp.dest "./"

gulp.task 'demon', ->
	port    = port || args.port
	python  = spawn 'python', ["-m", "SimpleHTTPServer", "#{port}"], { stdio : 'inherit', stderr: 'inherit'}

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
	sequence 'js', 'css', 'inject', 'watch', 'demon'
