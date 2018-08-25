/***
Author: Siyang Liang 470288382

This is program generates an animation which is a combination of fireworks and meteor shower
***/

//an instance of mainmeteor which will be scattered
MainMeteor p;
//a counter to count how many scattered meteors left on the screen
Integer scatteredMeteors;
//determines the position where main meteor will be scattered
Integer scatterHeight;
//indicate whether the meteor is scattered
Boolean scattered;
//the brightness of the background
Float brightness;
//the initial value of the meteor length, will be used to reset the field of meteor class
static final Integer DEFAULT_METEOR_LENGTH = 1;
//the max length of meteors
static final Integer MAX_METEOR_LENGTH = 25;
//the number of meteor which will appear on screen
static final Integer METEOR_QUANTITY = 500;
//the maximum background brightness
static final Float MAX_BRIGHTNESS = 200.0;
//the size of main meteor
static final Float MAIN_METEOR_SIZE = 10.0;
//the size of scattered meteors
static final Float METEOR_SIZE = 3.0;
//these values are used to generate random velocity of scattered meteors
static final Integer SCATTER_X_MIN = -8;
static final Integer SCATTER_X_MAX = 8;
static final Integer SCATTER_Y_MIN = -8;
static final Integer SCATTER_Y_MAX = 2;
static final Integer SCATTER_Z_MIN = -4;
static final Integer SCATTER_Z_MAX = 4;
//these values are used to generate random colour of scattered meteors
static final Float COLOUR_MIN = 100.0;
static final Float COLOUR_MAX = 255.0;

void setup()
{
  background(0.0, 0.0, 0.0);
  size(1920, 900, P3D);
  //using perspective projection to make the animation visually looks real
  perspective();
  noStroke();
  smooth();
  initialise();
}

void draw()
{
  clear();
  if(scattered)
  //if the main meteor has scattered, reduce the brightness a little each frame
  {
    brightness -= 2;
  }
  //set the background colour using brightness
  background(brightness, brightness, brightness);
  p.tick(); //<>//
}

void keyPressed()
  {
    if(key == 's')
    {
      saveFrame("fireWorkSrc###.png");
    }
  }

void initialise()
{
  //initially no meteors scattered, so it's zero
  scatteredMeteors = 0;
  //not scattered initially, so it's false
  scattered = false;
  //the brightness will be adjust when main meteor scatter, so it's zero initially
  brightness = 0.0;
  //the mateor will scatter at a third of the canvas height
  scatterHeight = height/3;
  //create a new instance of main meteor, set initial position at the middle bottom, by default it moves upward with a acceleration of downward
  p = new MainMeteor(new PVector(width/2, height, 0), new PVector(0, -height/120, 0), new PVector(0, height/60/20, 0), MAIN_METEOR_SIZE, true, COLOUR_MAX, COLOUR_MAX, COLOUR_MAX);
  //create many meteors and add it to the main one
  for(Integer i = 0; i < METEOR_QUANTITY; i++)
  {
    //default position is set to the middle and a third of height (where scattering occured)
    //these meteors are not visually appeared at the beginning
    p.meteors.add(new Meteor
                        (new PVector(width/2, scatterHeight/1.0, 0), 
                         new PVector(random(SCATTER_X_MIN, SCATTER_X_MAX), random(SCATTER_Y_MIN, SCATTER_Y_MAX), random(SCATTER_Z_MIN, SCATTER_Z_MAX)), 
                         new PVector(0, 0.1, 0), METEOR_SIZE, false, random(COLOUR_MIN, COLOUR_MAX), random(COLOUR_MIN, COLOUR_MAX), random(COLOUR_MIN, COLOUR_MAX)));
  }
}

class MainMeteor extends Meteor
/*
 main meteor moves from bottom to top, and when it reaches certain height, it scatters.
*/
{
  //a list of meteors waiting to be scattered
  ArrayList<Meteor> meteors;
  
  MainMeteor(PVector position, PVector velocity, PVector acceleration, Float radius, Boolean status, Float r, Float g, Float b)
  {
    super(position, velocity, acceleration, radius, status, r, g, b);
    meteors = new ArrayList<Meteor>();
  }
  
  void scatter()
  /*
  this method scatter the main meteor, which will activate all meteors in the list and make them appear on screen
  */
  {
    //set the counter to the size of the list
    scatteredMeteors = meteors.size();
    //iterate the list, set each meteor to be visible
    for(Meteor p : meteors)
    {
      p.display = true;
    }
    //swtich scattered status to be true
    scattered = true;
    //adjust background brightness
    brightness = MAX_BRIGHTNESS;
    //reset the position of main meteor to its initial condition
    reset(); 
  }
 
  
  void tick()
  /*
  This method is called every frame, it renders the meteor, adjust it's position for next frame and adjust the velocity with acceleration
  also it may trigger some operation if certain condition is met.
  */
  {
    
    if(display)
    //when it is visible
    {
      render();
      update();
      if(position.y < scatterHeight && !scattered)
      {
        scatter();
      }
    }
    else
    {
      //when all scattered meteors is reset
      if(scatteredMeteors <= 0)
      {
        //set it visible so in next frame it starts moving again
        display = true;
        //set scattered condition to false
        scattered = false;
      }
    }
    //iterate each meteors
    for(Meteor p : meteors)
    {
      p.tick();
    }  
  }
  
  void reset()
  {
    //set it invisible
    display = false;
    //set condition to default
    position = defaultPos.copy();
    velocity = defaultVel.copy();
    acceleration = defaultAcc.copy();
    meteorLength = DEFAULT_METEOR_LENGTH;
  }
}

class Meteor
{
  PVector position, velocity, acceleration;
  //default position, default velocity, default acceleration
  PVector defaultPos, defaultVel, defaultAcc;
  //is visible or not
  Boolean display;
  //size of the meteor, which will be a circle
  Float radius;
  //colour r g b value
  Float r, g, b;
  //length of the meteor
  Integer meteorLength;
  
  Meteor(PVector position, PVector velocity, PVector acceleration, Float radius, Boolean status, Float r, Float g, Float b)
  {
    //set the default condition
    defaultPos = position;
    defaultVel = velocity;
    defaultAcc = acceleration;
    //set current condition
    reset();
    //set the attributes
    this.radius = radius;
    this.display = status;
    this.r = r;
    this.g = g;
    this.b = b;
    meteorLength = DEFAULT_METEOR_LENGTH;
  }
  
  void render()
  {
    //create an temporary vector
    PVector v = velocity.copy();
    //a temp Integer to be used
    Integer opacity;
    //a temp Float to be used
    Float sizeDecrementRate;
    pushMatrix();
    //translate to it's position first
    translate(position.x, position.y, position.z);
    //calculate the path of the meteor, render multiple circle to make it look like a meteor
    //the loop would render the head of the meteor first
    for(Integer i = 0; i < meteorLength; i++)
    {
      //the end of the meteor has lower opacity value
      opacity = 100-i*(100/MAX_METEOR_LENGTH);
      //adjust the colour
      fill(r, g, b, opacity);
      //calculate the path and translate
      v = v.sub(acceleration);
      //the reason it minus the velocity is because it render from head to tail, so it has to translate in opposite direction of the meteor
      translate(-v.x, -v.y, -v.z);
      //the end of the path is smaller, so as i gets larger, the more it get reduced
      sizeDecrementRate = sqrt(i);
      ellipse(0, 0, radius - sizeDecrementRate, radius - sizeDecrementRate);
    }
    popMatrix();
  }
  
  void tick()
  {
    //is visible
    if(display)
    {
      render();
      update(); //<>//
    }  
  }
  
  void reset()
  {
    //not visible until next scattering occur
    display = false;
    //reset to defult position
    position = defaultPos.copy();
    //generate a random velocity
    velocity = new PVector(random(SCATTER_X_MIN, SCATTER_X_MAX), random(SCATTER_Y_MIN, SCATTER_Y_MAX), random(SCATTER_Z_MIN, SCATTER_Z_MAX));
    //reset to default acceleration
    acceleration = defaultAcc.copy();
    //decrement the counter
    scatteredMeteors -= 1;
    //reset the meteor length
    meteorLength = DEFAULT_METEOR_LENGTH;
  }
  
  void incrementMeteorLength()
  /*
  check if the meteor length reach the maximum length, if not increment it
  */
  {
    if(meteorLength < MAX_METEOR_LENGTH)
      {
        meteorLength += 1;
      }
  }
  
  void detectOutOfBound()
  /*
  check if the meteor has a y value greater than height, in case of it, reset
  */
  {
    if(position.y > height)
      {
        reset(); 
      }
  }
  
  void update()
  {
    //adjust position and velocity
    position = position.add(velocity);
    velocity = velocity.add(acceleration);
    //increase the length as it moves
    incrementMeteorLength();
    //if it somehow get to below the screen, reset it
    detectOutOfBound();
  }
  
  
}