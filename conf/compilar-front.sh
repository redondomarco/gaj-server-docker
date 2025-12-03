#!/bin/bash

#export NVM_DIR="$HOME/.nvm"
#[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
#[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
#cd /

#nvm use 20
#npm install -g @angular/cli

#nvm install 10
#nvm use 10

#cd /
#npm install -g @angular/cli

#cd /gaj-frontend/src/tmf-frontend-ui/
#npm install

#ng serve --host 0.0.0.0

cd /gaj-frontend/src/tmf-frontend-ui/
npm install --legacy-peer-deps
npm install -g @angular/cli
npm install @angular/cli
ng serve --host 0.0.0.0 --env=prod
