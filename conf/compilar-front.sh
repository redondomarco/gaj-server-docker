#!/bin/bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

cd /
nvm install 10
nvm use 10
npm install -g @angular/cli

#
cd /gaj-frontend/src/tmf-frontend-ui/
npm install

ng serve --host 0.0.0.0