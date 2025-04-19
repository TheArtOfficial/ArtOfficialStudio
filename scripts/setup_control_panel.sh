#!/bin/bash

echo "Setting up Control Panel..."

# Create directory for the control panel
cd /control_panel

# Create virtual environment
python3.12 -m venv control_panel_venv
./control_panel_venv/bin/pip install --upgrade pip
./control_panel_venv/bin/pip install flask flask_wtf wtforms gunicorn gevent requests dotenv -qq

# Start Control Panel
cd /control_panel && ./control_panel_venv/bin/python app.py --port 1000 &
echo "Control Panel started"