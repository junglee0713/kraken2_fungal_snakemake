#!/bin/bash
DBNAME="/scr1/users/leej39/kraken2_db/fungi_20200130"
kraken2-build --download-library fungi --db $DBNAME --use-ftp
