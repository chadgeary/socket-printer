# reference
Runs a socket service (shared as 'printer' via cups) that application users print to.  
The socket redirects to a file. Every 5 minutes, a cron runs to rename the file based on headers, then FTP and transfer to NFS.  

# salt

- pillar
```
# salt pillar implementation (chadftppw)

# paste command(s), type (or paste) password, then hit RETURN
{ stty -echo; head -n 1; stty echo; } | sudo /usr/bin/gpg --armor --batch --trust-model always --encrypt -r 'saltmaster@saltmaster' | sudo tee /srv/pillar/chadftppw.sls

# format sls file for jinja/yaml/gpg
sudo sed -i -e 's/^/  /' /srv/pillar/chadftppw.sls
sudo sed -i -e '1i chadftppw: |' /srv/pillar/chadftppw.sls
sudo sed -i -e '1s/^/\n/' /srv/pillar/chadftppw.sls
sudo sed -i -e '1i #!jinja|yaml|gpg' /srv/pillar/chadftppw.sls

# assign via /srv/pillar/top.sls file
```

- initial  
```
sudo git clone https://github.com/chadgeary/socket-printer.git /srv/salt/socket-printer
```

- update  
```
cd /srv/salt/socket-printer/ && sudo git pull https://github.com/chadgeary/socket-printer.git master
```

- deploy  
```
sudo salt 'printserver.chadg.net' state.sls socket-printer
```
