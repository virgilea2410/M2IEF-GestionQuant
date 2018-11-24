% FONCTION D'ESTIMATION DU VECM - CONTRIBUTION DE MARCHE
% INPUTS:
%   - aSerie   = Vecteur contenant les séries
%   - Rank     = Rang de cointégration
%   - aLag     = Nombre de lag optimal pour les régressions
% OUTPUTS:
%   - VECMest  = Matrice contenant le modèle VECM éstimé
%   - Lamda_1  = Coefficiant du modele de cointégration DeltaP_CDS indiquant les contributions de P_CS sur P_CDS
%   - Lamda_2  = Coefficiant du modele de cointégration DeltaP_CS indiquant les contributions de P_CDS sur P_CS
%   - Lamda_1H = Hypothèse de significqtivité de Lamda_1 -> 1 si significatif, 0 sinon
%   - Lamda_2H = Hypothèse de significqtivité de Lamda_2 -> 1 si significatif, 0 sinon
%   - HAS1     = Borne inférieure de la contribution au marché selon Hasbrouck
%   - HAS2     = Borne supérieure de la contribution au marché selon Hasbrouck
%   - GG2      = Contribution au marché selon Gonzalo & Granger

function [VECMest, Lamda_1, Lamda_2, Lamda_1H, Lamda_2H, HAS1, HAS2, GG2] = EstimationVECM(aSeries, Rank, aLag)

NbSeries = size(aSeries, 2);

% Estimation du VECM
VECMmdl = vecm(NbSeries, 1, aLag); % Création du modèle VECM
VECMest = estimate(VECMmdl, aSeries); % Estimation du modèle VECM

Lamda_1 = VECMest.Adjustment(1,1)*VECMest.Cointegration(1,1); % Cointégration censé être transposé
Lamda_2 = -VECMest.Adjustment(2,1)*VECMest.Cointegration(2,1); % Cointégration censé être transposé
Sig1 = VECMest.Covariance(1,1);
Sig2 = VECMest.Covariance(2,2);
Sig12 = VECMest.Covariance(1,2);

SummarizeVECM = summarize(VECMest);
Lamda_1H =SummarizeVECM.Table{3,4} < 0.1 ;% Vrai si significatif
Lamda_2H =SummarizeVECM.Table{4,4} < 0.1; %

% Contribution de marché - Calcul des bornes de Hasbrouck et Gonzalo and Granger
DenomHAS = (Lamda_2^2)*Sig1-2*Lamda_1*Lamda_2*Sig12+(Lamda_1^2)*Sig2; 
NumHAS1 = (Lamda_2^2)*(Sig1-(Sig12^2)/Sig2);
NumHAS2 = (Lamda_2*sqrt(Sig1)-Lamda_1*Sig12/sqrt(Sig1))^2;

DenomHAS = (Lamda_2^2)*Sig1-2*Lamda_1*Lamda_2*sqrt(Sig12)+(Lamda_1^2)*Sig2; 
NumHAS1 = (Lamda_2^2)*(Sig1-Sig12/Sig2);
NumHAS2 = (Lamda_2*sqrt(Sig1)-Lamda_1*sqrt(Sig12)/sqrt(Sig1))^2;


HAS1 = NumHAS1/DenomHAS;
HAS2 = NumHAS2/DenomHAS;
GG2 = Lamda_2/(Lamda_2-Lamda_1);

end

% Informations relatives aux outputs Matlab des fonctions VECM
% myVECMest.Constant = constantes du modèle : c
% myVECMest.Adjustment = vitesse d'ajustement : A
% myVECMest.Cointegration = matrice de cointégration : B
% myVECMest.Impact = matrice des niveaux de long terme : Pi
