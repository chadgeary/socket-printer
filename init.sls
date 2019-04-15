{% if grains['host'] == 'printserver.chadg.net' %}

perlpkgs:
  pkg.installed:
    - pkgs:
      - cups
      - perl-IO-Socket-IP
      - perl-IO-Socket-SSL

/etc/systemd/system/socket-printer.service:
  file.managed:
    - backup: minion
    - source: salt://socket-printer/socket-printer.service
    - template: jinja
    - mode: 750
    - user: root
    - group: root
  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: /etc/systemd/system/socket-printer.service

/usr/local/bin/socket-printer.pl:
  file.managed:
    - backup: minion
    - source: salt://socket-printer/socket-printer.pl
    - mode: 770
    - user: root
    - group: wheel

/usr/local/bin/printer-filter.pl:
  file.managed:
    - backup: minion
    - source: salt://socket-printer/printer-filter.pl
    - template: jinja
    - mode: 770
    - user: root
    - group: wheel

cups_running:
  service.running:
    - name: cups
    - enable: True

lpadmin -p rpmr -E -v socket://localhost:9100 -m raw && systemctl restart cups:
  cmd.run

socket-printer_running:
  service.running:
    - name: socket-printer
    - watch:
      - module: /etc/systemd/system/socket-printer.service

/usr/bin/perl /usr/local/bin/printer-filter.pl:
  cron.present:
    - user: root
    - minute: '*/5'

{% endif %}
