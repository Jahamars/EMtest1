sudo cp tm.sh /usr/local/bin/
sudo cp tm.service /etc/systemd/system/
sudo cp tm.timer /etc/systemd/system/

sudo chmod +x /usr/local/bin/tm.sh

sudo systemctl daemon-reload
sudo systemctl enable tm.timer
sudo systemctl start tm.timer
