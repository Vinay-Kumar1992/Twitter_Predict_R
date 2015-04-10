#From Pablo Barbera's blog:http://pablobarbera.com/blog/archives/1.html
#Enter your own values for the twitter consumerKey and consumerSecret
library(ROAuth)
requestURL <- "https://api.twitter.com/oauth/request_token"
accessURL <- "https://api.twitter.com/oauth/access_token"
authURL <- "https://api.twitter.com/oauth/authorize"
consumerKey <- "6q9WsRgjXkcznLQ3hhvm22aZe"
consumerSecret <- "3CJDLOi3Ob8ES2bgm8i5vQvQSyf4HQBFEZsbGVsvPOuUbVJC6q"
my_oauth <- OAuthFactory$new(consumerKey = consumerKey, consumerSecret = consumerSecret, 
                             requestURL = requestURL, accessURL = accessURL, authURL = authURL)
my_oauth$handshake(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl"))
save(my_oauth, file = "my_oauth.Rdata")