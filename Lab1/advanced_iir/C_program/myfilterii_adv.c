#include<stdio.h>
#include<stdlib.h>

#define N 1 /// order of the filter 
#define NR 2
#define NB 10  /// number of bits

/* Advanced solution: 1st order filter IIR after 1-unrolling.
 * A and B coefficients are used in matlab to compute the new
   coefficients and then they are used here (after shift).*/

int y_func;

const int b0 = 1723 >> (13-NB); /// B0
const int B1_A1B0= 1996 >> (13-NB); /// B1-A1*B0 
const int A1B1= 272 >> (13-NB); /// -A1*B1 
const int A1_2 = 102 >> (13-NB); // A1ˆ2 
/// Perform fixed point filtering assuming direct form II
///\param x is the new input sample
///\return the new output sample
int myfilter(int x, int vin)
{
  static int sw[NR]; /// w shift register
  static int first_run = 0; /// for cleaning the shift register
  //static int y; /// output sample
  int i; /// index
  int w; /// intermediate value (w)
  
  int mult_b0 = 0, mult_b1_a1b0 = 0, mult_a1_2=0 , mult_a1b1=0; /// feed-back and feed-forward results
  int a_9_10;
  /// clean the buffer
  if (first_run == 0)
  {
    first_run = 1;
    for (i=0; i<NR; i++)
      sw[i] = 0;
  }

	printf ("myfilter func enters with x=%d, vin= %d\n", x, vin);

  if(vin)
  {
    /// compute feed-back and feed-forward
    mult_a1_2 = (sw[1]*A1_2) >> (NB+2);
    mult_b1_a1b0 = (sw[0]*B1_A1B0) >> (NB+2);
    mult_a1b1 = (sw[1]*A1B1) >> (NB+2);
    a_9_10 = mult_a1b1 + mult_b1_a1b0;	

    /// compute intermediate value (w) and output sample
    w = x + mult_a1_2;
    printf("W = %d\n",w);
    mult_b0= (w*b0) >> (NB+2);
    y_func = mult_b0 + a_9_10; 

    /// update the shift register
    for (i=NR-1; i>0; i--)
      sw[i] = sw[i-1];
    sw[0] = w;
  }
  printf("Int reg 0: %d\n", sw[0]);
  printf("Int reg 1: %d\n", sw[1]);
 
	printf ("myfilter func returns with %d\n\n", y_func<<(13-NB+3));
  return y_func<<(13-NB+3);
}

int main (int argc, char **argv)
{
  FILE *fp_in;
  FILE *fp_vin;
  FILE *fp_out;

  int x;
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
    y = myfilter(x>>(13-NB), vin);
    if(vin)
      fprintf(fp_out,"%d\n", y);
    fscanf(fp_in, "%d", &x);
    fscanf(fp_vin, "%d", &vin);
  } while (!feof(fp_in));

  fclose(fp_in);
  fclose(fp_out);

  printf("The used coeff are: B0 = %d, B1_A1B0 = %d, A1B1 = %d, A1_2 = %d\n", b0, B1_A1B0, A1B1, A1_2);


  return 0;

}
