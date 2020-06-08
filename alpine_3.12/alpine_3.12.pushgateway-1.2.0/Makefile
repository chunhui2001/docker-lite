
### 当前 Makefile 文件物理路径
ROOT_DIR	:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

rand 		:=$$RANDOM

metrics2:="\
"\#" TYPE gaugesome_metric counter\n\
gaugesome_metric $(rand)\n\
"\#" HELP awesomeness_total How awesome is this article.\n\
"\#" TYPE awesomeness_total counter\n\
awesomeness_total $(rand)"

simple2:
	echo 'some_metric{foo="bar"} 3.14' | curl --data-binary @- http://localhost:9091/metrics/job/metricfire/instance/article

simple3:
	echo $(metrics2) | curl --data-binary @- http://localhost:9091/metrics/job/metricfire/instance/article

random:
	echo $(metrics2)

