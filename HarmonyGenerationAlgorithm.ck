
    0 => int startnoteofscale; 
        //starts from A3 at 220HZ
        //A is 0, A# is 1, B is 2, etc.
    0 => int currentnote;
        //This is the variable used to store the note as it goes through the melody algorithm
    [0,2,3,5,7,8,10,12] @=> int minsintervals[]; 
    [0,2,4,5,7,9,11,12] @=> int majsintervals[]; 
    [0] @=> int currentscale[]; 
    1 => int directionup; //Current direction melody is moving in
    int notes[3][16]; 
    int chords[16]; 
    int inversions[16];   
    string cadences[16];
    int melodyintervals[15]; //Intervals between neighbouring notes stored here to calculate progressions
    int majororminor; //1 is major, 0 is minor
    //0 => int counter;

    TriOsc osc1 => dac;
    0.3 => osc1.gain;
    TriOsc osc2 => dac;
    0.3 => osc2.gain;
    TriOsc osc3 => dac;
    0.3 => osc3.gain;

fun void GenMel()
{ 
    Math.random2(0,999999) => int randseed;
    Std.srand(randseed); //fav seeds: 973266, 
    Math.random2(0,1) => majororminor;
    if (majororminor){majsintervals @=> currentscale;}else{minsintervals @=> currentscale;}
    
    for( 0 => int i; i < notes[0].size(); i++ )
    { 
        if (directionup == 1){currentnote + 1 => currentnote;}
        else {currentnote - 1 => currentnote;}    
        
        (Math.floor(Math.exp(Math.random2f(0,2)))) $ int => int jumpinterval;
        if (Math.random2(0,1)){-jumpinterval => jumpinterval;}
        if (Math.random2(0,1)){0 => jumpinterval;}
        currentnote - jumpinterval => currentnote;
        
        if (currentnote <= 0) {0 => currentnote; 1 => directionup;}
        if (currentnote >= 7) {7 => currentnote; 0 => directionup;}
        currentnote => notes[0][i];
    }
    chout <= IO.newline(); chout <= "NEW ";
    if (majororminor){chout <= "MAJOR";}else{chout <= "MINOR";}
    chout <= " MELODY:  "; chout <= IO.newline();
    
     chout <= IO.newline();
    chout <= "Index     : "; 
    for( 0 => int i; i < 10; i++ )
    { chout <= i; chout <= " ";}
    ["A","B","C","D","E","F"] @=> string base16[];
    for( 0 => int i; i < 6; i++ )
    { chout <= base16[i]; chout <= " ";}

    0 => int cadencedecided;
    0 => int cc; //currentchord
    

    for( 0 => int i; i < notes[0].size(); i++ )
    {     
        0 => cadencedecided;
        if(i!=cc){1 => cadencedecided;}else{0 => cadencedecided;}
            if (notes[0][i] == 4 || notes[0][i] == 6 || notes[0][i] == 1) //is it a V chord
            {
                if(cadencedecided == 0 && cc <= notes[0].size()-2){if (notes[0][i+1] == 0 || notes[0][i] == 2 || notes[0][i] == 4 || notes[0][i] == 7) //is it a I chord
                {  "P1" => cadences[i];   4 => chords[i];  "P2" => cadences[cc+1]; 0 => chords[i+1]; cc++;cc++; 1 => cadencedecided;}} //Perfect Cadence
                if(cadencedecided == 0 && cc <= notes[0].size()-2){if (notes[0][i+1] == 5 || notes[0][i] == 0 || notes[0][i] == 2) //is it a VI chord
                {  "D1" => cadences[i]; 4 => chords[i]; "D2" => cadences[cc+1];  5 => chords[i+1]; cc++;cc++; 1 => cadencedecided;}} //Deceptive Cadence
                if(cadencedecided == 0 && cc <= notes[0].size()-1){"H " => cadences[cc]; 4 => chords[i]; cc++; 1 => cadencedecided;} //Half Cadence
            }
            
            if (notes[0][i] == 3 || notes[0][i] == 5 || notes[0][i] == 0) //is it a IV chord
            {
                if(cadencedecided == 0 && cc <= notes[0].size()-2){if (notes[0][i+1] == 0 || notes[0][i] == 2 || notes[0][i] == 4) //is it a I chord
                {  "p1" => cadences[cc]; 3 => chords[i]; "p2" => cadences[cc+1];  0 => chords[i+1]; cc++;cc++; 1 => cadencedecided;}} //Plagal Cadence           
            }   
            
        if(cadencedecided == 0){"N " => cadences[cc]; 9 => chords[i];1 => cadencedecided;cc++; } //No cadence
              
    }
    //if(cadences[15]!="P2"&&cadences[15]!="D2"&&cadences[15]!="H"&&cadences[15]!="p2"&&cadences[15]!="H"){counter++;<<<counter>>>;}//checks if last space is blank
    
    for( 0 => int i; i < chords.size()-1; i++ )
    {
        if (chords[i] < 9)
        {   
            (notes[0][i]-chords[i]) => inversions[i];
            if (inversions[i]<0){inversions[i]+7=>inversions[i];}
            inversions[i]/2=>inversions[i];
            if (notes[0][i]==7&&chords[i]==0){0=>inversions[i];}
            //if (inversions[i]!=0){inversions[i]%3=>inversions[i];}
        }
        else
        {
        9 => inversions[i];   //means no actual chord was given
        }
    }
    for( 0 => int i; i < notes[0].size(); i++ )    //determines 2nd and 3rd part note values
    {
        if (chords[i]<9)
        {
            if (inversions[i]==0){(notes[0][i]+2)%7 => notes[1][i];(notes[1][i]+2)%7 => notes[2][i];} 
            if (inversions[i]==1){(notes[0][i]+2)%7 => notes[1][i];(notes[1][i]+3)%7 => notes[2][i];}
            if (inversions[i]==2){(notes[0][i]+3)%7 => notes[1][i];(notes[1][i]+2)%7 => notes[2][i];}
            
            //if (inversions[i]==2){(notes[0][i]+7)%8 => notes[3][i];}else {(notes[0][i]+6)%8 => notes[3][i];}
        }
        else {9 => notes[1][i]; 9 => notes[2][i];}
    }
       
    chout <= IO.newline();
    for( 0 => int b; b < 3; b++ )
    {
        chout <= "Notes "; chout <= b+1; chout <="   : ";
        for( 0 => int i; i < notes[b].size(); i++ )
        { if (notes[b][i]==9){chout <= " "; chout <= " "; }
        else {chout <= notes[b][i]; chout <= " "; }}
        chout <= IO.newline();
    }
    
    chout <= "Cadences  : "; 
    for( 0 => int i; i < cadences.size(); i++ )
    { if (cadences[i]=="N "){chout <= "  ";}
    else{chout <= cadences[i];}}
    chout <= IO.newline();
    

    chout <= "Chords    : ";
    for( 0 => int i; i < chords.size(); i++ )
    { if (chords[i]==9){chout <= " "; chout <= " "; }
    else{chout <= chords[i]; chout <= " "; }}    
    chout <= IO.newline();
    
    chout <= "Inversions: ";
    for( 0 => int i; i < inversions.size(); i++ )
    { if (inversions[i]==9){chout <= " "; chout <= " "; }
    else{chout <= inversions[i]; chout <= " "; }}
    chout <= IO.newline();
    <<<"Seed:",randseed>>>;
}

GenMel();

while(1)
{
    for( 0 => int i; i <4; i++ )
    {
        for( 0 => int i; i < notes[0].size(); i++ )
        {
        Math.pow(Math.pow(2,1./12.),currentscale[notes[0][i]]+startnoteofscale)*220 => osc1.freq;
        if (notes[1][i] <  9)
        {
            0.23 => osc2.gain;
            Math.pow(Math.pow(2,1./12.),currentscale[notes[1][i]]+startnoteofscale)*220 => osc2.freq;   
         
            0.25 => osc3.gain;
            Math.pow(Math.pow(2,1./12.),currentscale[notes[2][i]]+startnoteofscale)*220 => osc3.freq;   
              
        }
        else
        {
            if (osc2.gain() > 0 && osc3.gain() > 0)
            {
                osc2.gain()/2 => osc2.gain;
                osc3.gain()/2 => osc3.gain;
            }
        }
            200::ms => now;
        }
    }
    GenMel();
}
