all: mydaemon mydaemond.service
.PHONY: all mydaemon install uninstall clean

service_dir=/etc/systemd/system
awk_script='BEGIN {FS="="; OFS="="}{if ($$1=="ExecStart") {$$2=exec_path} if (substr($$1,1,1) != "\#") {print $$0}}'

mydaemon: myscript.py setup.py
	pip install .

mydaemond.service: myscript.py
# awk is needed to replace the absolute path of mydaemon executable in the .service file
	awk -v exec_path=$(shell which mydaemon) $(awk_script) mydaemond.service.template > mydaemond.service

install: $(service_dir) $(conf_dir) schedulerd.service scheduler.conf.yml
	cp mydaemond.service $(service_dir)

uninstall:
	-systemctl stop mydaemond
	-rm -r $(service_dir)/mydaemond.service

clean:
	-rm mydaemond.service
