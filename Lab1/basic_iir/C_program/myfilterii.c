#include<stdio.h>
#include<stdlib.h>

#define N 1 /// order of the filter 
#define NB 10  /// number of bits

/* 
 * Basic solution: 1st order filter IIR with input shifted 
   from 13 to 10 bit.
 * NB = 10 bits allows to mantain the THD = -36 dB.
*/

const int b0 = 1723>>(13-NB); /// B0
const int b[N]={1723>>(13-NB)}; /// [B1]
const int a[N]={-649>>(13-NB)}; /// [A1]

int y_func;


/// Perform fixed point filtering assuming direct form II
///\param x is the new input sample
///\return the new output sample
int myfilter(int x, int vin)
{
  
  static int first_run = 0; /// for cleaning the shift register
  static int sw[N];  /// w shift register
  int i; /// index
  int w; /// intermediate value (w)
  //int y; /// output sample
  int fb, ff; /// feed-back and feed-forward results

  /// clean the buffer
  if (first_run == 0)
  {
    first_run = 1;
    for (i=0; i<N; i++)
      sw[i] = 0;
  }

	printf ("myfilter func enters with x  =%d , vin = %d\n", x, vin);
  
  if(vin)
  {
      /// compute feed-back and feed-forward
    fb = 0;
    ff = 0;
    for (i=0; i<N; i++)
    {
      fb -= (sw[i]*a[i]) >> (NB+2);
      ff += (sw[i]*b[i]) >> (NB+2);
    }

    //printf ("sw[0]=%d  fb=%d   ff=%d\n", sw[0], fb, ff);	

    /// compute intermediate value (w) and output sample
    w = x + fb;
    //printf ("w=x+fb=%d+%d=%d\n", x,fb,w);
    y_func = (w*b0) >> (NB+2);
    //printf ("y=w*b0=%d*%d=%d (6 LSBs ARE THROWN AWAY)\n", w,b0,y);
    y_func += ff;
    //printf ("y=y+ff=%d\n", y);

    /// update the shift register
    for (i=N-1; i>0; i--)
      sw[i] = sw[i-1];
    sw[0] = w;
  }
  printf ("Int reg= %d\n",sw[0]);
  
 
	printf ("myfilter func returns with %d\n\n", y_func<<(13-NB+3));
  return y_func<<(13-NB+3);
}

int main (int argc, char **argv)
{
  FILE *fp_in;
  FILE *fp_vin;
  FILE *fp_out;

  int x;
  int x_tmp=0; //to keep the input stable when vin=0
  int y;
  int vin;

  /// check the command line
  if (argc != 4)
  {
    printf("Use: %s <input_file> <output_file>\n", argv[0]);
    exit(1);
  }

  /// open files
  fp_in = fopen(argv[1], "r");
  if (fp_in == NULL)
  {
    printf("Error: cannot open %s\n", argv[1]);
    exit(2);
  }
  fp_vin = fopen(argv[2], "r");
  if (fp_vin == NULL)
  {
    printf("Error: cannot open %s\n", argv[2]);
    exit(2);
  }
  fp_out = fopen(argv[3], "w");

  /// get samples and apply filter
  fscanf(fp_in, "%d", &x);
  fscanf(fp_vin, "%d", &vin);
  do{
    //if(vin == 0)
    //  x=x_tmp;
    y = myfilter(x>>(13-NB),vin);
    if (vin)
      fprintf(fp_out,"%d\n", y);
	// Store x to keep the input stable when vin=0
	//x_tmp=x;
    fscanf(fp_in, "%d", &x);
    fscanf(fp_vin, "%d", &vin);
  } while (!feof(fp_in));

  fclose(fp_in);
  fclose(fp_vin);
  fclose(fp_out);

  return 0;

}
