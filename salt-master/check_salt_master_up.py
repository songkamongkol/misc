# -- check_salt_master_up.py
# --
# -- Check salt-master health and update node-exporter
# -- salt file accordingly (1=All ok, 0=problem)
# --

import sys
import subprocess
import json

def update_salt(status):
    outfile = open(salt_file , "w")
    outfile.write("# HELP service_status [0|1]\n")
    outfile.write("# TYPE service_status gauge\n")
    outfile.write("service_status{service=\"salt-master-minions-connection\"} %s\n" % str(status))
    outfile.close()

# -- main
salt_file = sys.argv[1]
TOTAL_MINIONS_COUNT = 24
saltkey_output = subprocess.check_output(['salt-key', '--output=json'])
saltkeys = json.loads(saltkey_output)

if len(saltkeys['minions']) < 24:
    update_salt(0)
else:
    update_salt(1)
