#!/usr/bin/env bash

# iterate through adoc and mdoc files in the current directory
adocfiles=$(find . -name "*.adoc")
mdocfiles=$(find . -name "*.mdoc")

# clean create the build directory
BUILD_DIR=./build
rm -rf $BUILD_DIR
mkdir $BUILD_DIR

function adoc_to_xml() {
  echo "generating xml $1 ..."
  path_string=$(dirname $1) # the path to the file
  file_name_full=$(basename $i) # filename with extension
  file_extension="${file_name_full##*.}" # filename extension
  file_name="${file_name_full%.*}" # filename without extension

  # create he output directory
  output_dir=$BUILD_DIR/$path_string
  mkdir -p $output_dir

  # create the docbook xml in the output dir
  asciidoctor -b docbook $i -o $output_dir/$file_name.xml
}

function xml_to_md() {
  echo "generating md $1 ..."
  path_string=$(dirname $1) # the path to the file
  file_name_full=$(basename $i) # filename with extension
  file_extension="${file_name_full##*.}" # filename extension
  file_name="${file_name_full%.*}" # filename without extension

  # vanilla pandoc
  # pandoc -f docbook -t gfm $i -o $path_string/$file_name.md
  # fix mangled utf8 characters, remove hardcoded linebreaks at 72
  iconv -t utf-8 $i | pandoc -f docbook -t gfm --columns=120 | iconv -f utf-8 > $path_string/$file_name.md
}

# convert mdoc files to xml
for i in $mdocfiles; do
  adoc_to_xml $i
done

# convert adoc files to xml
for i in $adocfiles; do
  adoc_to_xml $i
done

# convert built xml files to md
xmlfiles=$(find $BUILD_DIR -name "*.xml")
for i in $xmlfiles; do
  xml_to_md $i
done

# cleanup xml files
find $BUILD_DIR -name \*.xml -type f -delete

echo "done"

