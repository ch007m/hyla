module Hyla
  class Configuration

    attr_reader :HEADER, :INDEX_SUFFIX, :HEADER_INDEX, :INCLUDE_PREFIX, :INCLUDE_SUFFIX, :LEVEL_1, :LEVEL_2, :SKIP_CHARACTERS,
                :ADOC_EXT, :PREFIX_ARTEFACT, :LOC_ARTEFACT

    def initialize()

      @INCLUDE_PREFIX = 'include::'
      @INCLUDE_SUFFIX = '[]'

      @INDEX_SUFFIX = '_AllSlides.index'

      @HEADER = ":data-uri:\n" +
                ":icons: font\n" +
                ":last-update-label!:\n" +
                ":source-highlighter: coderay\n" +
                ":toc: left\n" +
                "\n"

      @HEADER_INDEX = ":data-uri:\n" +
                      ":navigation:\n" +
                      ":menu:\n" +
                      ":status:\n" +
                      "\n"

      @LEVEL_1 = '= '

      @LEVEL_2 = '== '

      @SKIP_CHARACTERS = '>>'

      @ADOC_EXT = '.adoc'

      @PREFIX_ARTEFACT  = 'asciidoc_'

      @LOC_ARTEFACT = '../lib/templates/sample'

    end

  end # Class Artefact
end # module Hyla