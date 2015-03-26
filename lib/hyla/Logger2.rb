require 'log4r'
require 'log4r/yamlconfigurator'
require 'log4r/outputter/datefileoutputter'
include Log4r

y = "log4r_config:

  # define all loggers ...
  loggers:
    - name      : production
      level     : INFO
      trace     : 'false'
      outputters:
        - stdout
    - name      : development
      level     : DEBUG
      trace     : 'true'
      outputters :
        - datefile

  # define all outputters (incl. formatters)
  outputters:
    - type     : StdoutOutputter
      name     : stdout
      formatter:
        date_pattern: '%Y-%m-%d %H:%M:%S'
        pattern     : '%d %l: #\{TEST\} %m '
        type        : PatternFormatter

    - type     : DateFileOutputter
      name     : datefile
      dirname  : '/Users/chmoulli/Temp/Log'
      filename : 'my_app.log' # notice the file extension is needed!
      formatter:
        date_pattern: '%H:%M:%S'
        pattern     : '%d %l: %m '
        type        : PatternFormatter"

h = YAML.load y
log_cfg = YamlConfigurator
log_cfg['TEST'] = 'foobar'
log_cfg.decode_yaml h['log4r_config']
@log = Logger['development']
@log.info 'test'
