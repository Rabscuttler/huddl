# huddl

A tool for co-created gatherings

## For Devs

To run locally, make sure you have **ruby** installed and an instance of **mongodb**, then: 


```
gem install bundle foreman
bundle install
cp .env.example .env
```
Now set ```DOMAIN=localhost``` in your newly created .env file. Then:
```
foreman run bundle exec padrino s
```

Launches the app at **localhost:3000**