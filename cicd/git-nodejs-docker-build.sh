
#!/bin/bash
cicddir=/root
appdir=/root/docker/front
gitapirepo="https://USER:GITAPI@github.com/USER/REPO"

cd $appdir && git pull "$gitapirepo" > $cicddir/cicd.log


if grep -q "Already up to date" $cicddir/cicd.log
  then echo "Build skipped."
else
  echo "Find changes, doing rebuild"
  docker rm frontend -f 
  docker rmi front_frontend
  cd  $appdir && docker-compose up -d
  fi

