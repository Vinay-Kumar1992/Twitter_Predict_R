#R interface to the libstemmer librarry
library("SnowballC")
#twitter stream library
library(streamR)
#string library that ensures all functions handle all errors,NAs,etc
library(stringr)
#framework for text mining in R
library(tm)
#provides an interface to MOA(Massive Online Analysis) functionality from R
library(RMOA)

#function to accept current model, new tweet and its correct classification and return the updated model
get_updated_model <- function(mymodel, dtm_row, row_class, i) {
  dtm_df <- as.data.frame(as.matrix(dtm_row))
  dtm_df[i,"label"]= row_class
  datastream <- datastream_dataframe(data=dtm_df)
  mymodel <- trainMOA(model = mymodel, formula=label~., data = datastream, reset = FALSE, trace = TRUE)
  return(mymodel)
}

#function to return the tweets required. Specify the timeout
get_love_hate_tweets <- function(time){
	#Only get those tweets with love or hate in them
	filterStream("new_tweets.json", track = c("love", "hate"), timeout = time, oauth = my_oauth)
	#data frame of tweets from the json file generated
	tweets.df <- parseTweets("new_tweets.json", simplify = TRUE)

	return(tweets.df);
}

#remove excessive white spaces,symbols and return text
get_tweet_text <- function(tweets.df){
	return (data.frame(str_replace_all(train_tweets.df$text,"[^[:graph:]]", " ")))
}

#Twitter AUthentication file that needs to be pregenerated. See file Generate_OAuth_Token.R
load("my_oauth.Rdata")

#data frame of tweets
train_tweets.df=get_love_hate_tweets(10);

#data frame with the text of the tweets
train_tweets_new.df <- get_tweet_text(train_tweets.df);

#function to return the tweet's classification
get_sentiment <- function(x) {
  love <- "love"
  hate <- "hate"
  
  if(str_detect(x, "love")) {
    love 
  }
  else {
    hate
  }
}

#get the classification of each tweet
train_org_class.df <- data.frame(list(apply(train_tweets_new.df, 1, function(x) get_sentiment(tolower(gsub("[()]", "", x))) )))

colnames(train_tweets_new.df)[1]<- c("text")

#remove all mention of "love" from the text
train_tweets_rmvd.df <- data.frame(sapply(train_tweets_new.df$text, function(x) gsub(love, "", tolower(x))))
#remove all mention of "hate from the text"
train_tweets_rmvd.df <- data.frame(sapply(train_tweets_rmvd.df, function(x) gsub(hate, "", tolower(x))))

#data preprocessing
create_and_process_corp <- function(data_frame) {
  
  cs <- Corpus(VectorSource(data_frame[,1]))
  cs<-tm_map(cs, removePunctuation, lazy=FALSE)
  cs<-tm_map(cs, stripWhitespace, lazy=FALSE)
  cs<-tm_map(cs, content_transformer(tolower), lazy=FALSE)
  cs<-tm_map(cs, removeWords, stopwords("english"), lazy=FALSE)
  cs<-tm_map(cs, stemDocument, lazy=FALSE)
  
  return(cs)
}
cs <- create_and_process_corp(train_tweets_rmvd.df[,1]);


tdm <- TermDocumentMatrix(corpus)
m <- as.matrix(tdm)
v <- sort(rowSums(m), decreasing=TRUE)
N <- 75
head(v, N)
features <- names(head(v,N))

tdm_remsparse <- TermDocumentMatrix(corpus, control = list(dictionary = features ))
tdm_remsp_df <- as.data.frame(as.matrix(tdm_remsparse))
tdm_remsp_df <- t(tdm_remsp_df)
tdm_remsp_df <- as.data.frame(tdm_remsp_df)
tdm_remsp_df["label"]= train_org_class.df
trainingdatastream <- datastream_dataframe(data=tdm_remsp_df)

ctrl <- MOAoptions(model = "NaiveBayes")
mymodel <- NaiveBayes(control=ctrl)
#mymodel

myModel <- trainMOA(model = mymodel, formula=label~., data = trainingdatastream, reset = FALSE, trace = TRUE)


test_tweets_rmvd.df <- data.frame(sapply(test_tweets_new.df$text, function(x) gsub("love", "", tolower(x))))
test_tweets_rmvd.df <- data.frame(sapply(test_tweets_rmvd.df, function(x) gsub("hate", "", tolower(x))))

corpus_test <- create_and_process_corp(test_tweets_rmvd.df[,1]);

dtm_test <- DocumentTermMatrix(corpus_test, control = list(dictionary = features))

dtm_test_df <- as.data.frame(as.matrix(dtm_test))
i=1;
nrow(dtm_test_df)
scores = c()
testDataStream = datastream_dataframe(data = dtm_test_df)

while(testDataStream$processed < nrow(dtm_test_df) ){
  value <- predict(myModel, newdata=testDataStream$get_points(1), type="response")
  scores <- append(scores, value)
  myModel <- update_model(myModel$model, dtm_test_df[i,], test_org_class.df[i,1], i)
  i <- i+1
}
table(scores, test_org_class.df[,1])

