+++
date = "2016-11-25T01:04:17+01:00"
draft = false
title = "This blog's deployment"
author = "Michael"
+++

This is based on
[“Deploy your blog to github pages automatically using Hugo and Travis”](http://rcoedo.com/post/hugo-static-site-generator/)
by [Roman Coedo](https://github.com/rcoedo).

Start with the hugo setup:
```bash
hugo new site myblog
cd myblog
mkdir public
touch archetypes/.gitkeep data/.gitkeep layouts/.gitkeep public/.gitkeep static/.gitkeep

git init
git remote add origin git@github.com:<owner>/<repo>.git
git add config.toml */.gitkeep

echo "/keys\n/public\n*~" > .gitignore
git add .gitignore
git submodule add https://github.com/tanksuzuki/hemingway.git themes/hemingway
```

Write the first blog post:
```bash
hugo new post/this-blogs-deployment.md
editor post/this-blogs-deployment.md
git add post/this-blogs-deployment.md
```

Create a Github repository and add it as a remote.  Then
[generate a new ssh key](https://help.github.com/articles/generating-ssh-keys/),
store it in `keys` and encrypt it for travis:
```bash
git remote add origin git@github.com:<owner>/<repo>.git
touch .travis.yml
mkdir keys
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
docker run --rm -it -v $(pwd):/code ruby:2.3 bash

docker> gem install travis
docker> cd /code
docker> travis login
docker> travis encrypt-file keys/travis_key --add
docker> exit

sudo chown user:group travis_key
git add travis_key.enc
```

Add the content of `keys/travis_key.pub` as a deploy key: https://github.com/<owner>/<repo>/settings/keys

Also add `.travis.yml`, `Dockerfile` and `scripts/deploy.sh` to the repo (see
this blogs repo for comparison).

```bash
git commit -m "Initial commit"
git push origin master
```
