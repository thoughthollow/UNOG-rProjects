#Clear the working environment so as to start fresh. Can help to avoid weird errors i.e. it's best practice.
rm(list=ls())

#load the various packages. This must be done each time the script is run.
#if the packages are not installed, then add beforehand for each package "install.packages("packagename").
library(readr)
library(cld2)
library(tidyverse)

#import the csv file data into R, and save it as a variable.
df <- read.csv("YOURFILENAME.csv")

#rename the columns, as the csv names can be a little dirty sometimes from the export.
#be careful not to rename columns incorrectly!
names(df) <- c("Id", "QueueID" ,"Asked.On", "Question", "Details", "Answer", "Owner", "Source", "Status",  "Name", "Email", "Last.Updated", "Tags", "RA.Transactions")

#detect the Details language and add a column.
df <- mutate(df, Details_Lang = cld2::detect_language(Details, lang_code = FALSE), .after = "Details") %>%
  
  #note that the %>% i.e. the pipe sends the data onto the next block of code, so no need to refer to "df" again
  #get the Details string length as a column
  mutate(Details_StringLen = nchar(df$Details), .after = "Details_Lang") %>%
  
  #get the number of words in the Details string as a column
  mutate(Details_WordsLen = str_count(df$Details, "\\w+"), .after = "Details_StringLen")

#Get a table of the Details language count.
Details_langcount <- df %>%
  group_by(Details_Lang) %>%
  summarise(avg_count = n())

#Get a table where the Details language field is empty.
Details_NAlist <- df %>%
  filter(is.na(Details_Lang))


#detect the Answer language details like before.
df <- mutate(df, Answer_Lang = cld2::detect_language(Answer, lang_code = FALSE), .after = "Answer") %>%
  mutate(Answer_StringLen = nchar(df$Answer), .after = "Answer_Lang") %>%
  mutate(Answer_WordsLen = str_count(df$Answer, "\\w+"), .after = "Answer_StringLen")

#Get a table of the Answer language count.
Answer_langcount <- df %>%
  group_by(Answer_Lang) %>%
  summarise(avg_count = n())

#Get a table where the Answer language field is empty.
Answer_NAlist <- df %>%
  filter(is.na(Answer_Lang))

#Output the Answer and Details language count tables as CSV files.
write.csv(Answer_langcount, paste0("LibAnswers_AnswerLangs_", format(Sys.time(), "%Y-%m-%d_%H.%M"), ".csv"), row.names = FALSE)
write.csv(Details_langcount, paste0("LibAnswers_DetailsLangs_", format(Sys.time(), "%Y-%m-%d_%H.%M"), ".csv"), row.names = FALSE)



#Optional: Get a table of the Answer language count. Less useful because the storter strings mean less accurate results.
Question_langcount <- df %>%
  mutate(Question_Lang = cld2::detect_language(Question, lang_code = FALSE), .after = "Details") %>%
  group_by(Question_Lang) %>%
  summarise(avg_count = n()) 

#On the Question language: This below should shows how overzealous the function cld2 can be at times (at least with our LibAnswers data - results may vary). 
df2 <- df %>%
  mutate(Question_Lang = cld2::detect_language(Question, lang_code = FALSE), .after = "Details")
view(filter(df2, Question_Lang == "NORWEGIAN"))
