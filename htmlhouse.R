#install.packages("rvest")
#install.packages("stringr")

library(rvest)
library(stringr)
setwd("~/Sites/House")

rm(list=ls())
links = read.table("houselinks.txt")

#function for appending to html file
write_to_HTML <- function(list_of_code, file_name){
  for(text in list_of_code){
    write(text, file_name, sep = "\n", append = "true")
  }
}

#output file name
file_name = "index.html"
#creates first line in file (deletes old content)
write("<!DOCTYPE html>", file_name,sep = "\n", append = "false")

#adds everything until <body>
heading <- list("<html>","<head>","<link rel=\"stylesheet\" href=\"housestyle.css\" />", "<link rel=\"stylesheet\" href=\"house_slideshow.css\" />", "</head>", "<body>","<table style=\"width:100%\">")
write_to_HTML(heading, file_name)

#lays down column titles for table
table_data <- list("<tr>", "<th>Basic Information</th>", "<th>OH</th>", "<th>Image</th>","</tr>")
write_to_HTML(table_data, file_name)

id_number = 1
#loop that goes thru all the links
for (link in 1:nrow(links)){
  #creates new column
  table_data <- list("<tr>")
  write_to_HTML(table_data, file_name)

  #Specifying the url for desired website to be scrapped
  url <- toString(links[link,1])
  #Reading the HTML code from the website
  webpage <- read_html(url)

  
  #Using CSS selectors to scrap the rankings section
  address_data_html <- html_nodes(webpage,'.notranslate')
  #Converting the ranking data to text
  address_data <- html_text(address_data_html)
  address <- paste("<h2 class = \"address\"><a href =\"", url, "\" target=\"_blank\" class = \"address\">", address_data[2], "</a></h2>", sep = "", collapse = NULL)
  
  javascript_address <- gsub(" ", "", address_data[2], fixed = TRUE)
  
  #same as above with other data
  price_data_html <- html_nodes(webpage,'.estimates')
  price_data <- html_text(price_data_html)
  pos = str_locate(price_data,"\\$")
  if(substr(price_data, pos+7,pos+7) == ","){
    price = substr(price_data, pos, pos+10)
  }else{
    price = substr(price_data, pos, pos+7)
  }
  
  
  #gets a long list of different types of info
  detailsN_data_html <- html_nodes(webpage,'.hdp-fact-name')
  detailsN_data <- html_text(detailsN_data_html)
  
  detailsV_data_html <- html_nodes(webpage,'.hdp-fact-value')
  detailsV_data <- html_text(detailsV_data_html)
  
  #deletes "Built in" and leaves the year
  for (v in detailsV_data){
    if (str_sub(v,0,8) == "Built in"){
      yearBuilt = v
    }
  }
  
  #compiling basic data together
  basic_data_html <- html_nodes(webpage,'.addr_bbs')
  basic_data <- html_text(basic_data_html)
  
  #looks for alerts at the top
  alerts_data_html <- html_nodes(webpage,'.yui3-widget-ft')
  alerts_data <- html_text(alerts_data_html)
  if (identical(character(0),alerts_data)){
    notes = ""
  } else if(grepl("pending offer", alerts_data)){
    notes = "Pending Offer."
  } else if(grepl("Beware of suspicious", alerts_data)){
    notes = "Suspicious Listing."
  }
  #checks if this is still not on the market  
  status_data_html <- html_nodes(webpage,'.estimates')
  status_data <- html_text(status_data_html)
  
  if(!(identical(character(0),alerts_data))&&(grepl("Coming Soon", status_data))){
    notes = paste("Coming Soon.", notes, sep = " ", collapse = NULL)
  }
  notes <- paste("<h3 class =\"notes\">", notes, "</h3>", sep = " ", collapse = NULL)
  basic_info <- paste("<h2 class = basic_info>", price, "<br>", basic_data[1], ", ", basic_data[2], "<br>", basic_data[3], "<br>", yearBuilt, "</h2>",sep = "", collapse = NULL)
  basic_info <- paste(address, basic_info, notes,sep = "\n", collapse = NULL)
  
  
  #if there are no open houses, they write NA
  OH_list = list(detailsV_data[1], detailsV_data[2], detailsV_data[3])
  OH = "<h2 class = \"OH\">"
  for (rowNum in 1:3){
    if ((length(detailsV_data) > 2)&&(str_sub(detailsV_data[[rowNum]],-2,-1) == "pm")){
      OH <- paste(OH, detailsV_data[[rowNum]],"<br>", sep = " ", collapse = NULL)
    }
  }
  select_with_id <- paste("<select id = \"", javascript_address,"\" onchange=\"save_selection('", javascript_address, "', this.selectedIndex);\">", sep = "", collapse = NULL)
  OH <- paste(OH, select_with_id, "<option value=\"Check Later\">Check Later</option>", "<option value=\"Definitely Not\">Definitely Not</option>", "<option value=\"Maybe\">Maybe</option>","<option value=\"Strongly Consider\">Strongly Consider</option>","<option value=\"Definitely Visit\">Definitely Visit</option>","</select>","</h2>", sep = "\n", collapse = NULL)
  
  #starting HTML code for slideshow
  image_HTMLcode <- "<div class=\"slideshow-container\">"
  #getting images
  imageLink_data_html <- html_nodes(webpage,"img.hip-photo") # get any image with class = hip-photo
  imageLinks <- list(html_attr(imageLink_data_html, "src")) #this is the cover photo
  imageLinks2 <- list(html_attr(imageLink_data_html, "href")) #rest of the photos
  #merge lists without NA
  imageLinks <- append(na.omit(imageLinks[[1]]), na.omit(imageLinks2[[1]]))
  #changing size of photo requested from site
  imageLinks <- gsub("p_h", "p_h",imageLinks) #image sizes: p_c < p_h < p_f
  imageLinks <- gsub("p_c", "p_h",imageLinks)
  #convert to HTML code

  imageLinks[1] <- paste("<div class=\"mySlides", id_number, " fade\">","<img src = \"", imageLinks[1], "\"  />", "</div>", sep = "", collapse = NULL)

  if (length(imageLinks) > 1){ for (link in 2:length(imageLinks)){
    imageLinks[link] <- paste("<div class=\"mySlides", id_number, " fade\" id = \"hide\">","<img src = \"", imageLinks[link], "\"  />", "</div>", sep = "", collapse = NULL)
  }}
  for (code in imageLinks){
    image_HTMLcode <- paste(image_HTMLcode, code, sep = "\n", collapse = NULL)
  }
  prev_button <- paste("<a class=\"prev\" onclick=\"plusSlides(-1,", id_number, ")\">&#10094;</a>", sep = "", collapse = NULL) 
  next_button <- paste("<a class=\"next\" onclick=\"plusSlides(1,", id_number, ")\">&#10095;</a>", sep = "", collapse = NULL)
  image_HTMLcode <- paste(image_HTMLcode, prev_button, next_button, "</div>", sep = "\n", collapse = NULL)
  
  #data without HTML code
  table_data_raw <- list(basic_info, OH, image_HTMLcode)

  #loops and converts to HTML code 
  for (data in table_data_raw){
    table_data <- list(paste("<td>", data, "</td>", sep = "", collapse = NULL))
    write_to_HTML(table_data, file_name)
  }
  #ends row  
  table_data <- list("</tr>")
  write_to_HTML(table_data, file_name)
  
  id_number <- 1 + id_number
}#end for loop for this house

#closes table, body and html
footer <- list("</table>", "<script src=\"house.js\"></script>", "<script src=\"oatmeal_cookie.js\"></script>", "</body>", "</html>")
write_to_HTML(footer, file_name)


