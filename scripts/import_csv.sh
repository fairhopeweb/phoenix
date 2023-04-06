#!/bin/bash

# first reset directory usage to prevent errors.
cd ../reference

echo ""
echo "==============[BEGIN]================="
# get the length of the json array for loop.
total=$(jq '. | length' csv.json)
counter=0

# article count
echo ""
echo "==============[ARTICLES ABOUT TO BE PARSED]=================="
echo "Number of articles: $total"

# loop json object and create files with low grade titles.
while [ $counter -lt "$total" ];
do
  jq ".[$counter]" csv.json > ../docs/releases/release_$counter.json
  counter=$(( counter + 1))
done

# keep the loop counter here - will reassign for clarity.
unformatted=$total
formatted=0

echo ""
echo "==============[CHECK JSON ITEMS IN ARRAY]=================="
echo "Total Counted Json Objects: $total"
echo ""
echo "==============[CHECK SAVED FILES #]=================="
echo "Total Counted Saved Article Files: $counter"
echo ""
echo "====================== [TOTAL VS COUNTER CHECK BEFORE ITERATION] ========================="
echo "$total | $counter"
echo ""
echo "====================== [FILES TO FORMAT] ========================="
echo "Total Files to Format: $unformatted"


while [ $formatted -lt "$unformatted" ];
do
  ## data that we are going to get from each json
  slug=$(jq ".Slug" ../docs/releases/release_$formatted.json)
  title=$(jq ".Name" ../docs/releases/release_$formatted.json)
  tags=$(jq ".Tags" ../docs/releases/release_$formatted.json)
  image=$(jq ".HeaderImage" ../docs/releases/release_$formatted.json)
  published=$(jq ".Published" ../docs/releases/release_$formatted.json)

  body=$(jq ".MainBody" ../docs/releases/release_$formatted.json)

  # clean slug for file to remove quotes.
  slug_temp="${slug:1}"
  slug_clean="${slug_temp%?}"

  # clean name for file to remove quotes.
  title_temp="${title:1}"
  title_clean="${title_temp%?}"

  # clean tags for file to remove quotes.
  image_temp="${image:1}"
  image_clean="${image_temp%?}"

  # clean tags for file to remove quotes.
  pub_temp="${published:1}"
  pub_clean="${pub_temp%?}"

  # clean tags for file to remove quotes.
  body_temp="${body:1}"
  body_clean="${body_temp%?}"

  ## print them out to check if cleaned
  echo ""
  echo "====================== [CHECK FILE DATA] ========================="
  echo "Slug: $slug_clean"
  echo "Image: $image_clean"
  echo "Title: $title_clean"
  echo "Tags: $tags"
  echo "Published: $pub_clean"
  echo ""

  # create the properly named file - using the slug - here.
  touch ../docs/releases/"${slug_clean}".mdx

  # add the image to the file
  image_clean="![](${image_clean})"
  # shellcheck disable=SC2129
  echo "${image_clean}" >> ../docs/releases/"${slug_clean}".mdx

  # now add the tags below that:
  echo "${tags}" >> ../docs/releases/"${slug_clean}".mdx

  # add heading for markdown -> then the title to the file:
  title_clean="# ${title_clean:0}"
  echo "${title_clean}" >> ../docs/releases/"${slug_clean}".mdx

  # then the publishing date of the article:
  pub_clean="> ${pub_clean:0}"
  echo "${pub_clean}" >> ../docs/releases/"${slug_clean}".mdx

  # store the output of the subshell word count into the $countInstances variable
  # to keep track of how many backslashes will be replaced.
  countInstances=$(echo "${body_clean}" | grep -o '\\"' | wc -l)

  echo "====================== [FORMATTING DATA CHECK] ========================="
  echo "Counted '\' to Replace | ${countInstances}"
  echo ""

  # $matcher is used to detect the escape variables that have been leftover in the html
  # elements that are on the page. $replacement sets the first closing parenthesis.
  matcher='\\"'
  replacement='"'

  # running the replacement and clean the html body code.
  formattedHTML=${body_clean//$matcher/$replacement}

  reversed=$(echo "${formattedHTML}" | rev)

  echo "REVERSAL: ${reversed}"
  reversed="${reversed:890}"
  echo ""
  echo "SCRIPT REMOVED: ${reversed}"
  returned=$(echo "${reversed}" | rev)
  echo ""
  echo "SET BACK: ${returned}"

  # append the newly cleaned code to the file.
  echo  "${returned}" >> ../docs/releases/"${slug_clean}".mdx

  # then destroy the old copy now that we are done with it:
  rm ../docs/releases/release_$formatted.json

  formatted=$(( formatted + 1 ))

  echo ""
  echo "====================== [FILE COMPLETED] ========================="
  echo "DONE | $completed"
done



