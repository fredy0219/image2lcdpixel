/*
  Creator : Wei-Yu Chen
  Date : 2020 / 05 / 01
  
  Image transfar to LCD subpixels.

*/

import controlP5.*;
ControlP5 cp5;

PImage img;
PImage resize_img;
PImage lcd_img;
String current_filename;
PGraphics pg;
int scale = 100;
int circleSize = 15;

int col_step = 0;
int row_step = 0;

void setup(){
  size(1000, 700);

  //PFont font = createFont("arial",16);
  //textFont(font);
  cp5 = new ControlP5(this);
     
  cp5.addBang("save_image")
     .setPosition(650,20)
     .setSize(80,40)
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
     ;
  
  cp5.addBang("select_file")
     .setPosition(20,20)
     .setSize(80,40)
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
     ;
     
  cp5.addSlider("sampling_silder")
     .setPosition(400,20)
     .setRange(1,100)
     .setSize(150,15)
     .setValue(100)
     ;
     
  cp5.addSlider("subpixel_slider")
     .setPosition(400,60)
     .setRange(1,100)
     .setSize(150,15)
     .setValue(1)
     ;
  
  pg = createGraphics(8000, 8000);
  
}

void sampling_silder(float _scale){
  
  if(img != null){
    scale = (int)_scale;
    transferSize(scale);
  }
}

void subpixel_slider(float scale){
  if(img != null)
    circleSize = (int)scale;
}

void save_image(){
  
  if(img != null){
    selectOutput("Select a file to write to:", "fileSelectedOutput");
  }
}

void draw(){
  
  background(20);
  
  if(img != null){
    image(img, 0, 120, 250, img.height * 250 / img.width);
    
    int resize_w = resize_img.width > 250 ? 250 : img.width;
    
    image(resize_img, 0, 120+img.height * 250 / img.width + 10, resize_w, resize_img.height * 250 / resize_img.width);
    
    pushMatrix();
    translate(250 + 10, 120);
    img2lcd();
    popMatrix();
    
    text("File name : " +current_filename,150,30);
    text("Original image resolution : " + img.width + "x" + img.height , 150,50);
    text("Resize image resolution : " + lcd_img.width + "x" + lcd_img.height , 150,70);
    text("LCD image resolution : " + circleSize *(lcd_img.width * 2 + 1) + "x" + circleSize *(lcd_img.height * 2 + 1) , 150,90);
    
  }
  else{
    text("No file load...",150,30);
  }
  
  pushStyle();
  fill(50);
  text("weiyuchen",20,680);
  popStyle();
}

PImage transferSize(int pixelSize){
  
  
  resize_img = createImage(img.width, img.height, RGB);

  col_step = ( img.width % pixelSize == 0) ? img.width / pixelSize : img.width / pixelSize + 1;
  row_step = ( img.height % pixelSize == 0) ? img.height / pixelSize : img.height / pixelSize + 1;
  
  
  int r_sum = 0;
  int g_sum = 0;
  int b_sum = 0;
  
  lcd_img = createImage(col_step, row_step, RGB);
  
  lcd_img.loadPixels();
  resize_img.loadPixels();
  
  for(int i = 0 ; i < col_step ; i++)
    for(int j = 0 ; j < row_step ; j++){
      
      for(int k = 0 ; k < pixelSize ; k++ )
        for(int p = 0 ; p < pixelSize ; p++ ){
          int index_col = ((i * pixelSize + k) / img.width == 1) ? img.width-1 : (i * pixelSize + k) ;
          int index_row = ((j * pixelSize + p) / img.height == 1) ? img.height-1 : (j * pixelSize + p);
          int index = index_col + img.width * index_row;
          
          r_sum += red(img.pixels[index]);
          g_sum += green(img.pixels[index]);
          b_sum += blue(img.pixels[index]);
        }
      
      color pixel_color = color( r_sum / (pixelSize*pixelSize) 
                                                    , g_sum / (pixelSize*pixelSize)
                                                    , b_sum / (pixelSize*pixelSize));
      lcd_img.pixels[i + lcd_img.width * j] = pixel_color;
        
      for(int k = 0 ; k < pixelSize ; k++ )
        for(int p = 0 ; p < pixelSize ; p++ ){
          
          int index_col = ((i * pixelSize + k) / img.width == 1) ? img.width-1 : (i * pixelSize + k) ;
          int index_row = ((j * pixelSize + p) / img.height == 1) ? img.height-1 : (j * pixelSize + p);
          int index = index_col + img.width * index_row;
          resize_img.pixels[index] = pixel_color;
        }
        
      r_sum = 0;
      g_sum = 0;
      b_sum = 0;
    }
    
  lcd_img.updatePixels();
  resize_img.updatePixels();
  
  return lcd_img;
}

void img2lcd(){
  
  pg.beginDraw();
  pg.background(0);
  pg.noStroke();
  pg.pushMatrix();
  pg.translate(circleSize/2,circleSize/2);
  int lcd_col = lcd_img.width * 2 + 1;
  int lcd_row = lcd_img.height * 2 + 1;
  
  for(int i = 0 ; i < lcd_col-1 ; i++)
    for(int j = 0 ; j < lcd_row-1 ; j++){
      
      int size = circleSize;
      if(i % 2 == 0 && j % 2 == 0){ // blue dot
        int col_1 = ((i-2)/2 >= 0 && (i-2)/2 <= lcd_img.width-1) ? (i-2)/2 : ((i-2)/2 < 0) ? 0 : lcd_img.width-1;
        int row_1 = ((j-2)/2 >= 0 && (j-2)/2 <= lcd_img.height-1) ? (j-2)/2 : ((j-2)/2 < 0) ? 0 : lcd_img.height-1;
        
        int col_2 = i/2 ;
        int row_2 = row_1;
        
        int col_3 = col_1;
        int row_3 = j/2;
        
        int col_4 = i/2;
        int row_4 = j/2;

        int blue_brightness = (int)(blue(lcd_img.pixels[col_1 + row_1 * lcd_img.width])
                                + blue(lcd_img.pixels[col_2 + row_2 * lcd_img.width])
                                + blue(lcd_img.pixels[col_3 + row_3 * lcd_img.width])
                                + blue(lcd_img.pixels[col_4 + row_4 * lcd_img.width]))/4;
        
        //fill(0,0,blue_brightness);
        size = (int)map(blue_brightness,0,255,0,circleSize);
        pg.fill(0,0,255);
      }
      else if(i % 2 == 1 && j % 2 == 0){
        int col_1 = ((i-1)/2 >= 0 && (i-1)/2 <= lcd_img.width-1) ? (i-1)/2 : ((i-1)/2 < 0) ? 0 : lcd_img.width-1;
        int row_1 = ((j-1)/2 >= 0 && (j-1)/2 <= lcd_img.height-1) ? (j-1)/2 : ((j-1)/2 < 0) ? 0 : lcd_img.height-1;
        
        int col_2 = i/2 ;
        int row_2 = j/2;

        int green_brightness = (int)(green(lcd_img.pixels[col_1 + row_1 * lcd_img.width])
                                + green(lcd_img.pixels[col_2 + row_2 * lcd_img.width]))/2;
                                
        size = (int)map(green_brightness,0,255,0,circleSize);
        //fill(0,green_brightness,0);
        pg.fill(0,255,0);
        
      }
      else if(i % 2 == 0 && j % 2 == 1){
        int col_1 = ((i-2)/2 >= 0 && (i-2)/2 <= lcd_img.width-1) ? (i-2)/2 : ((i-2)/2 < 0) ? 0 : lcd_img.width-1;
        int row_1 = j/2;
        
        int col_2 = i/2 ;
        int row_2 = j/2;

        int green_brightness = (int)(green(lcd_img.pixels[col_1 + row_1 * lcd_img.width])
                                + green(lcd_img.pixels[col_2 + row_2 * lcd_img.width]))/2;
        size = (int)map(green_brightness,0,255,0,circleSize);                        
        //fill(0,green_brightness,0);
        pg.fill(0,255,0);
      }
      else if(i % 2 == 1 && j % 2 == 1){
        int col_1 = ((i-1)/2 >= 0 && (i-1)/2 <= lcd_img.width-1) ? (i-1)/2 : ((i-1)/2 < 0) ? 0 : lcd_img.width-1;
        int row_1 = ((j-1)/2 >= 0 && (j-1)/2 <= lcd_img.height-1) ? (j-1)/2 : ((j-1)/2 < 0) ? 0 : lcd_img.height-1;
        int red_brightness = (int)red(lcd_img.pixels[col_1 + row_1 * lcd_img.width]);
        size = (int)map(red_brightness,0,255,1,circleSize);
        //fill(red_brightness,0,0);
        pg.fill(255,0,0);
      }
      
      pg.ellipse(i*circleSize,j*circleSize,size,size);
    }
  pg.popMatrix();
  pg.endDraw();
  
  image(pg,0,0);
}

void select_file(){
  selectInput("Select a file to process:", "fileSelectedInput");
}

void fileSelectedInput(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    
    img = loadImage(selection.getAbsolutePath());
    current_filename = selection.getName();
    transferSize(scale);
    
  }
}

void fileSelectedOutput(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    
    PImage result = pg.get(0,0,circleSize *(lcd_img.width * 2 + 1), circleSize *(lcd_img.height * 2 + 1));
    result.save(selection.getAbsolutePath()+".jpg");
    
  }
}