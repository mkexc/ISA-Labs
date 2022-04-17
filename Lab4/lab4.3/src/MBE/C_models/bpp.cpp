#include <iostream>
// #include <bitset>

int stdpp(u_int16_t a, u_int32_t m, int n);
int modpp(u_int16_t a, u_int32_t m, int n);

using namespace std;

int main(const int argc, const char** argv)
{

    u_int16_t a=20;
    u_int32_t m=27261;
    int n=16;
    
    if(stdpp(a,m,n)==modpp(a,m,n))
        cout << "SUCCESS" << endl;
    else
        cout << "FAIL" << endl; 

    return 0;
}

int stdpp(u_int16_t a, u_int32_t m, int n)
{
    int32_t pp[n/2+1],prod=0;
    u_int16_t m_temp, mask;

    m=(m<<1); // shift for m-1
    mask=0x7;
    for (int i=0; i<(n/2)+1; i++)
    {
        
        m_temp=m&mask;
        m_temp=m_temp>>(i*2);
        switch (m_temp)
        {
        case 0: pp[i]=0;
            break;
        case 1: pp[i]=a;
            break;
        case 2: pp[i]=a;
            break;
        case 3: pp[i]=2*a;
            break;
        case 4: pp[i]=-2*a;
            break;
        case 5: pp[i]=-a;
            break;
        case 6: pp[i]=-a;
            break;
        default: pp[i]=0;
            break;
        }
        mask=mask<<2;
        prod+=pp[i]<<(i*2);
    }
    cout << "Product with stdpp : " << prod << endl;
    return prod;
}

int modpp(u_int16_t a, u_int32_t m, int n)
{
    int64_t pp[n/2+1],prod=0;
    u_int16_t m_temp, mask;
    u_int64_t pool[2]={a,a<<1};
    int sign=0, temp=0;
    m=(m<<1); // shift for m-1
    mask=0x7; // mask for first 3 multiplier's bits

    for (int i=0; i<n/2+1; i++)
    {
        // Masked muultiplier
        m_temp=m&mask;
        m_temp=m_temp>>(i*2);
        
        sign=0;

        //BOOTH MODIFIED ENCODER
        switch (m_temp)
        {
            case 1 : { 
                pp[i]=pool[0]; // A
                break;
            }
            case 2 : {
                pp[i]=pool[0]; // A
                break;
            }
            case 3: {
                pp[i]=pool[1]; // 2A
                break;
            }
            case 4: {
                pp[i]=pool[1] ^ 0xFFFFFFFFFFFFFFFF; pp[i]++; sign=1; // 2A ==> -2A
                break;
            }
            case 5: {
                pp[i]=pool[0] ^ 0xFFFFFFFFFFFFFFFF; pp[i]++; sign=1; // A ==> -A
                break;
            }
            case 6: {
                pp[i]=pool[0] ^ 0xFFFFFFFFFFFFFFFF; pp[i]++; sign=1; // A ==> -A
                break;
            }
            default: {
                pp[i]=0;    // 0
                break;
            }
        }
        // Partial products' MSBs management
        if(i==0) // first row of partial products
        {
            temp=(sign<< (n+1)) | (sign << (n+2)) | ((~sign&0x1) << (n+3));
        }
        else if (i==n/2-1) // 
        {
            temp=((~sign&0x1)<<(n+1));
        }
        else // every other row
        {
            temp=(((~sign)&0x1)<<(n+1)) | (1<<(n+2));
        }

        pp[i]&=0x1FFFF; // MSBs cleanup
        pp[i]|=temp; // Modified MSBs apply

        // Binary print
        // std::bitset <64> bin1(pp[i]);
        // std::cout << bin1 << std::endl;

        // Mask update for next row
        mask=mask<<2;
        // Sum partial product with proper weight to total product
        prod+=pp[i]<<(i*2);
    }
    cout << "Product with modpp : " << (prod&0xFFFFFFFF) << endl;
    return prod;
}