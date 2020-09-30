express = require "express"
app = express()
session = require "express-session"
GitHubPassPort = require "passport-github2"
passport = require "passport"

Strategy = GitHubPassPort.Strategy


checkAuth = (req, res, next) ->
    if req.isAuthenticated
        next()
    else
         res.redirect "/auth"

checkAuthAn = (req, res, next) ->
    if !req.isAuthenticated
        next()
    else
         res.redirect "/logout"

app.set "view engine", "ejs"

passport.serializeUser (user, done) ->
    done(null, user)
passport.deserializeUser (obj, done) ->
    done(null, obj)

passport.use new Strategy {
    clientID: "98d2eca7b51bfe8f59b7",
    clientSecret: "e6f7fc32f63c7f2d1132ad6eeb41ce0e6c323612",
    callbackURL: "http://localhost:8080/auth/callback"
}, (accessToken, refreshToken, profile, done) ->
    process.nextTick() ->
        done null, profile

app.use session {
    secret: "githb-secret-mueueueu",
    resave: true,
    saveUninitialized: true
}

app.use passport.initialize()
app.use passport.session()

app.get "/", (req, res) ->
    if !req.user
        res.send "You are not logged in, go to /login"
    else
         res.render "index", { req }

app.get "/login", checkAuth

app.get "/logout", checkAuth, (req, res) ->
    req.logout()
    res.redirect "/"

app.get "/auth", checkAuthAn, passport.authenticate "github", { scope: ["user:email"]}
app.get "/auth/callback", passport.authenticate "github", { failureRedirect: "/login" }, (req, res) ->
    res.redirect "/"


listener = app.listen 8080, () ->
    console.log "Express running on #{listener.address().port}"