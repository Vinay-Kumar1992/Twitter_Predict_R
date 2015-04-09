library(streamR)
library(stringr)
library(tm)
library(RMOA)

update_model <- function(mymodel, dtm_row, row_class, i) {
  dtm_df <- as.data.frame(as.matrix(dtm_row))
  #print(row_class)
  dtm_df[i,"label"]= row_class
  #print(dtm_df[,211])
  datastream <- datastream_dataframe(data=dtm_df)
  
  mymodel <- trainMOA(model = mymodel, formula=label~., data = datastream, reset = FALSE, trace = TRUE)
  
  return(mymodel)
}

load("my_oauth.Rdata")
filterStream("new_tweets.json", track = c("love", "hate"), timeout = 10, oauth = my_oauth)
tweets.df <- parseTweets("new_tweets.json", simplify = TRUE)
index <- sample(1:dim(tweets.df)[1])

train_tweets <- tweets.df[index[1:floor(dim(tweets.df)[1]/2)], ]
test_tweets <- tweets.df[index[((ceiling(dim(tweets.df)[1]/2)) + 1):dim(tweets.df)[1]], ]
train_tweets_new.df <- data.frame(str_replace_all(train_tweets$text,"[^[:graph:]]", " "))
test_tweets_new.df <- data.frame(str_replace_all(test_tweets$text,"[^[:graph:]]", " "))

love <- "love"
hate <- "hate"
get_sentiment <- function(x) { if(str_detect(x, "love")) love else hate }

train_org_class.df <- data.frame(list(apply(train_tweets_new.df, 1, function(x) get_sentiment(tolower(gsub("[()]", "", x))) )))
test_org_class.df <- data.frame(list(apply(test_tweets_new.df, 1, function(x) get_sentiment(tolower(gsub("[()]", "", x))) )))

colnames(train_tweets_new.df)[1]<- c("text")
colnames(test_tweets_new.df)[1]<- c("text")

train_tweets_rmvd.df <- data.frame(sapply(train_tweets_new.df$text, function(x) gsub("love", "", tolower(x))))
train_tweets_rmvd.df <- data.frame(sapply(train_tweets_rmvd.df, function(x) gsub("hate", "", tolower(x))))

cs <- Corpus(VectorSource(train_tweets_rmvd.df[,1]))
corpus<-tm_map(cs, removePunctuation, lazy=FALSE)
corpus<-tm_map(corpus, stripWhitespace, lazy=FALSE)
corpus<-tm_map(corpus, content_transformer(tolower), lazy=FALSE)
corpus<-tm_map(corpus, removeWords, stopwords("english"), lazy=FALSE)
corpus<-tm_map(corpus, stemDocument, lazy=FALSE)

#train_org_class.df[, 1]

tdm <- TermDocumentMatrix(corpus)
m <- as.matrix(tdm)
v <- sort(rowSums(m), decreasing=TRUE)
N <- 75
head(v, N)
features <- names(head(v,N))
#features

tdm_remsparse <- TermDocumentMatrix(corpus, control = list(dictionary = features ))
tdm_remsp_df <- as.data.frame(as.matrix(tdm_remsparse))
tdm_remsp_df <- t(tdm_remsp_df)
tdm_remsp_df <- as.data.frame(tdm_remsp_df)
tdm_remsp_df["label"]= train_org_class.df
irisdatastream <- datastream_dataframe(data=tdm_remsp_df)
#irisdatastream2 <- datastream_dataframe(data=tdm_remsp_df)

ctrl <- MOAoptions(model = "NaiveBayes")
mymodel <- NaiveBayes(control=ctrl)
#mymodel

myModel <- trainMOA(model = mymodel, formula=label~., data = irisdatastream, reset = FALSE, trace = TRUE)
#myModel <- trainMOA(model = mymodel, formula=label~., data = irisdatastream2, reset = FALSE, trace = TRUE)


test_tweets_rmvd.df <- data.frame(sapply(test_tweets_new.df$text, function(x) gsub("love", "", tolower(x))))
test_tweets_rmvd.df <- data.frame(sapply(test_tweets_rmvd.df, function(x) gsub("hate", "", tolower(x))))

cs_test <- Corpus(VectorSource(test_tweets_rmvd.df[,1]))
corpus_test<-tm_map(cs_test, removePunctuation, lazy=FALSE)
corpus_test<-tm_map(corpus_test, stripWhitespace, lazy=FALSE)
corpus_test<-tm_map(corpus_test, content_transformer(tolower), lazy=FALSE)
corpus_test<-tm_map(corpus_test, removeWords, stopwords("english"), lazy=FALSE)
corpus_test<-tm_map(corpus_test, stemDocument, lazy=FALSE)

dtm_test <- DocumentTermMatrix(corpus_test, control = list(dictionary = features))
#inspect(dtm_test[1:50,1:20])
dtm_test_df <- as.data.frame(as.matrix(dtm_test))
i=1;
nrow(dtm_test_df)
scores = c()
testDataStream = datastream_dataframe(data = dtm_test_df)
#myModel <- update_model(myModel, dtm_test_df[1,], test_org_class.df[1,])
while(testDataStream$processed < nrow(dtm_test_df) ){
#cat("value is ", i)

value <- predict(myModel, newdata=testDataStream$get_points(1), type="response")
scores <- append(scores, value)

#cat(" value ", value, "\n")
cat(" i  ",i, "\n")
#print(dtm_test_df[i,])
#print(test_org_class.df[i,1])
myModel <- update_model(myModel$model, dtm_test_df[i,], test_org_class.df[i,1], i)
i <- i+1
#accuracy
#dtm_test_df = dtm_test_df[-1,]
#which(scores=="hate")
}
table(scores, test_org_class.df[,1])

