# GPE Maven Training Project

The goal of this maven training archetype is to generate a skeleton of a training course containing one module in order to :

- Automate the build process of GPE training material (exercises, content) from asciidoc documents to HTML used by LMS system
- Generate Slideshows for instructors
- Test modifications done live with the asciidoc documents using 'live reload' and your browser

To create the skeleton of the project, we will use GPE `hyla`project

The [`hyla` name](http://en.wikipedia.org/wiki/Tree_frog) comes from a beautifull tree frog living in tropical regions (Eurasia, America).

![Tree Frog](http://upload.wikimedia.org/wikipedia/commons/thumb/4/4a/Red-eyed_tree_frog_Lapa_Rios.JPG/220px-Red-eyed_tree_frog_Lapa_Rios.JPG)

This project contains the resources (css, js, asciidoctor backends, iamges) used to perform rendering of asciidoc pages but also
definition and version of maven plugins used and of course a template which is a maven archetype. There are 3 modules

- parent : is the Bill of Materials (BOM) containing properties, version of the plugins, dependencies
- common : asciidoc resources files, banner and footer, CSS stylesheets, javascripts, asciidoctor backends (HTML5, deckjs)
- tooling : maven training archetype

## Pre-requisites

The following software must be installed previously on your machine :

- [Apache Maven : 3.0.2](http://maven.apache.org)
- [Ruby : >= 1.9.3](https://www.ruby-lang.org/en/) - Ruby is installed b y default on the MacOS
- [Asciidoctor : >= 0.1.14](http://asciidoctor.org/docs/install-asciidoctor-macosx/)`

As asciidoctor (which is a Ruby application) depends on the following projects/depdencies to work with the templates/backends (document, section, blocks, ...)
[tilt](https://github.com/rtomayko/tilt/), [haml](http://haml.info/), [slim](http://slim-lang.com/) or highlight the code [CodeRay](http://coderay.rubychan.de/),
it is mandatory to install them on your machine. This can be done easily using [gem](http://rubygems.org/) ruby tool with the command gem install`
To simplify the process, a Gemfile has been created (you will find it under the root location of the project created from maven archetype) to install asciidoctor and
all the required dependencies.

Open a terminal under the directory of the project created using the Hyla Maven Archetype and runs that command

    bundle install

Afetr a few moment, you should see the packages deployed

- [Grunt : > 0.4](http://gruntjs.com/getting-started)

- [Nodejs](http://nodejs.org/download/) - Can be installed using dmg file on MacOS or [howbrew](http://shapeshed.com/setting-up-nodejs-and-npm-on-mac-osx/)
- [Node Package Manager](http://shapeshed.com/setting-up-nodejs-and-npm-on-mac-osx/)

- [Google Chrome LiveReload](https://chrome.google.com/webstore/detail/livereload/jnihajbhpnppcggbcgedagnkighmdlei)

OPTIONAL :
- [Asciidoc : 8.6.2](http://www.methods.co.nz/asciidoc/INSTALL.html)
- [Pygments - Syntax Highlighter](http://asciidoctor.org/docs/user-manual/#pygments-installation) or use that link (http://www.andrewhavens.com/posts/13/how-to-install-pygments-syntax-highlighter-using-homebrew)

## Instructions

### Project Hyla

  Clone Project Hyla and compile/install it in your local Maven Repo

    git clone rhKerberosUsername@file.rdu.redhat.com:/mnt/share/PartnerTraining/mw/hyla

  Jump to the hyla git directory and compile/install the project into your local maven repository

    cd hyla
    mvn install

### Create a new Training Course

1) Create a project from Archetype

  For this test, the project is called ActiveMQ and corresponds to a GPE ActiveMQ Training with a module A

    mvn archetype:generate -DarchetypeGroupId=com.redhat.gpe.hyla -DarchetypeArtifactId=training-project-archetype -DarchetypeVersion=1.0-SNAPSHOT -DgroupId=com.redhat.gpe.training -DartifactId=activemq -Dversion=1.0-SNAPSHOT -Dpackage=com.redhat.training.gpe.activemq -Dtraining-name=ActiveMQ -Dtraining-code=activemq -DinteractiveMode=false

2) Move next to directory corresponding of your peoject name `activemq by example`

3) Generate LMS Content

  Run this maven command to generate from documents defined under directory `activemq/modulesA/docs` the HTML pages that
  you will retrieve under `activemq/modules/target/generated-docs/LMSClass`directory. LMS profile corresponds to the Learning content used by the students
  and pushed on Dokeos (Learning Management System)

    mvn package -P LMS

  Open one of the HTML page in your browser (activemq/modules/target/generated-docs/LMSClass/A/new_proj_administration.html).

4) Generate ILT content (slideshow)

  Run the following maven command to generate one HTML/Slideshow page containing all the slides.
  The asciidoc page used to generate this slideshow is called `activemq/modules/A/docs/new_project_AllSlides.index`. Profile ILT refers to
  Instructor Slides.

    mvn package -P ILT

  Open the page `new_project_AllSlides.html` created under `activemq/modules/target/generated-docs/ILTClass/A/new_project_AllSlides.html`

  Click on 'm' key to access all the slides, 'g' to go to a specific slide, 't' to display table of content, 'b' to show a blank page

5) Generate distribution (optional when developing content)

  A) Content

    mvn clean install -P content-distro

  B) Code

    mvn clean install -P code-distro


### Use Grunt tool to watch files to be rendered in HTML and load it live in your browser

1) Move to the `modules` directory of the newly created maven training project

2) Install Grunt, Grunt-cli and packages required

The first time that you will Grunt, you must install previously `nodejs` and package manager `npm` (see pre-requisite).
Next you can deploy the packages

    npm install -g grunt-cli
    npm install grunt
    npm install grunt-contrib-watch
    npm install grunt-shell
    npm install grunt-config

3) Open 2 Mac/Unix terminals

    grunt watch:asciidoc --module A --mode LMSClass --css my_theme.css --backend html5 --verbose

    TODO // Finalize this task
    grunt watch:asciidoc --module A --mode ILTClass --backend dzslides --verbose

and reload them automatically

    grunt watch:livereload --verbose

Remarks :

  * After each `mvn clean` a `mvn package` must be done to at least copy resources which are used
  * `module A` should be renamed according to your module name
  * LMS is only supported until now. Not slideshow

Enjoy !








