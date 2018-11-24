function [] = SetPathDir()
    %Fonction permettant � tout les script Matlab pr�sent dans le m�me dossier
    %que cette fonction SetPathDir(), lors de son appel, d'ajouter les 5
    %chemins des r�pertoires ProjetEconoPART2, Exercices, MyFunctions, Exercice
    %3 et Datas

%Chemin du r�pertoire principal
DirPath = which('SetPathDir.m');
DirPath = strrep(DirPath, '/SetPathDir.m', '');

%Chemin du r�pertoire Exercices
CointegrationPath = char('/Cointegration');
CointegrationPath = strcat(DirPath, CointegrationPath);

%Chemin du r�pertoire MyFunctions
ImportPath = char('/Import');
ImportPath = strcat(DirPath, ImportPath);

%Chemin du r�pertoire Exercices 3
StratPath = char('/Strategies');
StratPath = strcat(DirPath, StratPath);

%Ajout des chemins dans le compilateur 
addpath(CointegrationPath);
addpath(ImportPath);
addpath(StratPath);
addpath(DirPath);

end
