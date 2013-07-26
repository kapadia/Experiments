express = require('express')
http = require('http')
RedisStore = require('connect-redis')(express)

passport = require('passport')
TwitterStrategy = require('passport-twitter').Strategy

PORT = 8000

app = express()
server = http.createServer(app)
server.listen(PORT)

app.use(express.cookieParser())
app.use(express.session({
  store: new RedisStore({
    host: 'localhost',
    port: process.env.REDIS_PORT,
    db: process.env.REDIS_DB,
    pass: process.env.REDIS_PASS
  })
  secret: 'asdf'
}))

TWITTER_REQUEST_TOKEN_URL = "https://twitter.com/oauth/request_token"
TWITTER_ACCESS_TOKEN_URL = "https://twitter.com/oauth/access_token"
TWITTER_CONSUMER_KEY = process.env.TWITTER_CONSUMER_KEY
TWITTER_CONSUMER_SECRET = process.env.TWITTER_CONSUMER_SECRET

passport.use(new TwitterStrategy({
    consumerKey: TWITTER_CONSUMER_KEY,
    consumerSecret: TWITTER_CONSUMER_SECRET
    callbackURL: "/success"
  },
  (token, tokenSecret, profile, done) ->
    console.log "token", token
    console.log "tokenSecret", tokenSecret
    console.log "profile", profile
    console.log "done", done
))


app.get "/", (req, res) ->
  res.send "Hello World"

app.get "/success", (req, res) ->
  res.send "Success!"

app.get "/failure", (req, res) ->
  res.send "Failure."

app.get("/auth/twitter", passport.authenticate('twitter'))

app.get('/auth/twitter/callback', passport.authenticate('twitter', {
    successRedirect: '/success',
    failureRedirect: '/failure'
  }))