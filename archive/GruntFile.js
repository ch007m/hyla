module.exports = function (grunt) {

    // Nodes packages
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-shell');
    grunt.loadNpmTasks('grunt-config');

    // Retrieve Module & Mode from command line options
    var MODULE = grunt.option('module') || 'A';
    var MODE = grunt.option('mode') || 'LMSClass';
    var THEME = grunt.option('css') || 'my_theme.css';
    var BACKEND = grunt.option('backend') || 'html5';
    var BACKEND_DIR;

    var TARGET_DIR = '.';
    var GENERATED_DIR = TARGET_DIR + "/content/" + MODULE
    var SOURCE_DIR = MODULE;

    grunt.initConfig({
        shell: {
            run_asciidoctor: {
                // Options
                options: {
                    stdout: true
                },
                command:
                        'asciidoctor'
                                + ' -b ' + BACKEND
                                + ' -a embedAssets'
                                + ' ' + SOURCE_DIR + '/' + '<%= grunt.config.get("asciidocFile") %>'
                                + ' --out-file ' + GENERATED_DIR + '/' + '<%= grunt.config.get("fileName") %>' + '.html'
            }
        },
        watch: {
            asciidoc: {
                files: [SOURCE_DIR + '/*.txt', SOURCE_DIR + '/*.adoc'],
                tasks: ["shell:run_asciidoctor"],
                options: {
                    nospawn: true
                }
            },
            livereload: {
                files: [GENERATED_DIR + '/*.html'],
                tasks: [],
                options: {
                    livereload: true,
                    spawn: false
                }
            }

        }
    });

    // on watch events configure asciidoctor to only run on changed file
    grunt.event.on('watch', function(action, filePath) {

        // Split string receive to get only FileName
        tokens = filePath.split('/');
        // Remove file extension
        fileName = tokens[1].substr(0, tokens[1].lastIndexOf('.'));

        grunt.verbose.writeln("File Path received : " + filePath);
        grunt.verbose.writeln("Asciidoc FileName : " + tokens[1]);
        grunt.verbose.writeln("FileName without extension : " + fileName);

        grunt.config.set('asciidocFile', tokens[1])
        grunt.config.set('fileName', fileName)

        grunt.task.run('shell:run_asciidoctor');
    });

};