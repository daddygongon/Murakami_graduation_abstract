
Elementary_waves[] elementary_waves_array;
Sliders[] sliders_array;
boolean keyReleased = false;
boolean check_mode = false;
boolean lambda_mode = false;
int number_wave_point = 0;
int size = 400; 
int point_regulation = 4;
int s_p = size/point_regulation;
int maximum_waves_number = 5;
float check_y = s_p/2;
float[][] point = new float[s_p][s_p];
float[][] point_distance = new float[s_p*maximum_waves_number][s_p];
float wave_v;

void setup(){  
  colorMode(HSB, 360,100,100,100);
  size(size+(maximum_waves_number+1) * 95,size);
  frameRate(30);
  elementary_waves_array = new Elementary_waves[maximum_waves_number];
  sliders_array = new Sliders[maximum_waves_number+1];//check用のスライダーでプラス１
  make_elementary_waves(); //全ての点源のインスタンスを作成
  make_sliders();
}

void make_elementary_waves(){
  for(int i = 0; i < elementary_waves_array.length; i++){
    Elementary_waves elementary_waves = new Elementary_waves(width/2-50,size/2,30.0,3.0,2.0,10.0,20.0,100.0);//とりあえず作っている.
    elementary_waves_array[i] = elementary_waves;
  }
  wave_v = elementary_waves_array[0].lambda / elementary_waves_array[0].period; 
}

void make_sliders(){
  Sliders sliders = new Sliders(size+20,20,size-50,30,0,s_p,40,0,"y = ");
    sliders_array[0] = sliders;
    sliders_array[0].draw_flag = true;
  for(int i = 1; i < sliders_array.length; i++){
    sliders = new Sliders(size+20+i*95,20,size-50,30,elementary_waves_array[i-1].period_min,elementary_waves_array[i-1].period_max,40,1, "period = ");
    sliders_array[i] = sliders;
  }
}


void draw(){  
  background(255);
  strokeWeight(point_regulation);
  if(check_mode == true){
    draw_check();
  }else{
    draw_wave();
  }
}


void keyPressed(){
  if((keyPressed == true) && keyReleased == true &&((key == 'c') ||  (key == 'C'))){
    keyReleased = false;
    check_mode = true;
  }
  if((keyPressed == true) && keyReleased == true && ((key == 'b') ||  (key == 'B'))){
    keyReleased = false;
    check_mode = false;
  }
  if((keyPressed == true) && keyReleased == true && ((key == 'l') ||  (key == 'L'))){
    for(int i = 0; i < number_wave_point; i++){
      sliders_array[i+1].min = elementary_waves_array[i].lambda_min;
      sliders_array[i+1].max = elementary_waves_array[i].lambda_max;
      sliders_array[i+1].variable_name = "lambda = ";
    }
    keyReleased = false;
    lambda_mode = true;
  }
  if((keyPressed == true && lambda_mode == true) && keyReleased == true && ((key == 'p') ||  (key == 'P'))){
    for(int i = 0; i < number_wave_point; i++){
      sliders_array[i+1].min = elementary_waves_array[i].period_min;
      sliders_array[i+1].max = elementary_waves_array[i].period_max;
      sliders_array[i+1].variable_name = "period = ";
    }
    keyReleased = false;
    lambda_mode = false;
  }
}


void mousePressed() { //新しい素元波を一つ生成．
  int s_p_n = s_p * number_wave_point;
  if(mouseX < size && lambda_mode == false){
    if(maximum_waves_number>number_wave_point){
      elementary_waves_array[number_wave_point].center_x = mouseX;
      elementary_waves_array[number_wave_point].center_y = mouseY;
      elementary_waves_array[number_wave_point].created_time = millis();
      sliders_array[number_wave_point+1].draw_flag = true;
      for(int i = 0; i < s_p; i++){
        for(int j = 0; j < s_p; j++){//s_p_nは０→１へと増える　つまり最初の波の位相は0~s_pまで入ってる
          point_distance[i+s_p_n][j] = distance_calculate(elementary_waves_array[number_wave_point].center_x, //ここはs
          elementary_waves_array[number_wave_point].center_y, i*point_regulation, j*point_regulation);
        }
      }
      number_wave_point++;
    }
  }
}


void keyReleased() {
  keyReleased = true;
}

float distance_calculate(float center_x, float center_y, float x, float y){
  float a = dist(center_x,center_y,x,y);
  return a;
}

float range_to_calculate(int i){
  float a = (millis()-elementary_waves_array[i].created_time)*elementary_waves_array[i].lambda/elementary_waves_array[i].period/1000.0;
  return a;
}


void draw_wave(){
  int number_wave_point2 = number_wave_point*2;
  for(int i = 0; i < s_p; i++){
    for(int j = 0; j < s_p; j++){
      for(int k = 0; k < number_wave_point; k++){
        float range = range_to_calculate(k);//現在の波の最先端の距離を計算
        //sliders_array[k].draw_slider();
        if(point_distance[i+s_p*k][j] < range){ //クラス配列，各点と波ごとの距離と範囲を比較
          float y = elementary_waves_array[k].now_displacement_y(point_distance[i+s_p*k][j],
          elementary_waves_array[k].lambda, elementary_waves_array[k].period, elementary_waves_array[k].created_time);
          point[i][j] += y;
        }else{
        }
      }
      point[i][j] += number_wave_point;
      if(number_wave_point != 0 || point[i][j] != 0.0)
      {
        stroke( (number_wave_point2- point[i][j])*(230/number_wave_point2),100,100);
        point(i*point_regulation,j*point_regulation);
        point[i][j] = 0;
      }else{
        point(i*point_regulation,j*point_regulation);
      }
    }
  } 
  stroke(300,100,100,100);
  line(0,check_y*point_regulation,size,check_y*point_regulation);
  strokeWeight(10);
  for(int a = 0; a < number_wave_point; a++){
    point(elementary_waves_array[a].center_x, elementary_waves_array[a].center_y);
    text(a+1, elementary_waves_array[a].center_x-10,elementary_waves_array[a].center_y-10); 
  }
  check_y = sliders_array[0].draw_slider((float)check_y);
  for(int i = 0; i < number_wave_point; i++){//スライダーを描写 スライダーの方は＋１している
    if(lambda_mode == false){
      elementary_waves_array[i].period = sliders_array[i+1].draw_slider(elementary_waves_array[i].period);
      elementary_waves_array[i].lambda = elementary_waves_array[i].period * wave_v;
  }else{
    elementary_waves_array[i].lambda = sliders_array[i+1].draw_slider(elementary_waves_array[i].lambda);
     elementary_waves_array[i].period = elementary_waves_array[i].lambda / wave_v;
  }
  }
}



void draw_check(){ 
//stroke(0,0,0,0);
  for(int i = 0; i < s_p; i++){
    for(int j = 0; j < s_p; j++){
      for(int k = 0; k < number_wave_point; k++){
        float range = range_to_calculate(k);//現在の波の最先端の距離を計算
        if(point_distance[i+s_p*k][j] < range){ //クラス配列，各点と波ごとの距離と範囲を比較
          float y = elementary_waves_array[k].now_displacement_y(point_distance[i+s_p*k][j],
            elementary_waves_array[k].lambda, elementary_waves_array[k].period, elementary_waves_array[k].created_time);
          point[i][j] -= y;
        }
      }
      if(j==check_y) point(i*point_regulation,(size/2+(point[i][j]*145.0/(float)number_wave_point)));
      point[i][j] = 0;
    }
  }

  for(int i = 0; i < 11; i++){
    stroke(0,0,0,100);
    text((float)number_wave_point-(float)i*2*(float)number_wave_point/10.0,size+10,56+i*29.5);
    stroke(230,100,50,50);
    strokeWeight(1);
    line(0,52+i*29.5,size,52+i*29.5);
  }
  stroke(0,0,0,100);
  strokeWeight(5);
  line(0,size/2,size,size/2);
  line(size,0,size,size);
}

class Sliders{
  int position_x;
  int position_y;
  int slider_height;
  int slider_width;
  int digit;
  int num_separator;
  int number_tickmarks;
  float min;
  float max;
  float cordinate_y;
  String variable_name;
  boolean draw_flag;
  boolean slider_dragged;

  Sliders(int _position_x, int _position_y, int _slider_height, int _slider_width, float _min, float _max, int _number_tickmarks,int _digit, String _variable_name){
    position_x = _position_x;
    position_y = _position_y;
    slider_height = _slider_height;
    slider_width = _slider_width;
    min = _min;
    max = _max;
    number_tickmarks = _number_tickmarks;
    digit = _digit;
    variable_name = _variable_name;
    draw_flag = false;
    slider_dragged = false;
  }

  float draw_slider(float variable_value){
    if(draw_flag == true){
      num_separator = (int)map(variable_value, min, max, number_tickmarks-1,0); //temper=グローバル min~maxの範囲を０からnumber_tickmarksに変換
      cordinate_y = position_y + slider_height - ((float)slider_height / (number_tickmarks-1))*num_separator; 
      fill(255);
      noStroke();                                                        //text消すため
      rect(position_x, position_y + slider_height, slider_width+50, 30); 
      stroke(1);
      rect(position_x, position_y, slider_width, slider_height);
      fill(0);
      rect(position_x, cordinate_y, slider_width, position_y + slider_height - cordinate_y);
      if(variable_name == "y = "){text(variable_name + nf(variable_value*point_regulation,1,digit), position_x, position_y + slider_height + 20);
      }else{
        text(variable_name + nf(variable_value,1,digit), position_x-20, position_y + slider_height + 20);
      }
      if(mousePressed==false) slider_dragged=false;
      if(mouseX >= position_x & mouseX <= position_x + slider_width & mouseY<=cordinate_y+10 & mouseY>= cordinate_y-10){
        if(mousePressed){
          slider_dragged= true;
        }
      }
      if(slider_dragged){
        num_separator+= (int)((cordinate_y - mouseY)/((float)slider_height / (number_tickmarks-1))); // intにしないとjsで整数にならない
        num_separator = constrain(num_separator, 0, number_tickmarks-1); //目盛りを０から４０までに制限する
        if(digit == 0){
          variable_value = (max-min) - round(map(num_separator, 0, number_tickmarks-1, min, max)); // ０から目盛りをminmaxに変換
        }else{
          variable_value = (max+min) - map(num_separator, 0, number_tickmarks-1, min, max);
        }

        
        return variable_value;
      }else{
        return variable_value;
      }
    }else{
      return variable_value;
    }
  }
}


class Elementary_waves{
  float center_x;
  float center_y;
  float lambda;
  float period;
  float created_time;
  float period_max;
  float period_min;
  float lambda_max;
  float lambda_min;

  Elementary_waves(float _center_x, float _center_y, float _lambda, float _period, 
    float _period_min, float _period_max, float _lambda_min, float _lambda_max){
    center_x = _center_x;
    center_y = _center_y;
    lambda = _lambda;
    period = _period;
    period_max = _period_max;
    period_min = _period_min;
    lambda_max = _lambda_max;
    lambda_min = _lambda_min;
    created_time = 0; //とりあえず代入している
  }

  float now_displacement_y(float distance, float lambda, float period, float time_adjustment){
    float time_phase_adjustment;
    time_phase_adjustment = ((millis()-time_adjustment)/1000.0)*(360.0 / period); //ここで時間差を計算している→変数で開始時刻を記録→これを代入すればいい．
    float distance_lambda_adjustment = (distance%lambda)/lambda*(360.0);
    float y = sin(radians(time_phase_adjustment - distance_lambda_adjustment));
    return y;
  }


  /*float range_to_calculate(){
    float a = (millis()-created_time)*lambda/period/1000.0;
    return a;
  }*/
}

