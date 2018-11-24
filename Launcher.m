clc
close all
clear all

%% IMPORT DE DONNEES CDS et CS

SetPathDir();

[Data_CDS, Data_Bond, Import_Govt, ...
    Import_Swap, Names, Names_Swap, ...
    Names_Govt, Dates_Main, Equi] = ImportDataMain();

% Passage de toutes les donn�es en bps
Data_Bond = 100.*Data_Bond;
Import_Govt = 100.*Import_Govt;
Import_Swap = 100.*Import_Swap;


%% Cr�ation des donn�es n�cessaires

nRow = size(Data_CDS,1);
nCol = size(Data_CDS,2);

colUSZone = find(ismember(Names_Govt,'US') ==1);
colUSDPair = find(ismember(Names_Swap,'USD') ==1);

PriceCDS = Data_CDS;

% Recherche de la base optimale
PriceCSswap = Data_Bond-repmat(Import_Swap(:,colUSDPair),1,nCol);
PriceCSgov = Data_Bond-repmat(Import_Govt(:,colUSZone),1,nCol);
BasisSWAP = PriceCDS - PriceCSswap;
BasisGov = PriceCDS - PriceCSgov;

AveSwap = mean(mean(BasisSWAP));
AveGov = mean(mean(BasisGov));

if abs(AveSwap) < abs(AveGov)
    UsedBasis = 'SWAP';
    PriceCS = PriceCSswap;
    Basis = BasisSWAP;
else
    UsedBasis = 'GOVT';
    PriceCS = PriceCSgov;
    Basis = BasisGov;
end

clear BasisSWAP BasisGov colUSZone colUSDPair PriceCSswap PriceCSgov
clear Import_Swap Import_Govt Data_Bond Data_CDS Names_Swap Names_Govt

%% Lancement des estimations et des tests de coint�gration/causalit�
clc;

DicoGlobal = cell(nRow,2);
DicoBacktest = cell(nCol+1,3);

DicoBacktest(1,1) = {"Entreprise Name"};
DicoBacktest(1,2) = {"Analyse Type"};
DicoBacktest(1,3) = {"Model Estimation"};

nbVAR = 0;
nbVECM = 0;
nbAutre = 0;

for i = 1:nCol
    
    [ResultType, Result] = TestModelLauncher(PriceCDS(:,i),PriceCS(:,i));
    
    DicoGlobal(i,1) = {ResultType};
    DicoGlobal(i,2) = {Result};
    
    DicoBacktest(i+1,1) = {Names(1,i)};
    DicoBacktest(i+1,2) = {ResultType};
    DicoBacktest(i+1,3) = {Result.Model};
    
    if ResultType(1:9) == 'Coint�gra'
        nbVECM = nbVECM+1;
    elseif ResultType(1:9) == 'Causalit�'
        nbVAR = nbVAR+1;
    else
        nbAutre = nbAutre +1;
    end
    
end

[DicoCointegration, DicoCausalite] = FillDicos(Names,DicoGlobal,nbVAR,nbVECM);

DisplayCointegrationCausality(DicoCausalite,DicoCointegration);

if nbAutre > 0; msgbox('S�ries avec ordre d''int�gration diff�rents'); end

clear DicoGlobal i nbAutre nbVECM nbVAR ResultType Result
 

%% Regression OLS : Short Run Deviations

%% Import des donn�es OLS

[Import_OLSGov2Y, Import_OLSGov10Y, Import_OLSPut, ...
    Import_OLSOOTR, Import_OLSIndex, Import_OLSStock, ...
    Names_OLSGov2Y, Names_OLSGov10Y, Names_OLSPut, Names_OLSIndex, Dates_OLS] = ImportDataOLS();

% Cr�ations des variables en diff�rence
lagged_EquityPrice = lagmatrix(Import_OLSStock,1);
lagged_EquityPrice = lagged_EquityPrice(2:end,1);
lagged_Index = lagmatrix(Import_OLSIndex,1);
lagged_Index = lagged_Index(2:end,1);
OLS_InterestRate = diff(Import_OLSGov10Y);
OLS_SlopeYield = diff((Import_OLSGov10Y-Import_OLSGov2Y));
OLS_EquityPrice = diff(Import_OLSStock)./lagged_EquityPrice;
OLS_ImpliedVol = diff(Import_OLSPut);
OLS_Index = diff(Import_OLSIndex)./lagged_Index;
OLS_OOTheRun = diff(Import_OLSOOTR);

% Retraitement des donn�es utiles
MemberMain = ismember(Dates_Main, Dates_OLS);
FindRow = find(MemberMain==ones(size(MemberMain,1),1));
OLS_PriceCS = diff(PriceCS(FindRow,:))./100;
OLS_PriceCDS = diff(PriceCDS(FindRow,:))./100;
OLS_LaggedBasis = diff(lagmatrix(Basis(FindRow,:),1))./100;
OLS_LaggedCDS = lagmatrix(OLS_PriceCDS,1);

% Redimensionnement des vecteurs
OLS_InterestRate = OLS_InterestRate(2:end,:);
OLS_SlopeYield = OLS_SlopeYield(2:end,:);
OLS_EquityPrice = OLS_EquityPrice(2:end,:);
OLS_ImpliedVol = OLS_ImpliedVol(2:end,:);

OLS_Index = OLS_Index(2:end,:);
OLS_OOTheRun = OLS_OOTheRun(2:end,:);
OLS_PriceCS = OLS_PriceCS(2:end,:);
OLS_PriceCDS = OLS_PriceCDS(2:end,:);
OLS_LaggedBasis = OLS_LaggedBasis(2:end,:);
OLS_LaggedCDS = OLS_LaggedCDS(2:end);

clear Text_OLSGov2Y Text_OLSGov10Y Text_OLSPut Text_OLSIndex Text_OLSStock
clear Import_OLSGov2Y Import_OLSGov10Y Import_OLSStock Import_OLSPut Import_OLSIndex Import_OLSOOTR
clear lagged_EquityPrice lagged_Index
clear MemberMain FindRow


%% Lancement des r�gressions

regressorMatrix3 = [];
regressorMatrix4 = [];
explainedCDS = [];
explainedCS = [];
e =[];
nbRow = size(OLS_InterestRate,1);

for i = 1:nCol
    
    currCompany = Names(1,i);
    [rowpos] = find(ismember(Equi,currCompany) ==1);
    
    currZone = Equi{rowpos,2};
    currCountry = Equi{rowpos,3};
    
    colInterestRate = find(ismember(Names_OLSGov10Y,currCountry) ==1);
    colYieldCurve = colInterestRate;
    colImpliedVol = find(ismember(Names_OLSPut,currZone) ==1);
    colIndex = find(ismember(Names_OLSIndex,currZone) ==1);
            
    regressorMatrix1 = [OLS_InterestRate(:,colInterestRate), OLS_SlopeYield(:,colYieldCurve), OLS_Index(:,colIndex), ...
                       OLS_EquityPrice(:,i), OLS_ImpliedVol(:,colImpliedVol)];       
    regressorMatrix2 = [OLS_InterestRate(:,colInterestRate), OLS_SlopeYield(:,colYieldCurve), OLS_Index(:,colIndex), ...
                       OLS_EquityPrice(:,i), OLS_ImpliedVol(:,colImpliedVol), OLS_OOTheRun(:,1), OLS_LaggedBasis(:,i)];            
    
    % Colonnes 1 et 5: r�gression sans constante
    % Price = InterestRate + Slope + Index + Equity + ImpliedVol
    mdlCS1 = fitlm(regressorMatrix1,OLS_PriceCS(:,i),'Intercept',false);
    mdlCDS1 = fitlm(regressorMatrix1,OLS_PriceCDS(:,i),'Intercept',false);
    OLS_CS1_Result(i,:) = mdlCS1.Coefficients{:,1}';
    OLS_CS1_Tstat(i,:) = mdlCS1.Coefficients{:,3}';
    OLS_CS1_R2(i,:) = mdlCS1.Rsquared.Adjusted;
    OLS_CDS1_Result(i,:) = mdlCDS1.Coefficients{:,1}';
    OLS_CDS1_Tstat(i,:) = mdlCDS1.Coefficients{:,3}';
    OLS_CDS1_R2(i,:) = mdlCDS1.Rsquared.Adjusted;
     
    % Colonnes 2 et 6: r�gression sans constante
    % Price = InterestRate + Slope + Index + Equity + ImpliedVol + OOTR + LaggedBasis
    mdlCS2 = fitlm(regressorMatrix2,OLS_PriceCS(:,i),'Intercept',false);
    mdlCDS2 = fitlm(regressorMatrix2,OLS_PriceCDS(:,i),'Intercept',false);
    OLS_CS2_Result(i,:) = mdlCS2.Coefficients{:,1}';
    OLS_CS2_Tstat(i,:) = mdlCS2.Coefficients{:,3}';
    OLS_CS2_R2(i,:)= mdlCS2.Rsquared.Adjusted;
    OLS_CDS2_Result(i,:) = mdlCDS2.Coefficients{:,1}';
    OLS_CDS2_Tstat(i,:) = mdlCDS2.Coefficients{:,3}';
    OLS_CDS2_R2(i,:)= mdlCDS2.Rsquared.Adjusted;
    
    % Pr�paration panel + CDS Lagged
    explainedCDS = [explainedCDS ; OLS_PriceCDS(:,i)];
    explainedCS = [explainedCS ; OLS_PriceCS(:,i)];
    regressorMatrix3 = [regressorMatrix3 ; [regressorMatrix1, repmat(OLS_LaggedCDS(:,i),1,5).*regressorMatrix1]];                
    regressorMatrix4 = [regressorMatrix4 ; [regressorMatrix2, repmat(OLS_LaggedCDS(:,i),1,7).*regressorMatrix2]];        
    adde = [zeros(nbRow,i-1) ones(nbRow,1) zeros(nbRow,nCol-i)];
    e = [e; adde];
    
end

% Colonnes 3 et 7: r�gression donn�es de panel 
% Price = InterestRate + Slope + Index + Equity + ImpliedVol + CDS Lagged
mdlCS3 = fitlm([e regressorMatrix3],explainedCS(:,1),'Intercept',false);
mdlCDS3 = fitlm([e regressorMatrix3],explainedCDS(:,1),'Intercept',false);
OLS_CS3_Result = mdlCS3.Coefficients{:,1}(end-9:end,:)';
OLS_CS3_Tstat = mdlCS3.Coefficients{:,3}(end-9:end,:)';
OLS_CS3_R2 = mdlCS3.Rsquared.Adjusted;
OLS_CDS3_Result = mdlCDS3.Coefficients{:,1}(end-9:end,:)';
OLS_CDS3_Tstat = mdlCDS3.Coefficients{:,3}(end-9:end,:)';
OLS_CDS3_R2 = mdlCDS3.Rsquared.Adjusted;

% Colonnes 4 et 8 : r�gression donn�es de panel
% Price = InterestRate + Slope + Index + Equity + ImpliedVol + OOTR + LaggedBasis + CDS Lagged
mdlCS4 = fitlm([e regressorMatrix4],explainedCS(:,1),'Intercept',false);
mdlCDS4 = fitlm([e regressorMatrix4],explainedCDS(:,1),'Intercept',false);
OLS_CS4_Result = mdlCS4.Coefficients{:,1}(end-12:end,:)';
OLS_CS4_Tstat = mdlCS4.Coefficients{:,3}(end-12:end,:)';
OLS_CS4_R2 = mdlCS4.Rsquared.Adjusted;
OLS_CDS4_Result = mdlCDS4.Coefficients{:,1}(end-12:end,:)';
OLS_CDS4_Tstat = mdlCDS4.Coefficients{:,3}(end-12:end,:)';
OLS_CDS4_R2 = mdlCDS4.Rsquared.Adjusted;

% Moyenne des Coefficients; t-stats; R2 pour data standard et Coefficients; t-stats; R2 pour donn�es de panel
CDS_1 = [round(mean(OLS_CDS1_Result),2); round(mean(OLS_CDS1_Tstat),2);[round(mean(OLS_CDS1_R2),2),zeros(1,4)]];  % Moyenne
CDS_2 = [round(mean(OLS_CDS2_Result),2); round(mean(OLS_CDS2_Tstat),2);[round(mean(OLS_CDS2_R2),2),zeros(1,6)]]; % Moyenne
CDS_3 = [round(OLS_CDS3_Result,3); round(OLS_CDS3_Tstat,3);[round(OLS_CDS3_R2,2),zeros(1,9)]]; % Valeur
CDS_4 = [round(OLS_CDS4_Result,3); round(OLS_CDS4_Tstat,3);[round(OLS_CDS4_R2,2),zeros(1,12)]]; % Valeur

CS_1 = [round(mean(OLS_CS1_Result),2); round(mean(OLS_CS1_Tstat),2);[round(mean(OLS_CS1_R2),2),zeros(1,4)]]; % Moyenne
CS_2 = [round(mean(OLS_CS2_Result),2); round(mean(OLS_CS2_Tstat),2);[round(mean(OLS_CS2_R2),2),zeros(1,6)]]; % Moyenne
CS_3 = [round(OLS_CS3_Result,2); round(OLS_CS3_Tstat,2);[round(OLS_CS3_R2,2),zeros(1,9)]]; % Valeur
CS_4 = [round(OLS_CS4_Result,2); round(OLS_CS4_Tstat,2);[round(OLS_CS4_R2,2),zeros(1,12)]]; % Valeur

% Remplissage du dictionnaire de r�sultats
DicoRegress = FillDicoRegress(CS_1,CS_2,CS_3,CS_4,CDS_1,CDS_2,CDS_3,CDS_4);

%% Affichage des r�sulats OLS

disp('RESULTATS D''ESTIMATION DES REGRESSIONS OLS, Moyenne corp par corp');
disp('--- Type :  IntRate      YldCurv      MktRet     EqtyRet       MktVol       ---');
disp('----------------------------------------------------------------------------------');
disp(['     CDS :  ', num2str(round(mean(OLS_CDS1_Result),4))]);
disp(['  Tstats :  ', num2str(round(mean(OLS_CDS1_Tstat),4))]);
disp(['      R2 :  ', num2str(round(mean(OLS_CDS1_R2),4))]);
disp(['      CS :  ', num2str(round(mean(OLS_CS1_Result),4))]);
disp(['  Tstats :  ', num2str(round(mean(OLS_CS1_Tstat),4))]);
disp(['      R2 :  ', num2str(round(mean(OLS_CS1_R2),4))]);
disp('---------------------------------------------------------------------------------');

disp('RESULTATS D''ESTIMATION DES REGRESSIONS OLS, augment�e du facteur liquidit� + base lagg�, Moyenne corp par corp');
disp('--- Type :  IntRate     YldCurv      MktRet     EqtyRet      MktVol      Liq     Lagged Basis  ---');
disp('------------------------------------------------------------------------------------------------------');
disp(['     CDS :  ', num2str(round(mean(OLS_CDS2_Result),4))]);
disp(['  Tstats :  ', num2str(round(mean(OLS_CDS2_Tstat),4))]);
disp(['      R2 :  ', num2str(round(mean(OLS_CDS2_R2),4))]);
disp(['      CS :  ', num2str(round(mean(OLS_CS2_Result),4))]);
disp(['  Tstats :  ', num2str(round(mean(OLS_CS2_Tstat),4))]);
disp(['      R2 :  ', num2str(round(mean(OLS_CS2_R2),4))]);
disp('-----------------------------------------------------------------------------------------------------');


%% Clears

% Variables import�es
clear Names_OLSGov10Y Names_OLSGov2Y Names_OLSIndex Names_OLSPut
clear OLS_EquityPrice OLS_ImpliedVol OLS_Index OLS_InterestRate OLS_LaggedBasis 
clear OLS_LaggedCDS OLS_OOTheRun OLS_PriceCDS OLS_PriceCS OLS_SlopeYield

% Variabl�ees cr�es
clear i adde currCompany rowpos currZone currCountry nbRow
clear colInterestRate colYieldCurve colImpliedVol colIndex

% Utilis�s dans les r�gressions
clear e regressorMatrix1 regressorMatrix2 regressorMatrix3 regressorMatrix4
clear explainedCDS explainedCS

% R�sultats des r�gressions
clear mdlCS1 mdlCS2 mdlCS3 mdlCS4 mdlCDS1 mdlCDS2 mdlCDS3 mdlCDS4
clear OLS_CS1_Result OLS_CS1_Tstat OLS_CS1_R2 OLS_CS2_Result OLS_CS2_Tstat OLS_CS2_R2 % CS 1 et 2
clear OLS_CS3_Result OLS_CS3_Tstat OLS_CS3_R2 OLS_CS4_Result OLS_CS4_Tstat OLS_CS4_R2 % CS 3 et 4
clear OLS_CDS1_Result OLS_CDS1_Tstat OLS_CDS1_R2 OLS_CDS2_Result OLS_CDS2_Tstat OLS_CDS2_R2 % CDS 1 et 2
clear OLS_CDS3_Result OLS_CDS3_Tstat OLS_CDS3_R2 OLS_CDS4_Result OLS_CDS4_Tstat OLS_CDS4_R2 % CDS 3 et 4
clear CS_1 CS_2 CS_3 CS_4 CDS_1 CDS_2 CDS_3 CDS_4


%% Arbitrage Quantitative Trading Strategies 

i_VECM = 1;
i_VAR = 1;


%user_answer = input( ...
%    'Do you want to optimize trading models ou use pre-optimized models ?\n[1] : optmize      /!\\ Very long : ~30min\n[2] : Use pre-optimised parameters\n>');

%if user_answer == 1
%    optimise = true;
%else user_answer == 2
    optimise = false;
%end

 for i = 1:nCol
     
    currentModel = table2array(DicoBacktest(i+1, 2));
    
    if currentModel(1:9) == 'Coint�gra'
        
        if optimise
            [window, K] = OptimiVECMBacktest(PriceCDS(1:100,i), PriceCS(1:100,i), 2); 
        else
            window = 42;
            K = 2;
        end
        
        [BTRatioVECM(i_VECM), bpsBTRatioVECM(i_VECM)] = RatioRevertBacktester(PriceCDS(:,i),PriceCS(:,i), window, K);
        [BTVECM(i_VECM), bpsBTVECM(i_VECM)] = VECMBacktester(PriceCDS(:,i),PriceCS(:,i), window, K);
        
        i_VECM = i_VECM + 1;
    elseif currentModel(1:9) == 'Causalit�'
        [BTVAR(i_VAR), bpsBTVAR(i_VAR)] = VARBacktester(PriceCDS(:,i),PriceCS(:,i));
        
        i_VAR = i_VAR + 1;
    end
    
 end
 
 
[benchmark, BTBench] = HoldBenchmark([PriceCDS, PriceCS]);
 
sumBTRatioVECM = sum(BTRatioVECM);
sumBTVECM = sum(BTVECM);
sumBTVAR = sum(BTVAR);
sumBench = sum(BTBench);

ROIVAR = mean(bpsBTVAR);
ROIVECM = mean(bpsBTVECM);
ROIMeanRevert = mean(bpsBTRatioVECM);

clear i i_arbitrage i_VAR i_VECM
clear currentModel


%% Backtest Via HMA Moving Average

PrevCum = 0;
% Recherche du Lag optim
NbRows = round(size(PriceCDS,1)/2);
for i=1:45
n = 30;
NbBPToAct = 0.05;

PnL = HMABactester(PriceCS(1:NbRows,:), PriceCDS(1:NbRows,:), n, NbBPToAct);
CumPnL = sum(PnL);

    if (CumPnL > PrevCum)
        PrevCum = CumPnL;
        LagOptim = n;
    end

end

% Strat�gie
PnL = HMABactester(PriceCS(NbRows+1:end,:), PriceCDS(NbRows+1:end,:), n, NbBPToAct);
CumPnL = sum(PnL);

clear PrevCum NbRows NbBPToAct