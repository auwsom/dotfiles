#!/bin/bash
source /root/.env
mail -s "email test on: $(hostname)" $EMAIL <<< "email test"
