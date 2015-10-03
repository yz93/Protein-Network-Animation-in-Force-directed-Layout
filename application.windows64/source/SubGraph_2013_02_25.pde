ArrayList<Node> allNodes = new ArrayList<Node>();
int THRESHOLD = 900;
String K="1";
boolean PAUSE=false;
int FRAMERATE=60;
int REPULSION = 200000; // 5000 to 500000;
float ATTRACTION = 2.2;   // 0.5 to 3.0;
PFont f = createFont("Arial",12,true);
//String[] lines = loadStrings("order(51).txt");

void keyPressed()
{  
PAUSE = !PAUSE;  
if (PAUSE)    
  noLoop();  
else    
  loop();
}

float edgeBrightness(float connectionLevel)
{
  float scale = (999.0-THRESHOLD)/160;
float s = (connectionLevel - THRESHOLD)/scale+10;
return s;
}

float impToSize(float imp, float scaleMax, float scaleMin)
{
float scale = (scaleMax-scaleMin)/35;
float s = (imp-scaleMin)/scale+5;
return s;
}

boolean mouseOverCircle(float x, float y, float diameter) 
{  
  return (dist(mouseX, mouseY, x, y) <= diameter*0.5);
}

class Neighbor
{
Node mNode;
int connWeight;
Neighbor(Node node)
{
mNode = node;
connWeight = 200;
}

Neighbor(Node node, int conn)
{
mNode = node;
connWeight = conn;
}
}

class Node
{
int mId;
String mName;
float mImportance;
float mX;
float mY;
//float mZ;
float mScore;
//float mSize;
PVector mForce;
ArrayList<Neighbor> neighbors = new ArrayList<Neighbor>();
//ArrayList<Node> neighbors = new ArrayList<Node>();
Node(int i)
{
mId = i;
mX = random(15,680);
mY = random(15,680);
//mZ = 0;
mScore = 15;
mForce = new PVector(0,0);
mName = "";
mImportance=0.01;
}
}

void setup()
{
size(700,700);
background (0);
frameRate(FRAMERATE);
String[] lines = loadStrings("order("+K+").txt");
String[] lines1 = loadStrings("pname("+K+").txt");
int[] num0 = int(split(lines[lines.length-1],' '));
int[] num1 = int(split(lines[0],' '));
//println(imp[0],imp[1]);
int start = num1[0];
int end = num0[0];
float[] num2 = float(split(lines1[lines1.length-1], ' '));
float[] num3 = float(split(lines1[0], ' '));
println(num2[1]);
float MIN = num2[1];
float MAX = num3[1];

for (int k=start; k<=end; k++)
{
allNodes.add(new Node(k));
Node curr = allNodes.get(k-1);
String[] name = split(lines1[k-1],' ');
float[] imp = float(split(lines1[k-1],' '));
curr.mName = name[0];
curr.mImportance = imp[1];
curr.mScore = impToSize(imp[1], MAX, MIN);   // compute the size of nodes;
//(imp[1]-0.0028)/0.00002+10;
//println(imp[1]);
}
//println(allNodes.size());
/*
for (int i=0; i < allNodes.size(); i++)
{
allNodes.get(i).mX=random(10,450);
allNodes.get(i).mY=random(10,450);
 // temp.mZ=5*i;
}
*/
for (int i=0; i<lines.length; i++)
{
int[] num = int(split(lines[i],' '));
if (num[1] > end)
  {
    end = num[1];
    allNodes.add(new Node(num[1]));
  }
println(allNodes.size());
Node temp0 = allNodes.get(num[0]-1);    // because the node's id starts at 1, index is off by 1;
Node temp1 = allNodes.get(num[1]-1);
temp0.neighbors.add(new Neighbor(temp1, num[2]));
//temp1.neighbors.add(temp0);
//temp0.mScore = num[2];
}
println(start, end);
println(allNodes.size());
}

void draw()
{
background (0);

for (int i=0 ;i<allNodes.size(); i++)
{
PVector F = new PVector(0,0);
PVector repulse, attraction;
float iX = allNodes.get(i).mX;
float iY = allNodes.get(i).mY;

// repulsive force between every node
for (int j=0; j<allNodes.size(); j++)
{
  if (i != j)
  {
  float jX = allNodes.get(j).mX;
  float jY = allNodes.get(j).mY;
  repulse = new PVector(iX-jX, iY-jY);
  float distance = repulse.mag();
  float magnitude = REPULSION/sq(distance);//30000/sq(distance); 
  repulse.normalize();  // do not know if necessary, but it's safe
  repulse.setMag(magnitude);
  F.add(repulse);
  }
}

// attractive force in neighboring nodes
for (int k=0; k<allNodes.get(i).neighbors.size(); k++)
{
float kX = allNodes.get(i).neighbors.get(k).mNode.mX;
float kY = allNodes.get(i).neighbors.get(k).mNode.mY;
attraction = new PVector(kX-iX, kY-iY);
float len = attraction.mag();
float magnitude = ATTRACTION*log(len);//0.5*len;//3*(log(len)/log(2));
attraction.normalize();
attraction.setMag(magnitude);
F.add(attraction);
}
Node curr = allNodes.get(i);
if (curr.neighbors.size() == max(allNodes.get(0).neighbors.size(), allNodes.get(1).neighbors.size()))
  F.setMag(0.1*F.mag());

curr.mForce = F;
/*if (curr.mX <= 15 || curr.mX >= width-15 || curr.mY <= 15 || curr.mY >= height-15)
{
  curr.mForce.rotate(PI);
//  curr.mForce.setMag(5*curr.mForce.mag());
}*/
//curr.mX += 0.1*(curr.mForce.x);
//curr.mY += 0.1*(curr.mForce.y);
}

for (int i=0; i < allNodes.size(); i++)
{
Node curr = allNodes.get(i);
if (curr.mX <= 15)
curr.mForce.add(new PVector(300, 0));
if (curr.mY <= 15)
curr.mForce.add(new PVector(0,300));
if (curr.mX >= width-15)
curr.mForce.add(new PVector(-300, 0));
if (curr.mY >= height-15)
curr.mForce.add(new PVector(0,-300));
curr.mX += 0.06*(curr.mForce.x);
curr.mY += 0.06*(curr.mForce.y);
//curr.mX = min(width-15, max(15,curr.mX));
//curr.mY = min(height-15, max(15,curr.mY));
}

for (int i=0; i < allNodes.size(); i++)
{
Node temp = allNodes.get(i);
if (mouseOverCircle(temp.mX, temp.mY, temp.mScore))
  {
    temp.mScore *=3;
    noStroke();
    fill(0, 0, 255);
    ellipse(temp.mX, temp.mY, temp.mScore, temp.mScore);
    temp.mScore /= 3;
    textFont(f,12);
    //pushMatrix();
    fill(0,255,255);
    text(temp.mName, temp.mX+0.5*temp.mScore, temp.mY+0.5*temp.mScore);
    fill(0, 0, 255);
    //popMatrix();
  }
else
//pushMatrix();
//translate(temp.mX,temp.mY);
noStroke();
fill(0, 0, 255);
ellipse(temp.mX, temp.mY, temp.mScore, temp.mScore);
textFont(f,12);
//pushMatrix();
fill(0, 255, 255);
text(temp.mName, temp.mX+0.5*temp.mScore, temp.mY+0.5*temp.mScore);
//popMatrix();
for (int j=0; j<temp.neighbors.size(); j++)
{
Neighbor nei = temp.neighbors.get(j);
Node temp2 = nei.mNode;
//noFill();
float e = edgeBrightness(nei.connWeight);
//float e2=(nei.connWeight-900)/0.7071+30;//(nei.connWeight-900)/0.4605+40;//(nei.connWeight-700)/1.391+40;//(nei.connWeight-200)/3.716+40;
stroke(255, e);
line(temp.mX, temp.mY, temp2.mX, temp2.mY);
}
}
}

