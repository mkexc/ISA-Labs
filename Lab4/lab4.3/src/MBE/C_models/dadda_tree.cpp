#include <iostream>
#include <vector>
#include <string>

std::vector<int> d_generator(int NB);
void dadda_place(std::vector<std::vector<std::vector<std::string > > >& Array3D);
void dadda_print(std::vector<std::vector<std::vector<std::string > > >& Array3D);

int main(int argc, const char * argv[]) {

    if(argc != 2){
        std::cout << "Insert number of bits!" << std::endl;
    }
    
    int NB = atoi(argv[1]);
    std::vector<int> data=d_generator(NB);
    std::cout << "Generating Dadda Tree for number of bits: " << NB << std::endl << std::endl;
    
    std::cout << "Layers required are: " << data.size() << std::endl;
    std::cout << "d of top layer is equal to: " << data[data.size()-1] << std::endl << std::endl;
    
    std::vector<std::vector<std::vector<std::string > > > Array3D(data.size());
    for (int i=0; i<data.size(); i++){
        Array3D[i] = std::vector<std::vector<std::string > >(data[i], std::vector<std::string>(2*NB,std::string("*")));
    }
    
    dadda_place(Array3D);
    dadda_print(Array3D);
    
    return 0;
}

std::vector<int> d_generator(int NB)
{
    std::vector<int> data(1,2);
    
    //std::cout << "Layer= " << data.size()-1 << " d= " << data[data.size()-1] << std::endl;
    while (data[data.size()-1]<(NB/2)+1) {
        data.resize(data.size()+1);
        data[data.size()-1]=(int)(3.0/2*data[data.size()-2]);
        //std::cout << "Layer= " << data.size()-1 << " d= " << data[data.size()-1] << std::endl;
    }
    data[data.size()-1]=(NB/2)+1;
    
    return data;
}

void dadda_place(std::vector<std::vector<std::vector<std::string > > >& Array3D)
{
    
    std::vector<int> N_fa(Array3D.size());
    std::vector<int> N_fa_rows(Array3D.size());
    N_fa[0]=(int)Array3D[0][0].size()-4;
    N_fa_rows[0]=0;
    int NB2= (int)Array3D[0][0].size();
    for (int i=0;i<Array3D.size();i++){
        if(i==0){
            for (int j=0;j<Array3D[i].size();j++){
                for (int k=0; k<NB2; k++){
                    //Array3D[i][j][k]="\033[1;31mA\033[0m";
                    Array3D[i][j][k]="A";
                }
            }
        }
        else{
            N_fa[i]=N_fa[i-1] - N_fa_rows[i-1]*4;
            N_fa_rows[i]=(int)Array3D[i].size()/3; // d/3
            std::cout << "N_fa current layer top row: " << N_fa[i] << std::endl;
            std::cout << "N_fa_rows current layer top row: " << N_fa_rows[i] << std::endl << std::endl;
            for(int j=0; (j<N_fa_rows[i]) && (N_fa[i]-(j*4) >= 4) ; j++)
            {
                std::cout<<"K: " << NB2/2.0 +2 <<std::endl;
                for (int k=NB2/2.0 +2;k<=(N_fa[i]-(4*j))/2 + NB2/2 +2 ; k++) {
                    if(k==NB2/2 +2 + (N_fa[i]-(4*j))/2 && i!=1)
                    {
                        Array3D[i][j*3][k]="H";
                        Array3D[i][(j*3)+1][k]="H";
                        
                    }
                    else if(k!=NB2/2 +2 + (N_fa[i]-(4*j))/2){
                        Array3D[i][j*3][k]="F";
                        Array3D[i][(j*3)+1][k]="F";
                        Array3D[i][(j*3)+2][k]="F";
                    }
                }
                std::cout << "K limit: " << NB2/2 +1 - ((N_fa[i]-(4*j))/2+1) << std::endl;
                for (int k=NB2/2 +1;k>=NB2/2 +1 - ((N_fa[i]-(4*j))/2+1) ; k--) {
                    if(k>=NB2/2 +1 - (N_fa[i]-(4*j))/2 + 1)
                    {
                        Array3D[i][j*3][k]="F";
                        Array3D[i][(j*3)+1][k]="F";
                        Array3D[i][(j*3)+2][k]="F";
                    }
                    else{
                        Array3D[i][j*3][k]="H";
                        Array3D[i][(j*3)+1][k]="H";
                        
                    }
                }
            }
        }
    }
    
    
}

void dadda_print(std::vector<std::vector<std::vector<std::string > > >& Array3D)
{
    std::cout<<"Dadda Tree Compressors Placement:" << std::endl << std::endl;
    
    for(int i=(int)Array3D.size()-1;i>=0;i--){
        std::cout << "////////////////////////////////////////// Layer " << i << std::endl;
        for (int j=0; j<(int)Array3D[i].size(); j++) {
            for (int k=(int)Array3D[i][j].size()-1; k>=0; k--) {
                std::cout << Array3D[i][j][k] << " ";
            }
            std::cout << std::endl;
        }
    }
    
    
}
