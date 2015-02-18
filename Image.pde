class Image
{
  PVector dimensions;
  PImage img;

  Image(String filename, float startWidth)
  {
    if (!filename.equals("none") && filename != null) {
        println("Loading image: "+filename);
        img = loadImage(filename);
        dimensions = new PVector(startWidth, startWidth*img.height/img.width);
        img.resize((int)startWidth, (int)(startWidth*img.height/img.width));
        println("Size "+ dimensions.x + " and " + dimensions.y);
    }
    else {
      img = loadImage("head.png");
      // img = nul
      dimensions = new PVector(0.0, 0.0);
    }

  }
}

String[] listFileNames(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } else {
    // If it's not a directory
    return null;
  }
}

String[] findImgFiles( String[] filenames ) {
// http://computationalphoto.mlog.taik.fi/2011/03/05/processing-finding-images-in-a-directory-listing/

  // this is where we'll put the found image files
  String[] outList_of_foundImageFiles = {
  };

  // to find out what a valid image file suffic might be
  String[] list_of_imageFileSuffixes = {
    "jpeg", "jpg", "tif", "tiff", "png"
  };

  if( images_dir_path.charAt( images_dir_path.length() -1 ) == '/' ) {
    println(" looks like there's a slash at the end of the dir path… no need for modifications ");
  }
  else {
    images_dir_path = images_dir_path+'/' ;
    println(" aha! it's missing a slash at the end, let's add one. \n\t images_dir_path is now = "+images_dir_path );
  }

  // ____ go through all the filenames
  // and check whether the fileending is not one for images
  for( int file_i = 0; file_i < filenames.length ; file_i++ ) {

    println(" looking at file "+filenames[file_i]+" checking if it might not just be a image file ");

    String[] curr_filenameSplit = splitTokens( filenames[ file_i], "." );

    // ___ now check whether file suffix matches any in
    // our little list of filesuffixes
    for( int fileSuffix_i = 0 ; fileSuffix_i < list_of_imageFileSuffixes.length ; fileSuffix_i++ ) { // only do this is the file has a suffix!! // (i.e. which it hopefully has if a split string results // in more than one part/length ) if( curr_filenameSplit.length > 1 ) {
      // fetch the filesuffixes as strings
      // (this might be a long-winded way of doing it,
      // but it takes out some the common instances of bugs… )
      String examinedFile_filesuffix = curr_filenameSplit[curr_filenameSplit.length-1] ;
      String listOfValid_fileSuffixed = list_of_imageFileSuffixes[fileSuffix_i] ;

      // do the actual comparison
      if( examinedFile_filesuffix.equals( listOfValid_fileSuffixed ) ) {
        // and if it's a matching image file suffix, add the whole
        // filepath to the file to the list out outfilenames
        outList_of_foundImageFiles = append( outList_of_foundImageFiles,filenames[ file_i ] );
      }
    }
  }
  // and return something nice
  return outList_of_foundImageFiles;
}
