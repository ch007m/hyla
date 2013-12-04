module.exports = function (grunt) {

    // Nodes packages
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-shell');
    grunt.loadNpmTasks('grunt-config');

    // Retrieve Module & Mode from command line options
    var MODULE = grunt.option('module') || 'A';
    var MODE = grunt.option('mode') || 'LMSClass';
    var THEME = grunt.option('css') || 'gpe_theme.css';
    var BACKEND = grunt.option('backend') || 'html5';
    var BACKEND_DIR;

    var TARGET_DIR = 'target';
    var GENERATED_DIR = TARGET_DIR + "/content/" + MODE + "/" + MODULE
    var SOURCE_DIR = MODULE + '/' + 'docs';
    var CSS_FILE = GENERATED_DIR + '/css/' + THEME;

    if (BACKEND === 'html5') {
        BACKEND_DIR = MODULE + '/' + TARGET_DIR + '/maven-shared-archive-resources/asciidoctor-backend/haml/html5';
    } else {
        BACKEND_DIR = MODULE + '/' + TARGET_DIR + '/maven-shared-archive-resources/asciidoctor-backend/haml/dzslides';
    }


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
                                + ' -T ' + BACKEND_DIR
                                + ' -a embedAssets'
                                + ' -a stylesheet=' + CSS_FILE
                                + ' ' + SOURCE_DIR + '/' + '<%= grunt.config.get("asciidocFile") %>'
                                + ' --out-file ' + GENERATED_DIR + '/' + '<%= grunt.config.get("fileName") %>' + '.html'
            }
        },
        watch: {
            asciidoc: {
                files: [SOURCE_DIR + '/*.txt'],
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
        fileName = tokens[2].split('.').slice(0,1)

        grunt.log.debug("File Path received : " + filePath);
        grunt.log.debug("Asciidoc FileName : " + tokens[2]);
        grunt.log.debug("FileName without extension : " + fileName);

        grunt.config.set('asciidocFile', tokens[2])
        grunt.config.set('fileName', fileName)
        grunt.task.run('shell:run_asciidoctor');
    });

};