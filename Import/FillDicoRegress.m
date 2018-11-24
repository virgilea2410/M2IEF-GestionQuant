% FONCTION DE REMPLISSAGE DU DICTIONNAIRE DE REGRESSION OLS ECONONOMIQUE
% INPUTS:
%   - CS_R1    = Matrice de résultat des regressions 1 des CS (moyenne sur les entreprises des coefficiants, des t-stats et des R2s) 
%   - CS_R2    = Matrice de résultat des regressions 2 des CS (moyenne sur les entreprises des coefficiants, des t-stats et des R2s)
%   - CS_R3    = Matrice de résultat des regressions 1  et CDS lagged des CS via la méthode des données de pannel (coefficiants, t-stats et R2s)
%   - CS_R4    = Matrice de résultat des regressions 2  et CDS lagged des CS via la méthode des données de pannel (coefficiants, t-stats et R2s)
%   - CDS_R1   = Matrice de résultat des regressions 1 des CDS (moyenne sur les entreprises des coefficiants, des t-stats et des R2s)
%   - CDS_R2   = Matrice de résultat des regressions 2 des CDS (moyenne sur les entreprises des coefficiants, des t-stats et des R2s)
%   - CDS_R3   = Matrice de résultat des regressions 1  et CDS lagged des CDS via la méthode des données de pannel (coefficiants, t-stats et R2s)
%   - CDS_R4   = Matrice de résultat des regressions 2  et CDS lagged des CDS via la méthode des données de pannel (coefficiants, t-stats et R2s)
% OUTPUT:
%   - dicoToReturn = Dictionnaire des résultats des régressions organisée avec les différents types de régressions par colonnes et les coefficiants et t-stat associées par ligne


function [dicoToReturn] = FillDicoRegress(CS_R1, CS_R2, CS_R3, CS_R4, CDS_R1, CDS_R2, CDS_R3, CDS_R4)

%% Initialisation
dicoToReturn = cell(29,9);

dicoToReturn(3,1) = {'Change in long-term interest rate'};
dicoToReturn(5,1) = {'Change in slope of yield curve'};
dicoToReturn(7,1) = {'Equity market returns'};
dicoToReturn(9,1) = {'Firm-specific equity returns'};
dicoToReturn(11,1) = {'Change in market volatility'};
dicoToReturn(13,1) = {'Change in liquidity'};
dicoToReturn(15,1) = {'CDS(t-1)*Change in long-term interest rate'};
dicoToReturn(17,1) = {'CDS(t-1)*Change in slope of yield curve'};
dicoToReturn(19,1) = {'CDS(t-1)*Equity market returns'};
dicoToReturn(21,1) = {'CDS(t-1)*Firm-specific equity returns'};
dicoToReturn(23,1) = {'CDS(t-1)*Change in market volatility'};
dicoToReturn(25,1) = {'CDS(t-1)*Change in liquidity'};
dicoToReturn(27,1) = {'Lagged basis'};
dicoToReturn(29,1) = {'Adjusted R2'};

dicoToReturn(1,2) = {'CDS Price'};
dicoToReturn(1,6) = {'CS Price'};
dicoToReturn(2,2) = {'(1)'};
dicoToReturn(2,3) = {'(2)'};
dicoToReturn(2,4) = {'(3)'};
dicoToReturn(2,5) = {'(4)'};
dicoToReturn(2,6) = {'(1)'};
dicoToReturn(2,7) = {'(2)'};
dicoToReturn(2,8) = {'(3)'};
dicoToReturn(2,9) = {'(4)'};

%% Remplissage

% Colonnes 1 et 5: Regressor Matrix 1
    % Inscription des moyennes des coefficiants et des t-stat en dessous
for i = 1:5
    dicoToReturn(i*2-1+2,2) = {CDS_R1(1,i)};
    dicoToReturn(i*2+2,2) = {CDS_R1(2,i)};
    dicoToReturn(i*2-1+2,6) = {CS_R1(1,i)};
    dicoToReturn(i*2+2,6) = {CS_R1(2,i)};
end
    % Inscription des R2
dicoToReturn(29,2) = {CDS_R1(3,1)};
dicoToReturn(29,6) = {CS_R1(3,1)};


% Colonnes 2 et 6: Regressor Matrix 2
    % Inscription des moyennes des coefficiants et des t-stat en dessous
for i = 1:6
    dicoToReturn(i*2-1+2,3) = {CDS_R2(1,i)};
    dicoToReturn(i*2+2,3) = {CDS_R2(2,i)};
    dicoToReturn(i*2-1+2,7) = {CS_R2(1,i)};
    dicoToReturn(i*2+2,7) = {CS_R2(2,i)};
end
    % Inscription des R2 et LaggedBasis coefficiants
dicoToReturn(27,3) = {CDS_R2(1,end)};
dicoToReturn(28,3) = {CDS_R2(2,end)};
dicoToReturn(29,3) = {CDS_R2(3,1)};
dicoToReturn(27,7) = {CS_R2(1,end)};
dicoToReturn(28,7) = {CS_R2(2,end)};
dicoToReturn(29,7) = {CS_R2(3,1)};

% Colonnes 3 et 7: Regressor Matrix 3 et CDS Lagged
    % Inscription des coefficiants et des t-stat en dessous
for i = 1:5
    dicoToReturn(i*2-1+2,4) = {CDS_R3(1,i)};
    dicoToReturn(i*2+2,4) = {CDS_R3(2,i)};
    dicoToReturn(i*2-1+2,8) = {CS_R3(1,i)};
    dicoToReturn(i*2+2,8) = {+CS_R3(2,i)};
    dicoToReturn(i*2-1+2+12,4) = {CDS_R3(1,i+5)};
    dicoToReturn(i*2+2+12,4) = {CDS_R3(2,i+5)};
    dicoToReturn(i*2-1+2+12,8) = {CS_R3(1,i+5)};
    dicoToReturn(i*2+2+12,8) = {CS_R3(2,i+5)};
end
    % Inscription des R2
dicoToReturn(29,4) = {CDS_R3(3,1)};
dicoToReturn(29,8) = {CS_R3(3,1)};

% Colonnes 4 et 8: Regressor Matrix 4 et CDS Lagged
    % Inscription des coefficiants et des t-stat en dessous
for i = 1:13
    dicoToReturn(i*2-1+2,5) = {CDS_R4(1,i)};
    dicoToReturn(i*2+2,5) = {CDS_R4(2,i)};
    dicoToReturn(i*2-1+2,9) = {CS_R4(1,i)};
    dicoToReturn(i*2+2,9) = {CS_R4(2,i)};
end
    % Inscription des R2
dicoToReturn(29,5) = {CDS_R4(3,1)};
dicoToReturn(29,9) = {CS_R4(3,1)};


end

