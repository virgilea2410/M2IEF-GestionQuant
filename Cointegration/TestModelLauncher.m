% FONCTION DE LANCEMENT DES TEST ET CALCUL DES MODELES
%   Fonction lancant les tests de coint�gration de Johansen ou le test de Causalit� de Granger
%       et lancement des calculs des mod�les VAR et VECM
% INPUTS:
%   - PriceCDS     = Vecteur des prix CDS associ�s � une entreprise
%   - PriceCS      = Vecteur des prix CS obtenu par rapport aux prix Gov ou SWAP et associ�s � une entreprise
% OUTPUTS:
%   - AnalyseType  = Nom du mod�le pertinant pour l'entreprise: Coint�gration / Causalit� (Coint�gration) / Causalit� (ADF) / ADF Diff
%   - Results      = Objet de r�sultats contenant les �l�ments associ�es au mod�le pertinant pour l'entreprise, avec r�sultats des hypoth�ses de tests et coeffciants, statistiques de test, p-Value et rang

function [AnalyseType Results] = TestModelLauncher(PriceCDS, PriceCS)

%HCointNC = NaN; HCointC1 = NaN; HCointC2 = NaN; H_CDSCauseCS = NaN; H_CSCauseCDS = NaN; decision = "";

nbVar = 2;

% Test ADF: V�rificaton du niveau d'int�gration des deux s�ries - m�me niveau requis
    % h = 1 : rejet de l'hypoth�se de racine unitaire nulle = pr�sence de racine unitaire = I(1)
HadfCDS = adftest(PriceCDS,'model','TS'); % Test ADF s�rie CDS Mod�le 3
if HadfCDS == 1
    HadfCDS = adftest(PriceCDS,'model','ARD'); % Test ADF s�rie CDS Mod�le 2
    if HadfCDS == 1
        HadfCDS = adftest(PriceCDS,'model','AR'); % Test ADF s�rie CDS Mod�le 1
    end
end

HadfCS = adftest(PriceCS,'model','TS'); % Test ADF s�rie CS Mod�le 3
if HadfCS == 1 
    HadfCS = adftest(PriceCS,'model','ARD'); % Test ADF s�rie CS Mod�le 2
    if HadfCS == 1
        HadfCS = adftest(PriceCS,'model','AR'); % Test ADF s�rie CS Mod�le 1
    end
end 


% Test de coint�gration ou test de causalit� et estimation des mod�les
if HadfCS == 0 && HadfCDS == 0 % Deux sont I(1) non stationnaires
    
    % Estimation du mod�le VAR et du nb de lag optimal via AIC
    Diff_CDS_CS = PriceCDS - PriceCS;
    Lag = FindVARLag(Diff_CDS_CS, 1, 10);
    ModelVAR = varm(1,Lag); % Estimation du mod�le VAR(p) avec p minimisant le crit�re AIC
    ResultVAR = estimate(ModelVAR,Diff_CDS_CS); % WARNING: DIF CDS_CS VS Y??
    
    
    % Test de coint�gration de Johanson
    [HCointNC, ~, ~] = jcitest([PriceCDS,PriceCS], 'Display', 'off','model','H1*','lag',Lag,'alpha',0.1); % Test de coint�gration non contraint
    [Results.Restricted0H, ~, ~, ~, ~] = jcontest([PriceCDS,PriceCS], 1, 'BVec', [1; -1; 0], 'model', 'H1*'); % Test de coint�gration contraint et constante nulle
    c = ResultVAR.Constant; % R�cup�ration de la constante du mod�le VAR(p)
    [Results.RestrictedCH, ~, ~, ~, ~] = jcontest([PriceCDS,PriceCS], 1, 'BVec', [1; -1; c], 'model', 'H1*'); % Test avec vecteur de coint�gration sans contrainte de nullit� de la constante
    Results.Rank0TH = HCointNC{1,1};
    Results.Rank1TH = HCointNC{1,2};
    
    % R�cup�raiton du rang de coint�gration et d�clanchement du processsus adequat
    if HCointNC{1,2} == 0 && HCointNC{1,1} == 1 % M�me rang I(1): Coint�gration --> VECM
        
        Rank = 1;
        [Results.Model, Results.Lambda1,Results.Lambda2,Results.Lambda1H,Results.Lambda2H, Results.HAS1, Results.HAS2, Results.GG] = EstimationVECM([PriceCDS PriceCS], Rank, Lag);
        AnalyseType = 'Coint�gration';
 
    else % Pas de coint�gration --> Causalit� Granger
       
       Lag = FindVARLag([PriceCDS,PriceCS], 0, 10);
       [Results.H_CDSCauseCS, Results.SumCoeffCDSCauseCS, Results.FstatCDSCauseCS, Results.CritikVal, Results.PvalCDSCauseCS] = GrangerCausalityTest(PriceCS, PriceCDS, Lag, 0.95); % V�rification CDS cause CS       
       [Results.H_CSCauseCDS, Results.SumCoeffCSCauseCDS, Results.FstatCSCauseCDS, Results.CritikVal, Results.PvalCSCauseCDS] = GrangerCausalityTest(PriceCDS, PriceCS, Lag, 0.95); % V�rification CS cause CDS
       AnalyseType = 'Causalit� (Coint�gration)'; 
       
        MyVarMdl = varm(nbVar, Lag);
        Results.Model = estimate(MyVarMdl, [PriceCDS,PriceCS]);

    end

elseif and(HadfCS == 1, HadfCDS == 1) % S�rie stationnaires
    
   % Absence de coint�gration --> Test de causalit� de Granger
   Lag = FindVARLag([PriceCDS,PriceCS], 0, 10);
   [Results.H_CDSCauseCS, Results.SumCoeffCDSCauseCS, Results.FstatCDSCauseCS, Results.CritikVal, Results.PvalCDSCauseCS] = GrangerCausalityTest(PriceCS, PriceCDS,Lag,0.95); % V�rification CDS cause CS 
   [Results.H_CSCauseCDS, Results.SumCoeffCSCauseCDS, Results.FstatCSCauseCDS, Results.CritikVal, Results.PvalCSCauseCDS] = GrangerCausalityTest(PriceCDS, PriceCS,Lag,0.95); % V�rification CS cause CDS 
   AnalyseType = 'Causalit� (ADF)'; 
   
    MyVarMdl = varm(nbVar, Lag);
    Results.Model = estimate(MyVarMdl, [PriceCDS,PriceCS]);

else
   
    AnalyseType = 'ADF Diff'; 
    Results.Model = "0";
end

end

% Informations Annexes
%   - HCointNC     = Hypoth�se li�e au test de coint�gration de Johansen non contraint
%   - HCointC1     = Hypoth�se li�e au test de coint�gration de Johansen contraint avec vecteur de coint�gration ayant une constante nulle
%   - HCointC2     = Hypoth�se li�e au test de coint�gration de Johansen contraint avec vecteur de coint�gration ayant une constante non nulle
%   - H_CDSCauseCS = Hypoth�se li�e au test de causalit� de Granger PriceCDS causant PriceCS
%   - H_CSCauseCDS = Hypoth�se li�e au test de causalit� de Granger PriceCS causant PriceCDS