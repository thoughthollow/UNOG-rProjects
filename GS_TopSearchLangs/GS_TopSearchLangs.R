#Clear the working environment so as to start fresh. Can help to avoid weird errors i.e. it's best practice.
rm(list=ls())

#load the various packages. This must be done each time the script is run.
#if the packages are not installed, then add beforehand for each package "install.packages("packagename")
library(readr)
library(cld2)
library(tidyverse)
library(stringr)

#import the csv file data into R, and save it as a variable
df <- read.csv("yourfilenameforimporting.csv")
#rename the 3 columns
names(df) <- c("search_string", "no_of_searches", "no_of_results_per_search")

#detect the search language and add a column
df <- mutate(df,  cld2_Lang = cld2::detect_language(search_string, lang_code = FALSE)) %>%

#note that the %>% i.e. the pipe sends the data onto the next block of code, so no need to refer to "df" again
#get the search string length as a column
  mutate(string_char_length = nchar(df$search_string)) %>%

#get the number of words in the search string as a column
  mutate(no_of_words = str_count(df$search_string, "\\w+"))

#the above is the same as this below:
#df <- mutate(df,  cld2_Lang = cld2::detect_language(search_string, lang_code = FALSE))
#df <- mutate(df, string_char_length = nchar(df$search_string))
#df <- mutate(df, no_of_words = str_count(df$search_string, "\\w+"))

#exort as csv, with  the datetime in the filename
write.csv(df, paste0("GS_TopLangs_exported_", format(Sys.time(), "%Y-%m-%d_%H.%M"), ".csv"), row_names = FALSE)

#Note: By default the write.csv function overwrites data if a file with the same name exists already.
#You can use write.table to avoid overwriting, like so:
#write.table(df, "mydata.csv",append = TRUE)
